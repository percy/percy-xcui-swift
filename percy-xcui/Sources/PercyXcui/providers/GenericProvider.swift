import Foundation
import UIKit

public class GenericProvider {
  let cliWrapper: CliWrapper

  var metadata: Metadata = Metadata(options: ScreenshotOptions())

  public init() {
    self.cliWrapper = CliWrapper()
  }

  public func screenshot(name: String, options: ScreenshotOptions) throws {
    self.metadata = Metadata(options: options)
    let tag: [String: Any] = getTag(options: options)
    let tiles: [Tile] = try captureTiles()
    let testCase: String? = options.testCase
    let labels: String? = options.labels
    let response: [String: Any] = try cliWrapper.postScreenshot(
      name: name,
      tag: tag,
      tiles: tiles,
      testCase: testCase,
      labels: labels
    )
    Log.info(
      msg: "Please check screenshot `\(name)` : \(response["link"] ?? "Error link not found")")
  }

  private func captureTiles() throws -> [Tile] {
    let statusbar: Int = metadata.statBarHeight()
    let navbar: Int = metadata.navBarHeight()
    let header: Int = 0
    let footer: Int = 0
    var array: [Tile] = []

    let content: String = try ScreenshotController().takeScreenshot()
    array.append(
      Tile(
        content: content, statusBarHeight: Int(statusbar), navBarHeight: navbar,
        headerHeight: header, footerHeight: footer, fullScreen: false))
    return array
  }

  private func getTag(options: ScreenshotOptions) -> [String: Any] {
    let jsonObject: [String: Any] = [
      "name": metadata.deviceName(),
      "osName": metadata.osName(),
      "osVersion": metadata.platformVersion(),
      "width": metadata.deviceScreenWidth(),
      "height": metadata.deviceScreenHeight(),
      "orientation": metadata.orientation()
    ]
    return jsonObject
  }
}
