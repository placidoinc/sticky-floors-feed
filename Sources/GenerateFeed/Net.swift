// swift-corelibs-foundation's URLSession hits a reproducible crash on Linux
// fetching zeitgeists' feed — "libcurl.Easy Code=43", confirmed across two
// Swift toolchain versions (6.0, 5.10), while a plain `curl` against the
// identical URL from the identical CI environment succeeds instantly with a
// clean 200 and valid JSON. That isolates the bug to Foundation's own HTTP
// client, not the network path — so this shells out to the same `curl`
// binary that's already proven reliable, instead of using URLSession at all.
// Works the same way on macOS (curl is preinstalled there too), so there's
// no platform-conditional code path to maintain.

import Foundation

struct SimpleResponse {
    let statusCode: Int
}

enum NetError: Error {
    case curlFailed(Int32)
}

enum Net {
    static func data(from url: URL) async throws -> (Data, SimpleResponse) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["curl", "-sL", "--max-time", "60", "-o", tempURL.path, "-w", "%{http_code}", url.absoluteString]
        let stdoutPipe = Pipe()
        process.standardOutput = stdoutPipe

        try process.run()
        process.waitUntilExit()
        guard process.terminationStatus == 0 else {
            throw NetError.curlFailed(process.terminationStatus)
        }

        let statusData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
        let statusCode = Int(String(decoding: statusData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)) ?? 0
        let data = try Data(contentsOf: tempURL)
        return (data, SimpleResponse(statusCode: statusCode))
    }
}
