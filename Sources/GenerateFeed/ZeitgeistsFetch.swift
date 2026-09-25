// Fetches zeitgeists.org's LA feed and keeps only screenings at a tracked
// venue. Mirrors Sticky Floors' own ZeitgeistsClient.swift (same feed, same
// @graph parsing, same workPresented fields) — the only real difference is
// this runs once nightly on a server instead of once per phone per launch.

import Foundation

struct FeedWork: Encodable {
    let rawName: String
    let year: String?
    let runtimeMinutes: Int?
    let director: String?
}

struct FeedScreening: Encodable {
    let rawTitle: String
    let venueID: String
    let start: String // ISO8601
    var feedDirectorHint: String?
    var feedRuntimeHint: Int?
    var ticketURL: String?
    var rawDescription: String?
    var videoFormats: [String]
    var works: [FeedWork]
}

enum ZeitgeistsError: Error {
    case badResponse
    case malformed
}

enum ZeitgeistsFetch {
    private static let feedURL = URL(string: "https://feeds.zeitgeists.org/region/los-angeles.json")!

    static func fetchScreenings() async throws -> [FeedScreening] {
        let (data, response) = try await URLSession.shared.data(from: feedURL)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw ZeitgeistsError.badResponse
        }
        guard let root = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let graph = root["@graph"] as? [[String: Any]] else {
            throw ZeitgeistsError.malformed
        }

        let venueIDsByFeedPlaceID = Venues.idsByFeedPlaceID
        let isoWithFraction = ISO8601DateFormatter()
        isoWithFraction.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let isoPlain = ISO8601DateFormatter()
        isoPlain.formatOptions = [.withInternetDateTime]
        func parseDate(_ raw: Any?) -> Date? {
            guard let s = raw as? String else { return nil }
            return isoWithFraction.date(from: s) ?? isoPlain.date(from: s)
        }

        var screenings: [FeedScreening] = []
        for node in graph {
            guard node["@type"] as? String == "ScreeningEvent",
                  let rawTitle = node["name"] as? String,
                  let start = parseDate(node["startDate"]),
                  let location = node["location"] as? [String: Any],
                  let placeID = location["@id"] as? String,
                  let venueID = venueIDsByFeedPlaceID[placeID]
            else { continue }
            let ticketURL = node["url"] as? String
            let workNodes = (node["workPresented"] as? [[String: Any]]) ?? []
            let works: [FeedWork] = workNodes.compactMap { w in
                guard let name = w["name"] as? String else { return nil }
                let year = (w["year"] as? Int).map(String.init) ?? (w["year"] as? String)
                let runtime = (w["duration"] as? Int) ?? (w["duration"] as? NSNumber)?.intValue
                let director = (w["director"] as? [String: Any])?["name"] as? String
                return FeedWork(rawName: name, year: year, runtimeMinutes: runtime, director: director)
            }
            let description = (node["description"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let videoFormats = workNodes.compactMap { $0["videoFormat"] as? String }
            screenings.append(FeedScreening(
                rawTitle: rawTitle, venueID: venueID, start: isoWithFraction.string(from: start),
                feedDirectorHint: works.first?.director, feedRuntimeHint: works.first?.runtimeMinutes,
                ticketURL: ticketURL, rawDescription: (description?.isEmpty == false) ? description : nil,
                videoFormats: videoFormats, works: works))
        }
        return screenings
    }
}
