import Foundation

enum AppPercyError: Error {
    case screenshotError(String)
    case postScreenshotError(String)
    case percyNotEnabled
    case deviceNotAllowed
}
