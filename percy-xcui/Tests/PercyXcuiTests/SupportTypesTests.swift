import Foundation
import Testing

@testable import PercyXcui

struct TileTests {
  @Test func getTileJSONSingle() throws {
    let tile = Tile(
      content: "data", statusBarHeight: 44, navBarHeight: 1, headerHeight: 2, footerHeight: 3,
      fullScreen: true)
    let json = try #require(Tile.getTileJSON(tiles: [tile]) as? [[String: Any]])
    #expect(json.count == 1)
    #expect(json[0]["content"] as? String == "data")
    #expect(json[0]["statusBarHeight"] as? Int == 44)
    #expect(json[0]["navBarHeight"] as? Int == 1)
    #expect(json[0]["headerHeight"] as? Int == 2)
    #expect(json[0]["footerHeight"] as? Int == 3)
    #expect(json[0]["fullscreen"] as? Bool == true)
  }

  @Test func getTileJSONMultiple() throws {
    let tiles = [
      Tile(content: "a", statusBarHeight: 0, navBarHeight: 0, headerHeight: 0, footerHeight: 0,
        fullScreen: false),
      Tile(content: "b", statusBarHeight: 0, navBarHeight: 0, headerHeight: 0, footerHeight: 0,
        fullScreen: false)
    ]
    let json = try #require(Tile.getTileJSON(tiles: tiles) as? [[String: Any]])
    #expect(json.count == 2)
  }

  @Test func getTileJSONEmpty() throws {
    let json = try #require(Tile.getTileJSON(tiles: []) as? [[String: Any]])
    #expect(json.isEmpty)
  }
}

struct ScreenshotOptionsTests {
  @Test func defaults() {
    let options = ScreenshotOptions()
    #expect(options.statusBarHeight == -1)
    #expect(options.navigationBarHeight == -1)
    #expect(options.fullScreen == false)
    #expect(options.testCase == nil)
    #expect(options.labels == nil)
  }

  @Test func mutation() {
    let options = ScreenshotOptions()
    options.statusBarHeight = 10
    options.navigationBarHeight = 20
    options.fullScreen = true
    options.testCase = "tc"
    options.labels = "a,b"
    #expect(options.statusBarHeight == 10)
    #expect(options.navigationBarHeight == 20)
    #expect(options.fullScreen == true)
    #expect(options.testCase == "tc")
    #expect(options.labels == "a,b")
  }
}

@Suite(.serialized)
struct LoggerTests {
  @Test func info() {
    Log.logLevel = "info"
    Log.info(msg: "an info message")
    Log.logLevel = "info"
  }

  @Test func errorAlwaysLogs() {
    Log.logLevel = "info"
    Log.error(msg: "an error message")
  }

  @Test func debugSuppressedWhenNotDebugLevel() {
    Log.logLevel = "info"
    // Returns early without logging (exercises the guard's true branch).
    Log.debug(msg: "should be suppressed")
  }

  @Test func debugEmittedWhenDebugLevel() {
    Log.logLevel = "debug"
    Log.debug(msg: "should be emitted")
    Log.logLevel = "info"
  }

  @Test func logfmtDefaultLevel() {
    Log.logfmt(msg: "direct logfmt call")
  }
}

struct ErrorsTests {
  @Test func screenshotErrorCase() {
    let error: AppPercyError = .screenshotError("boom")
    guard case let .screenshotError(message) = error else {
      Issue.record("Expected screenshotError")
      return
    }
    #expect(message == "boom")
  }

  @Test func postScreenshotErrorCase() {
    let error: AppPercyError = .postScreenshotError("nope")
    guard case let .postScreenshotError(message) = error else {
      Issue.record("Expected postScreenshotError")
      return
    }
    #expect(message == "nope")
  }
}

struct ScreenshotControllerTests {
  @Test func takeScreenshotThrowsOnHost() {
    // On the non-UIKit host the controller shim throws (real capture needs the
    // iOS runtime). On an iOS simulator build this same call captures a screen.
    #expect(throws: AppPercyError.self) {
      _ = try ScreenshotController().takeScreenshot()
    }
  }
}
