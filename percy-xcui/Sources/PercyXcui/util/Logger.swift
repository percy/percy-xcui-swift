import Foundation

public class Log {
    public enum Level: String {
        case info
        case debug
        case error
    }

    static var logLevel: Level = .info

    static func info(msg: String) {
        logfmt(msg: msg)
    }

    static func debug(msg: String) {
        if logLevel != .debug {
            return
        }

        logfmt(msg: msg, level: .debug)
    }

    static func error(msg: String) {
        logfmt(msg: msg, level: .error)
    }

    static func logfmt(msg: String, level: Level = .info) {
        print(NSString(format: "[percy:sdk][%@] %@", level.rawValue, msg))
    }
}
