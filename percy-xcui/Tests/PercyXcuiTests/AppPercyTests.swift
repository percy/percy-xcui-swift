import Foundation
import Testing

@testable import PercyXcui

/// Serialized: these tests mutate `AppPercy`'s shared static config and the
/// registered `URLProtocol` stub.
@Suite(.serialized)
struct AppPercyTests {
  init() {
    StubURLProtocol.register()
    StubURLProtocol.reset()
    Log.logLevel = "debug"
    resetConfig()
  }

  private func resetConfig() {
    AppPercy.ignoreErrors = true
    AppPercy.allowedDevices = []
    AppPercy._allowedDevicesMessageShown = false
    AppPercy.percyCLIHostname = "percy.cli"
    AppPercy.percyCLIPort = 5338
  }

  private func teardown() {
    StubURLProtocol.unregister()
    resetConfig()
  }

  private func enableHealthcheck() {
    StubURLProtocol.stubs["/percy/healthcheck"] = .init(
      statusCode: 204, headers: [:], body: nil, error: nil)
  }

  @Test func setLogLevel() {
    defer { teardown() }
    let percy = AppPercy()
    percy.setLogLevel(level: "error")
    #expect(Log.logLevel == "error")
    percy.setLogLevel()
    #expect(Log.logLevel == "info")
  }

  @Test func screenshotDisabledWhenCLINotRunning() throws {
    defer { teardown() }
    // No healthcheck stub -> connection fails -> isPercyEnabled false ->
    // screenshot() returns early without touching the provider.
    let percy = AppPercy()
    #expect(percy.isPercyEnabled == false)
    try percy.screenshot(name: "abc")
  }

  @Test func screenshotEnabledSwallowsErrorByDefault() throws {
    defer { teardown() }
    enableHealthcheck()
    let percy = AppPercy()
    #expect(percy.isPercyEnabled == true)
    // Host ScreenshotController throws; ignoreErrors defaults to true so this
    // is logged and swallowed (no rethrow).
    try percy.screenshot(name: "abc")
  }

  @Test func screenshotEnabledRethrowsWhenIgnoreErrorsFalse() {
    defer { teardown() }
    enableHealthcheck()
    let percy = AppPercy()
    AppPercy.ignoreErrors = false
    #expect(throws: AppPercyError.self) {
      try percy.screenshot(name: "abc")
    }
  }

  @Test func screenshotSkippedWhenDeviceNotAllowed() throws {
    defer { teardown() }
    enableHealthcheck()
    let percy = AppPercy()
    AppPercy.ignoreErrors = false
    AppPercy.allowedDevices = ["Definitely Not This Device"]
    // isDeviceAllowed() returns false -> screenshot returns early, provider
    // never runs, so no error is thrown even with ignoreErrors=false.
    try percy.screenshot(name: "abc")
    // Second call exercises the already-shown branch (message not re-logged).
    try percy.screenshot(name: "abc")
    #expect(AppPercy._allowedDevicesMessageShown == true)
  }

  @Test func screenshotAllowedWhenDeviceInAllowedList() throws {
    defer { teardown() }
    enableHealthcheck()
    let percy = AppPercy()
    // Add the current device to the allowed list so isDeviceAllowed() == true.
    AppPercy.allowedDevices = [Metadata().deviceName()]
    // Reaches the provider (which throws on host); default ignoreErrors swallows.
    try percy.screenshot(name: "abc")
  }
}
