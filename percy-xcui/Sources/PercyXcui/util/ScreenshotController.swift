import Foundation
import UIKit
import XCTest

public class ScreenshotController: UIViewController {
  public func viewDidLoad() {
    super.viewDidLoad()
  }

  public func takeScreenshot() throws -> String {
    guard let imageData = XCUIScreen.main.screenshot().image.pngData() else {
      throw AppPercyError.screenshotError("Failed to take screenshot")
    }
    return imageData.base64EncodedString()
  }
}
