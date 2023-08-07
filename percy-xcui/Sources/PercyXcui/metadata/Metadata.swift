import Foundation
import UIKit
import XCTest

internal class Metadata {
  var options: ScreenshotOptions

  init(options: ScreenshotOptions = ScreenshotOptions()) {
    self.options = options
  }

  public func osName() -> String {
    return "iOS"
  }

  public func platformVersion() -> String {
    return String(UIDevice.current.systemVersion.split(separator: ".").first ?? "")
  }

  public func orientation() -> String {
    if XCUIDevice.shared.orientation.isLandscape {
      return "landscape"
    }
    // Note: we return default portait as sometimes orientation is unknown/flat as well
    return "portrait"
  }

  public func deviceScreenWidth() -> CGFloat {
    return CGFloat(mapToDeviceWidth(identifier: deviceName().lowercased())) * UIScreen.main.scale
  }

  public func deviceScreenHeight() -> CGFloat {
    return CGFloat(mapToDeviceHeight(identifier: deviceName().lowercased())) * UIScreen.main.scale
  }

  public func statBarHeight() -> Int {
    if options.statusBarHeight != -1 {
      return options.statusBarHeight
    }
    return Int(CGFloat(mapToDeviceStatusBar(identifier: deviceName().lowercased())) * UIScreen.main.scale)
  }

  public func navBarHeight() -> Int {
    if options.navigationBarHeight != -1 {
      return options.navigationBarHeight
    }
    return 0
  }

  public func deviceName() -> String {
    return mapToDevice(identifier: machineName())
  }

  func machineName() -> String {
    var systemInfo = utsname()
    uname(&systemInfo)
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    return machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
  }

  func getDefaultStatusBarHeight(forDevice device: String) -> Int {
    if device.lowercased().contains("iphone") {
      return 44 // Default status bar height for iPhone
    } else if device.lowercased().contains("ipad") {
      return 20 // Default status bar height for iPad
    } else {
      return 44 // Default status bar height for unknown devices
    }
  }

  // swiftlint:disable:next cyclomatic_complexity function_body_length
  func mapToDevice(identifier: String) -> String {
    #if os(iOS)
      switch identifier {
      case "iPod5,1": return "iPod touch (5th generation)"
      case "iPod7,1": return "iPod touch (6th generation)"
      case "iPod9,1": return "iPod touch (7th generation)"
      case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
      case "iPhone4,1": return "iPhone 4s"
      case "iPhone5,1", "iPhone5,2": return "iPhone 5"
      case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
      case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
      case "iPhone7,2": return "iPhone 6"
      case "iPhone7,1": return "iPhone 6 Plus"
      case "iPhone8,1": return "iPhone 6s"
      case "iPhone8,2": return "iPhone 6s Plus"
      case "iPhone9,1", "iPhone9,3": return "iPhone 7"
      case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
      case "iPhone10,1", "iPhone10,4": return "iPhone 8"
      case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
      case "iPhone10,3", "iPhone10,6": return "iPhone X"
      case "iPhone11,2": return "iPhone XS"
      case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
      case "iPhone11,8": return "iPhone XR"
      case "iPhone12,1": return "iPhone 11"
      case "iPhone12,3": return "iPhone 11 Pro"
      case "iPhone12,5": return "iPhone 11 Pro Max"
      case "iPhone13,1": return "iPhone 12 mini"
      case "iPhone13,2": return "iPhone 12"
      case "iPhone13,3": return "iPhone 12 Pro"
      case "iPhone13,4": return "iPhone 12 Pro Max"
      case "iPhone14,4": return "iPhone 13 mini"
      case "iPhone14,5": return "iPhone 13"
      case "iPhone14,2": return "iPhone 13 Pro"
      case "iPhone14,3": return "iPhone 13 Pro Max"
      case "iPhone14,7": return "iPhone 14"
      case "iPhone14,8": return "iPhone 14 Plus"
      case "iPhone15,2": return "iPhone 14 Pro"
      case "iPhone15,3": return "iPhone 14 Pro Max"
      case "iPhone8,4": return "iPhone SE"
      case "iPhone12,8": return "iPhone SE (2nd generation)"
      case "iPhone14,6": return "iPhone SE (3rd generation)"
      case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
      case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3rd generation)"
      case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th generation)"
      case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
      case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
      case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
      case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
      case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
      case "iPad13,18", "iPad13,19": return "iPad (10th generation)"
      case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
      case "iPad5,3", "iPad5,4": return "iPad Air 2"
      case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
      case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
      case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
      case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad mini"
      case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad mini 2"
      case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad mini 3"
      case "iPad5,1", "iPad5,2": return "iPad mini 4"
      case "iPad11,1", "iPad11,2": return "iPad mini (5th generation)"
      case "iPad14,1", "iPad14,2": return "iPad mini (6th generation)"
      case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
      case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
      case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch) (1st generation)"
      case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch) (2nd generation)"
      case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7":
        return "iPad Pro (11-inch) (3rd generation)"
      case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch) (4th generation)"
      case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch) (1st generation)"
      case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
      case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":
        return "iPad Pro (12.9-inch) (3rd generation)"
      case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch) (4th generation)"
      case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11":
        return "iPad Pro (12.9-inch) (5th generation)"
      case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch) (6th generation)"
      case "AppleTV5,3": return "Apple TV"
      case "AppleTV6,2": return "Apple TV 4K"
      case "AudioAccessory1,1": return "HomePod"
      case "AudioAccessory5,1": return "HomePod mini"
      case "i386", "x86_64", "arm64":
        return
          "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
      default: return identifier
      }
    #elseif os(tvOS)
      switch identifier {
      case "AppleTV5,3": return "Apple TV 4"
      case "AppleTV6,2": return "Apple TV 4K"
      case "i386", "x86_64":
        return
          "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
      default: return identifier
      }
    #endif
  }

  func mapToDeviceStatusBar(identifier: String) -> Int {
    switch identifier {
    case "iphone 14 pro", "iphone 14 pro max": return 54
    case "iphone 14", "iphone 14 plus": return 47
    case "iPhone 13", "iphone 13 pro", "iphone 13 pro max": return 47
    case "iphone 12", "iphone 12 pro", "iphone 12 pro max": return 47
    case "iPhone 12 Mini": return 50
    case "iphone 11": return 48
    case "iphone 11 pro", "iphone 11 pro max": return 44
    default: return getDefaultStatusBarHeight(forDevice: identifier)
    }
  }

  func mapToDeviceWidth(identifier: String) -> Int {
    switch identifier {
    case "iphone 14 pro max": return 430
    case "iphone 14 pro": return 393
    case "iphone 14 plus", "iphone 12 pro max", "iphone 13 pro max": return 428
    case "iphone 14", "iphone 13 pro", "iphone 13": return 390
    case "iphone 13 mini", "iphone 12 mini", "iphone 11 pro": return 375
    case "iphone 12 pro", "iphone 12": return 390
    case "iphone 11 pro max": return 418
    case "iphone 11": return 414
    default: return Int(UIScreen.main.bounds.width)
    }
  }

  func mapToDeviceHeight(identifier: String) -> Int {
    switch identifier {
    case "iphone 14 pro max": return 932
    case "iphone 14 pro": return 852
    case "iphone 14 plus", "iphone 12 pro max", "iphone 13 pro max": return 926
    case "iphone 14", "iphone 13 pro", "iphone 13": return 844
    case "iphone 13 mini", "iphone 12 mini", "iphone 11 pro": return 812
    case "iphone 12 pro", "iphone 12": return 844
    case "iphone 11 pro max", "iphone 11": return 896
    default: return Int(UIScreen.main.bounds.height)
    }
  }
}
