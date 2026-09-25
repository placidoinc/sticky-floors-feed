// Vista Theatre's own site carries director/runtime data zeitgeists doesn't
// for this one venue — same gap-filling role as the app's own
// VenueSiteScraper.swift, moved server-side so it runs once nightly instead
// of once per phone per launch (politer to Vista's server, and it's the
// same reasoning the whole backend exists for). Not a general "scrape any
// venue" abstraction — a second venue gets a second scraper file like this
// one, only once it actually needs one.

import Foundation

struct ScrapedFilmMeta {
    let title: String
    let year: String?
    let runtimeMinutes: Int?
    let director: String?
}

enum VistaScraper {
    private static let scheduleURL = URL(string: "https://vistatheaterhollywood.com/schedule")!
    private static let moviePageBase = "https://vistatheaterhollywood.com/movies/"

    static func fetchCurrentFilms() async -> [ScrapedFilmMeta] {
        let slugs: [String]
        do {
            slugs = try await fetchSlugs()
        } catch {
            print("Vista schedule fetch failed: \(error)")
            return []
        }

        var out: [ScrapedFilmMeta] = []
        await withTaskGroup(of: ScrapedFilmMeta?.self) { group in
            for slug in slugs {
                group.addTask {
                    do {
                        return try await fetchFilm(slug: slug)
                    } catch {
                        print("Vista movie page fetch failed for \"\(slug)\": \(error)")
                        return nil
                    }
                }
            }
            for await film in group {
                if let film { out.append(film) }
            }
        }
        print("Vista scrape: \(out.count)/\(slugs.count) movie pages yielded metadata")
        return out
    }

    private static func fetchSlugs() async throws -> [String] {
        let (data, response) = try await Net.data(from: scheduleURL)
        guard 200..<300 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        let html = String(decoding: data, as: UTF8.self)
        let regex = try NSRegularExpression(pattern: #"/movies/([a-z0-9-]+)"#)
        let range = NSRange(html.startIndex..., in: html)
        var slugs: [String] = []
        var seen = Set<String>()
        regex.enumerateMatches(in: html, range: range) { match, _, _ in
            guard let match, let r = Range(match.range(at: 1), in: html) else { return }
            let slug = String(html[r])
            if seen.insert(slug).inserted { slugs.append(slug) }
        }
        return slugs
    }

    private static func fetchFilm(slug: String) async throws -> ScrapedFilmMeta? {
        guard let url = URL(string: moviePageBase + slug) else { return nil }
        let (data, response) = try await Net.data(from: url)
        guard 200..<300 ~= response.statusCode else {
            throw URLError(.badServerResponse)
        }
        let html = String(decoding: data, as: UTF8.self)

        guard let title = firstMatch(#"entry__movie--title[^>]*>([^<]+)<"#, in: html).map(decodeHTMLEntities) else { return nil }
        let director = firstMatch(#"entry__movie--directors"[^>]*><p>([^<]+)<"#, in: html).map(decodeHTMLEntities)
        let details = firstMatch(#"entry__movie--details"[^>]*>([^<]+)<"#, in: html).map(decodeHTMLEntities)

        var year: String?
        var runtimeMinutes: Int?
        if let details {
            let parts = details.components(separatedBy: "·").map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }
            year = parts.first { $0.count == 4 && Int($0) != nil }
            runtimeMinutes = parts.compactMap(parseRuntime).first
        }

        return ScrapedFilmMeta(title: title, year: year, runtimeMinutes: runtimeMinutes, director: director)
    }

    private static func parseRuntime(_ s: String) -> Int? {
        let lower = s.lowercased()
        guard lower.contains("h") || lower.contains("m") else { return nil }
        var hours = 0, minutes = 0, matchedAnything = false
        if let r = lower.range(of: #"\d+(?=h)"#, options: .regularExpression) {
            hours = Int(lower[r]) ?? 0
            matchedAnything = true
        }
        if let r = lower.range(of: #"\d+(?=m)"#, options: .regularExpression) {
            minutes = Int(lower[r]) ?? 0
            matchedAnything = true
        }
        guard matchedAnything else { return nil }
        return hours * 60 + minutes
    }

    private static func decodeHTMLEntities(_ s: String) -> String {
        var out = s
        for (entity, replacement) in [
            ("&amp;", "&"), ("&quot;", "\""), ("&apos;", "'"), ("&#039;", "'"),
            ("&lt;", "<"), ("&gt;", ">"), ("&nbsp;", " "),
        ] {
            out = out.replacingOccurrences(of: entity, with: replacement)
        }
        while let match = out.range(of: #"&#x?[0-9a-fA-F]+;"#, options: .regularExpression) {
            let entity = out[match]
            let digits = entity.dropFirst(entity.hasPrefix("&#x") ? 3 : 2).dropLast()
            guard let code = UInt32(digits, radix: entity.hasPrefix("&#x") ? 16 : 10),
                  let scalar = Unicode.Scalar(code) else { break }
            out.replaceSubrange(match, with: String(Character(scalar)))
        }
        return out
    }

    private static func firstMatch(_ pattern: String, in html: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let range = Range(match.range(at: 1), in: html) else { return nil }
        return html[range].trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// A loose, punctuation/case-insensitive key for matching a Vista scrape
/// title against the feed's own raw screening title for that same film —
/// not the app's full matchKey() (no need for the format/presenter/series
/// stripping here, since Vista's own page titles don't carry that noise).
func looseTitleKey(_ s: String) -> String {
    s.lowercased().replacingOccurrences(of: #"[^a-z0-9]+"#, with: " ", options: .regularExpression)
        .trimmingCharacters(in: CharacterSet.whitespaces)
}
