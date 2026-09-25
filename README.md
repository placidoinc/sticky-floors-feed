# sticky-floors-feed

Nightly job that merges zeitgeists.org + Sticky Floors' own venue scrapers into one
normalized JSON feed, published via GitHub Pages, for the Sticky Floors iOS app to read.

Separate from the main app repo on purpose — this repo only ever holds the
ingestion job and its output feed, never app source.
