import Foundation

@testable import PercyXcui

/// A `URLProtocol` subclass that intercepts every request made through
/// `URLSession.shared` (which `CliWrapper` uses) and returns a canned response
/// keyed by URL path. Registering a global `URLProtocol` is the supported way
/// to stub `URLSession.shared` without adding a third-party HTTP-stub
/// dependency, and lets the unit suite exercise `CliWrapper` on the macOS host.
final class StubURLProtocol: URLProtocol {
  /// A canned outcome for a single request.
  struct Stub {
    var statusCode: Int
    var headers: [String: String]
    var body: Data?
    var error: Error?
  }

  /// Maps a URL path (e.g. "/percy/healthcheck") to its canned outcome.
  static var stubs: [String: Stub] = [:]

  /// Set to simulate a transport-level failure for any unmatched request.
  static var fallbackError: Error?

  static func reset() {
    stubs = [:]
    fallbackError = nil
  }

  static func register() {
    URLProtocol.registerClass(StubURLProtocol.self)
  }

  static func unregister() {
    URLProtocol.unregisterClass(StubURLProtocol.self)
    reset()
  }

  override class func canInit(with request: URLRequest) -> Bool {
    return true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    return request
  }

  override func startLoading() {
    guard let url = request.url else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }

    let stub = StubURLProtocol.stubs[url.path]

    if let error = stub?.error ?? StubURLProtocol.fallbackError {
      client?.urlProtocol(self, didFailWithError: error)
      return
    }

    guard let stub = stub else {
      // No stub configured: behave like a connection failure.
      client?.urlProtocol(self, didFailWithError: URLError(.cannotConnectToHost))
      return
    }

    if let response = HTTPURLResponse(
      url: url, statusCode: stub.statusCode, httpVersion: "HTTP/1.1", headerFields: stub.headers) {
      client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    }

    if let body = stub.body {
      client?.urlProtocol(self, didLoad: body)
    }

    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {
    // No-op: responses are delivered synchronously in startLoading().
  }
}
