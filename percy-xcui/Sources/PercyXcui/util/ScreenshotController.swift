import Foundation
#if canImport(UIKit)
  import UIKit
  import XCTest

  public class ScreenshotController: UIViewController {
    // swiftlint:disable:next unneeded_override
    public override func viewDidLoad() {
      super.viewDidLoad()
    }

    public func takeScreenshot() throws -> String {
      guard let imageData = XCUIScreen.main.screenshot().image.pngData() else {
        throw AppPercyError.screenshotError("Failed to take screenshot")
      }
      return imageData.base64EncodedString()
    }
  }
#else
  // Host (non-UIKit) build used only by the unit-test suite. `XCUIScreen` and
  // `UIViewController` are unavailable off-device, so the host shim throws the
  // same error type the iOS path raises on failure. iOS behaviour is unchanged.
  public class ScreenshotController {
    public init() {}

    public func takeScreenshot() throws -> String {
      throw AppPercyError.screenshotError("Screenshot capture requires the iOS runtime")
    }
  }
#endif
