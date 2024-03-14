import Foundation

public class AppPercy {
  // global config options
  static var ignoreErrors = true
  static var percyCLIHostname = "percy.cli"
  static var percyCLIPort = 5338
  static var allowedDevices = [String]()
  // swiftlint:disable:next identifier_name
  static var _allowedDevicesMessageShown: Bool = false

  public func setLogLevel(level: String = "info") {
    Log.logLevel = level
  }

  let cliWrapper: CliWrapper
  var isPercyEnabled: Bool

  public init() {
    self.cliWrapper = CliWrapper()
    self.isPercyEnabled = cliWrapper.healthcheck()
  }

  public func screenshot(name: String, options: ScreenshotOptions = ScreenshotOptions()) throws {
    if !isPercyEnabled || !isDeviceAllowed() {
      return
    }

    let provider: GenericProvider = GenericProvider()
    do {
      try provider.screenshot(name: name, options: options)
    } catch let error {
      Log.error(msg: "[\(name)] Error while capturing screenshot : \(error)")
      if !AppPercy.ignoreErrors {
        throw error
      }
    }
  }

  private func isDeviceAllowed() -> Bool {
    if AppPercy.allowedDevices.isEmpty {
      return true
    }

    let meta: Metadata = Metadata()
    if AppPercy.allowedDevices.contains(meta.deviceName()) {
      return true
    }

    if !AppPercy._allowedDevicesMessageShown {
      Log.info(
        msg: "`\(meta.deviceName())` is not included in"
          + "the allowedDevices list. Ignoring screenshot commands.")
    }
    AppPercy._allowedDevicesMessageShown = true
    return false
  }
}
