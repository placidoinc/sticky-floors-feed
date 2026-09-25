// The async URLSession.data(from:) convenience method isn't reliably
// present across Linux Foundation versions (confirmed missing under
// swift:5.10-jammy in CI, present under 6.0 — but 6.0's FoundationNetworking
// hit a separate libcurl crash instead). The completion-handler dataTask
// API has been stable on Linux since early swift-corelibs-foundation, so
// wrapping it in a continuation sidesteps both problems at once.

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum Net {
    static func data(from url: URL) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data, let response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            task.resume()
        }
    }
}
