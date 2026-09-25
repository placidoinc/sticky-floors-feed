// The tracked venue allow-list. This is the source of truth for which
// screenings make it into the output feed — anything at a Place not listed
// here (a trivia night, an untracked venue) is dropped during the merge,
// same filtering job Sticky Floors' own SeedData.venueIDsByFeedPlaceID does
// on-device today. Kept in sync by hand with the app's copy in Models.swift
// until a venue actually needs adding from this side first.

struct FeedVenue: Encodable {
    let id: String
    let name: String
    let city: String
    let neighborhood: String
    let address: String
    let bio: String
    let ticketingURL: String?
    let organizerID: String?
    let feedPlaceID: String
    let latitude: Double
    let longitude: Double
}

struct FeedOrganizer: Encodable {
    let id: String
    let name: String
}

enum Venues {
    static let organizers: [FeedOrganizer] = [
        FeedOrganizer(id: "americancinematheque", name: "American Cinematheque"),
    ]

    static let all: [FeedVenue] = [
        FeedVenue(id: "2220", name: "2220 Arts + Archives", city: "Los Angeles", neighborhood: "2220 Beverly Blvd", address: "2220 Beverly Blvd, Los Angeles", bio: "An artist-run space in Historic Filipinotown, in the old Bootleg Theater building, programming experimental film, music, and literature since 2021.", ticketingURL: "https://2220arts.org", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/cef531ba-2898-48e9-8715-3c02587742a6", latitude: 34.0672466, longitude: -118.2722135),
        FeedVenue(id: "academy", name: "Academy Museum", city: "Los Angeles", neighborhood: "6067 Wilshire Blvd", address: "6067 Wilshire Blvd, Los Angeles", bio: "The Academy's film museum on Miracle Mile, open since 2021, with two theaters running curated series and restorations.", ticketingURL: "https://www.academymuseum.org", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/b99ddcce-3455-464d-85f5-200cbf64bdbf", latitude: 34.0635, longitude: -118.3608),
        FeedVenue(id: "aero", name: "Aero Theatre", city: "Los Angeles", neighborhood: "1328 Montana Ave, Santa Monica", address: "1328 Montana Ave, Santa Monica", bio: "A 1940 single-screen house in Santa Monica, built for Douglas Aircraft workers, run by American Cinematheque since 2005.", ticketingURL: "https://www.americancinematheque.com", organizerID: "americancinematheque", feedPlaceID: "https://zeitgeists.org/place/df36aee8-17ff-4580-885b-45f791d689d7", latitude: 34.0319362, longitude: -118.4952943),
        FeedVenue(id: "braindead", name: "Brain Dead Studios", city: "Los Angeles", neighborhood: "Fairfax District", address: "611 N Fairfax Ave, Los Angeles", bio: "The label Brain Dead's repertory cinema on Fairfax, in the 1942 building that was once the Silent Movie Theatre and Cinefamily.", ticketingURL: "https://braindeadstudios.com", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/56111734-e813-46cb-b97c-4ffa9f24f895", latitude: 34.0820184, longitude: -118.3617556),
        FeedVenue(id: "gardena", name: "Gardena Cinema", city: "Los Angeles", neighborhood: "Gardena", address: "14948 Crenshaw Blvd, Gardena", bio: "An 800-seat single-screen theater from 1946, family-run by the Kim family since 1976 — the last of its kind in the South Bay.", ticketingURL: "https://gardenacinema.com", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/97b51366-29fd-4a47-906b-2ae169c6c5f4", latitude: 33.8960608, longitude: -118.3289312),
        FeedVenue(id: "losfeliz", name: "Los Feliz Theatre", city: "Los Angeles", neighborhood: "1822 N Vermont Ave", address: "1822 N Vermont Ave, Los Angeles", bio: "A 1935 art deco theater next to Skylight Books, owned by Vintage Cinemas and programmed daily by American Cinematheque.", ticketingURL: "https://vintagecinemas.com/losfeliz3", organizerID: "americancinematheque", feedPlaceID: "https://zeitgeists.org/place/4a6cb12a-8fb2-43bf-92d8-621509baf918", latitude: 34.1043595, longitude: -118.3011787),
        FeedVenue(id: "newbev", name: "New Beverly Cinema", city: "Los Angeles", neighborhood: "Beverly Blvd", address: "7165 Beverly Blvd, Los Angeles", bio: "LA's oldest revival house, in a 1920s building on Beverly Blvd, owned by Quentin Tarantino since 2007 and run on 35mm and 16mm.", ticketingURL: "https://thenewbev.com", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/85618347-6a83-4a0c-9fb6-05cab4b0e2c4", latitude: 34.0763294, longitude: -118.3457652),
        FeedVenue(id: "scribble", name: "Scribble", city: "Los Angeles", neighborhood: "Los Angeles", address: "5541 York Blvd, Los Angeles", bio: "A nonprofit on a Highland Park corner — sliding-scale counseling center by day, all-ages venue for screenings, concerts, and comedy by night.", ticketingURL: nil, organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/2acb6445-a5b1-4a2b-8135-38e199794a0a", latitude: 34.1196054, longitude: -118.1968121),
        FeedVenue(id: "stories", name: "Stories Books & Cafe", city: "Los Angeles", neighborhood: "1716 Sunset Blvd", address: "1716 Sunset Blvd, Los Angeles", bio: "Echo Park's neighborhood bookstore and café on Sunset, with a back patio that becomes an event space for readings, screenings, and music at night.", ticketingURL: "https://storiesla.com", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/0ffcfb61-4a2f-4f11-82c2-e0d8d0ffb1cf", latitude: 34.0773434, longitude: -118.2590913),
        FeedVenue(id: "vidiots", name: "Vidiots", city: "Los Angeles", neighborhood: "Eagle Rock", address: "4884 Eagle Rock Blvd, Los Angeles", bio: "The legendary Santa Monica video store, reborn in 2023 as a nonprofit in Eagle Rock's 1929 Eagle Theatre — 271 seats, a bar, and 60,000 tapes.", ticketingURL: "https://vidiotsfoundation.org", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/243a1ac8-7eae-401b-86dc-46a06066a2d4", latitude: 34.1349023, longitude: -118.2151265),
        FeedVenue(id: "vista", name: "Vista Theatre", city: "Los Angeles", neighborhood: "Los Feliz", address: "4473 Sunset Dr, Los Angeles", bio: "A 1923 single-screen theater on the Los Feliz/East Hollywood line, Spanish outside and Egyptian inside, owned by Quentin Tarantino since 2021.", ticketingURL: "https://vintagecinemas.com/vista", organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/16149119-3064-4887-888c-f38bbab6cc82", latitude: 34.0982827, longitude: -118.2869511),
        FeedVenue(id: "whammy", name: "WHAMMY!", city: "Los Angeles", neighborhood: "Los Angeles", address: "2514 Sunset Blvd (rear), Los Angeles", bio: "A VHS shop and microcinema in an Echo Park alley, open since 2022, screening rare tapes and cult finds Wednesday through Sunday.", ticketingURL: nil, organizerID: nil, feedPlaceID: "https://zeitgeists.org/place/b5facb33-96b2-4c50-8e84-71a9e7c46c82", latitude: 34.0795062, longitude: -118.2697078),
        FeedVenue(id: "egyptian", name: "Egyptian Theatre", city: "Los Angeles", neighborhood: "Hollywood Blvd", address: "6712 Hollywood Blvd, Los Angeles", bio: "Sid Grauman's 1922 Hollywood movie palace, the first for a studio premiere, restored and run by American Cinematheque.", ticketingURL: "https://www.americancinematheque.com", organizerID: "americancinematheque", feedPlaceID: "https://zeitgeists.org/place/5f346b86-2a9e-406f-90d2-833484c20820", latitude: 34.1017, longitude: -118.3300),
    ]

    /// Feed `Place` `@id` -> our venue id — the actual allow-list filter.
    static var idsByFeedPlaceID: [String: String] {
        Dictionary(uniqueKeysWithValues: all.map { ($0.feedPlaceID, $0.id) })
    }
}
