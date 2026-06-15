import Foundation
import Testing

@testable import PercyXcui

struct GenericProviderTests {
  @Test func screenshotBuildsTagThenThrowsOnHostCapture() {
    Log.logLevel = "debug"
    let provider = GenericProvider()
    // screenshot() builds the metadata + tag, then captureTiles() calls
    // ScreenshotController().takeScreenshot() which throws on the non-UIKit
    // host. This exercises getTag(), statBarHeight() and navBarHeight().
    #expect(throws: AppPercyError.self) {
      try provider.screenshot(name: "abc", options: ScreenshotOptions())
    }
  }

  @Test func screenshotWithCustomOptions() {
    let provider = GenericProvider()
    let options = ScreenshotOptions()
    options.statusBarHeight = 10
    options.navigationBarHeight = 20
    options.testCase = "tc"
    options.labels = "l1,l2"
    #expect(throws: AppPercyError.self) {
      try provider.screenshot(name: "abc", options: options)
    }
  }
}
