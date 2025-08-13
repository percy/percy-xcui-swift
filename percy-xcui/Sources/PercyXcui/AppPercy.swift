import Foundation

public class AppPercy {
    // global config options
    public static var ignoreErrors = true
    public static var percyCLIHostname = "percy.cli"
    public static var percyCLIPort = 5338
    public static var allowedDevices = [String]()
    // swiftlint:disable:next identifier_name
    static var _allowedDevicesMessageShown: Bool = false

    public func setLogLevel(level: Log.Level = .info) {
        Log.logLevel = level
    }

    let cliWrapper: CliWrapper
    var isPercyEnabled: Bool = false

    public init(logLevel: Log.Level = .info) {
        self.cliWrapper = CliWrapper()
        setLogLevel(level: logLevel)
        healthcheck()
    }

    public func healthcheck() {
        self.isPercyEnabled = cliWrapper.healthcheck()
    }

    public func screenshot(name: String, options: ScreenshotOptions = ScreenshotOptions()) throws {
        guard isPercyEnabled else {
            if !AppPercy.ignoreErrors {
                throw AppPercyError.percyNotEnabled
            }
            return
        }
        guard isDeviceAllowed() else {
            if !AppPercy.ignoreErrors {
                throw AppPercyError.deviceNotAllowed
            }
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

    @available(iOS 15.0, *)
    public func stop() async {
        try? await cliWrapper.stop()
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
