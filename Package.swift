// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "sticky-floors-feed",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(name: "GenerateFeed", path: "Sources/GenerateFeed")
    ]
)
