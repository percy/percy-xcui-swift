import Foundation
import Testing

@testable import PercyXcui

/// Serialized because these tests mutate global state: the registered
/// `URLProtocol` stub and `Log.logLevel`.
@Suite(.serialized)
struct CliWrapperTests {
  init() {
    StubURLProtocol.register()
    StubURLProtocol.reset()
    Log.logLevel = "debug"
  }

  private func tile() -> Tile {
    return Tile(
      content: "abc", statusBarHeight: 44, navBarHeight: 0, headerHeight: 0, footerHeight: 0,
      fullScreen: false)
  }

  // MARK: - healthcheck

  @Test func healthcheckSuccessNoVersionHeader() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 204, headers: [:], body: nil, error: nil)
    #expect(CliWrapper().healthcheck() == true)
  }

  @Test func healthcheckSuccessSupportedVersion() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 200, headers: ["X-Percy-Core-Version": "1.30.0"], body: nil, error: nil)
    #expect(CliWrapper().healthcheck() == true)
  }

  @Test func healthcheckSuccessMinorBelow24() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 200, headers: ["X-Percy-Core-Version": "1.10.0"], body: nil, error: nil)
    // Still enabled, just an informational message about the minor version.
    #expect(CliWrapper().healthcheck() == true)
  }

  @Test func healthcheckUnsupportedMajorVersion() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 200, headers: ["X-Percy-Core-Version": "0.99.0"], body: nil, error: nil)
    #expect(CliWrapper().healthcheck() == false)
  }

  @Test func healthcheckNonNumericVersion() {
    defer { StubURLProtocol.unregister() }
    // Exercises the `Int(...) ?? 0` fallbacks for both components.
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 200, headers: ["X-Percy-Core-Version": "x.y.z"], body: nil, error: nil)
    // major parses to 0 -> unsupported.
    #expect(CliWrapper().healthcheck() == false)
  }

  @Test func healthcheckTransportError() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 0, headers: [:], body: nil, error: URLError(.notConnectedToInternet))
    #expect(CliWrapper().healthcheck() == false)
  }

  @Test func healthcheckNoStubConnectionFailure() {
    defer { StubURLProtocol.unregister() }
    // No stub registered -> StubURLProtocol simulates a connection failure.
    #expect(CliWrapper().healthcheck() == false)
  }

  // MARK: - postScreenshot

  @Test func postScreenshotSuccess() throws {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 200, headers: [:], body: Data("{\"link\":\"https://x\"}".utf8), error: nil)
    let response = try CliWrapper().postScreenshot(
      name: "abc", tag: ["name": "iPhone"], tiles: [tile()], testCase: "tc", labels: "l1")
    #expect(response["link"] as? String == "https://x")
  }

  @Test func postScreenshotSuccessNilOptionalFields() throws {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 201, headers: [:], body: Data("{\"link\":\"https://y\"}".utf8), error: nil)
    let response = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [tile()])
    #expect(response["link"] as? String == "https://y")
  }

  @Test func postScreenshotTransportError() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 0, headers: [:], body: nil, error: URLError(.timedOut))
    #expect(throws: AppPercyError.self) {
      _ = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [self.tile()])
    }
  }

  @Test func postScreenshotNon2xx() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 500, headers: [:], body: Data("err".utf8), error: nil)
    #expect(throws: AppPercyError.self) {
      _ = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [self.tile()])
    }
  }

  @Test func postScreenshotNilBody() {
    defer { StubURLProtocol.unregister() }
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 200, headers: [:], body: nil, error: nil)
    // 2xx but no data -> nil-data path -> empty ret -> throws.
    #expect(throws: AppPercyError.self) {
      _ = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [self.tile()])
    }
  }

  @Test func postScreenshotCorruptedJSON() {
    defer { StubURLProtocol.unregister() }
    // Valid UTF-8 but a JSON array, not an object -> jsonObject cast fails.
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 200, headers: [:], body: Data("[1,2,3]".utf8), error: nil)
    #expect(throws: AppPercyError.self) {
      _ = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [self.tile()])
    }
  }

  @Test func postScreenshotNonUTF8Body() {
    defer { StubURLProtocol.unregister() }
    // Invalid UTF-8 bytes: exercises the "Unable to decode as UTF-8" debug path,
    // then JSONSerialization fails -> empty ret -> throws.
    StubURLProtocol.stubs["/percy/comparison"] = .init(
      statusCode: 200, headers: [:], body: Data([0xff, 0xfe, 0xfd]), error: nil)
    #expect(throws: AppPercyError.self) {
      _ = try CliWrapper().postScreenshot(name: "abc", tag: [:], tiles: [self.tile()])
    }
  }

  // Note: the `do/catch` around JSONSerialization.data(withJSONObject:) in
  // CliWrapper.postScreenshot is defensive. Foundation raises an Objective-C
  // NSInvalidArgumentException (not a Swift error) for invalid JSON objects, so
  // that catch block cannot be reached from a unit test without aborting the
  // process. Those two lines are documented as host-uncovered defensive code.
}
