import XCTest

@testable import PercyXcui

final class AppPercyTests: XCTestCase {
  var percy: AppPercy = AppPercy()

  override func setUp() {
    let app = XCUIApplication()
    app.launch()

    NetworkHelpers.start(requests: [
      NetworkHelpers.stubHealthcheck(), NetworkHelpers.stubPostComparison()
    ])
    percy = AppPercy()
    Log.logLevel = "debug"
  }

  override func tearDown() {
    NetworkHelpers.stop()
    super.tearDown()
  }

  func testScreenshot() throws {
    try percy.screenshot(name: "abc")
  }

  func testScreenshotIfCLIError() throws {
    // reset network stub
    NetworkHelpers.stop()
    NetworkHelpers.start(requests: [
      NetworkHelpers.stubHealthcheck(), NetworkHelpers.stubPostComparison(success: false)
    ])

    // does not throw
    try percy.screenshot(name: "abc")

    // with throw true
    AppPercy.ignoreErrors = false
    XCTAssertThrowsError(try percy.screenshot(name: "abc")) { error in
      XCTAssertTrue(error is AppPercyError)
    }

    // reset
    AppPercy.ignoreErrors = true
  }

  func testScreenshotIfDeviceNotAllowed() throws {
    // reset network stub
    NetworkHelpers.stop()
    // We do not mock postComparison here so that it throws if screenshot is taken
    NetworkHelpers.start(requests: [NetworkHelpers.stubHealthcheck()])

    // does not throw
    AppPercy.ignoreErrors = false
    AppPercy.allowedDevices = ["Clearly not current phone"]
    try percy.screenshot(name: "abc")

    // reset
    AppPercy.ignoreErrors = true
  }

  func testScreenshotForDifferentHostName() throws {
    AppPercy.percyCLIHostname = "app-percy.cli"
    AppPercy.percyCLIPort = 5448
    percy = AppPercy()
    // reset network stub
    NetworkHelpers.stop()
    NetworkHelpers.start(requests: [
      NetworkHelpers.stubHealthcheck(success: true, percyCLIHostname: "app-percy.cli", percyCLIPort: 5448),
      NetworkHelpers.stubPostComparison(success: true, percyCLIHostname: "app-percy.cli", percyCLIPort: 5448)
    ])

    // does not throw
    try percy.screenshot(name: "abc")

    // reset
    AppPercy.ignoreErrors = true
    AppPercy.percyCLIHostname = "percy.cli"
    AppPercy.percyCLIPort = 5338
  }
}
