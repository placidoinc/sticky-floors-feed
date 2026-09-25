import Foundation

struct Feed: Encodable {
    let generatedAt: String
    let venues: [FeedVenue]
    let organizers: [FeedOrganizer]
    let screenings: [FeedScreening]
}

@main
struct GenerateFeed {
    static func main() async throws {
        print("Fetching zeitgeists.org LA feed…")
        var screenings = try await ZeitgeistsFetch.fetchScreenings()
        print("Kept \(screenings.count) screenings at tracked venues.")

        print("Scraping Vista Theatre's own site for gap-fill metadata…")
        let vistaFilms = await VistaScraper.fetchCurrentFilms()
        var vistaByKey: [String: ScrapedFilmMeta] = [:]
        for film in vistaFilms { vistaByKey[looseTitleKey(film.title)] = film }

        var filled = 0
        for i in screenings.indices where screenings[i].venueID == "vista" {
            guard screenings[i].feedDirectorHint == nil,
                  let match = vistaByKey[looseTitleKey(screenings[i].rawTitle)] else { continue }
            if screenings[i].feedDirectorHint == nil { screenings[i].feedDirectorHint = match.director }
            if screenings[i].feedRuntimeHint == nil { screenings[i].feedRuntimeHint = match.runtimeMinutes }
            filled += 1
        }
        print("Filled \(filled) Vista screening(s) with scraped director/runtime hints.")

        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let feed = Feed(
            generatedAt: isoFormatter.string(from: Date()),
            venues: Venues.all,
            organizers: Venues.organizers,
            screenings: screenings
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(feed)

        let outputURL = URL(fileURLWithPath: "docs/feed.json")
        try data.write(to: outputURL)
        print("Wrote \(data.count) bytes to \(outputURL.path)")
    }
}
