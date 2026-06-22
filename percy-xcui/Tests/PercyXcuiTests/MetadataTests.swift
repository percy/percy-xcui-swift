import Foundation
import Testing

@testable import PercyXcui

// swiftlint:disable type_body_length
struct MetadataTests {
  // Allows overriding the resolved device name so the scale-dependent helpers
  // can be exercised deterministically on the host.
  final class MockMetadata: Metadata {
    var mockName = "iPhone 14 Pro"
    override func deviceName() -> String {
      return mockName
    }
  }

  @Test func osName() {
    #expect(Metadata().osName() == "iOS")
  }

  @Test func platformVersionIsNonEmptyMajor() {
    // On the host this resolves to the OS major version string; just assert it
    // is a parseable, non-empty value.
    let version = Metadata().platformVersion()
    #expect(!version.isEmpty)
    #expect(Int(version) != nil)
  }

  @Test func orientationDefaultsToPortrait() {
    #expect(Metadata().orientation() == "portrait")
  }

  @Test func screenScale() {
    // Host fallback is 1.
    #expect(Metadata().screenScale() >= 1)
  }

  @Test func navBarHeightDefault() {
    #expect(Metadata().navBarHeight() == 0)
  }

  @Test func navBarHeightFromOptions() {
    let options = ScreenshotOptions()
    options.navigationBarHeight = 100
    #expect(Metadata(options: options).navBarHeight() == 100)
  }

  @Test func statBarHeightFromOptions() {
    let options = ScreenshotOptions()
    options.statusBarHeight = 77
    #expect(Metadata(options: options).statBarHeight() == 77)
  }

  @Test func statBarHeightComputed() {
    let mock = MockMetadata()
    mock.mockName = "iPhone 14 Pro"
    #expect(mock.statBarHeight() == Int(CGFloat(54) * mock.screenScale()))
  }

  @Test func deviceScreenWidthComputed() {
    let mock = MockMetadata()
    mock.mockName = "iPhone 14 Pro"
    #expect(mock.deviceScreenWidth() == CGFloat(393) * mock.screenScale())
  }

  @Test func deviceScreenHeightComputed() {
    let mock = MockMetadata()
    mock.mockName = "iPhone 14 Pro"
    #expect(mock.deviceScreenHeight() == CGFloat(852) * mock.screenScale())
  }

  @Test func deviceNameResolvesViaMachineName() {
    // machineName() reads utsname; mapToDevice maps it. Either way it returns a
    // non-empty string on the host runner.
    #expect(!Metadata().deviceName().isEmpty)
  }

  @Test func machineNameNonEmpty() {
    #expect(!Metadata().machineName().isEmpty)
  }

  @Test func getDefaultStatusBarHeight() {
    let meta = Metadata()
    #expect(meta.getDefaultStatusBarHeight(forDevice: "iPhone X") == 44)
    #expect(meta.getDefaultStatusBarHeight(forDevice: "iPad Air") == 20)
    #expect(meta.getDefaultStatusBarHeight(forDevice: "unknown") == 44)
  }

  @Test func mapToDeviceStatusBarAllArms() {
    let meta = Metadata()
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 14 pro") == 54)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 14 pro max") == 54)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 14") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 14 plus") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iPhone 13") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 13 pro") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 13 pro max") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 12") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 12 pro") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 12 pro max") == 47)
    #expect(meta.mapToDeviceStatusBar(identifier: "iPhone 12 Mini") == 50)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 11") == 48)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 11 pro") == 44)
    #expect(meta.mapToDeviceStatusBar(identifier: "iphone 11 pro max") == 44)
    // default -> getDefaultStatusBarHeight
    #expect(meta.mapToDeviceStatusBar(identifier: "some ipad") == 20)
  }

  @Test func mapToDeviceWidthAllArms() {
    let meta = Metadata()
    #expect(meta.mapToDeviceWidth(identifier: "iphone 14 pro max") == 430)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 14 pro") == 393)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 14 plus") == 428)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 12 pro max") == 428)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 13 pro max") == 428)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 14") == 390)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 13 pro") == 390)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 13") == 390)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 13 mini") == 375)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 12 mini") == 375)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 11 pro") == 375)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 12 pro") == 390)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 12") == 390)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 11 pro max") == 418)
    #expect(meta.mapToDeviceWidth(identifier: "iphone 11") == 414)
    // default -> host fallback 0
    #expect(meta.mapToDeviceWidth(identifier: "unknown device") == 0)
  }

  @Test func mapToDeviceHeightAllArms() {
    let meta = Metadata()
    #expect(meta.mapToDeviceHeight(identifier: "iphone 14 pro max") == 932)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 14 pro") == 852)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 14 plus") == 926)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 12 pro max") == 926)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 13 pro max") == 926)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 14") == 844)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 13 pro") == 844)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 13") == 844)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 13 mini") == 812)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 12 mini") == 812)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 11 pro") == 812)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 12 pro") == 844)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 12") == 844)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 11 pro max") == 896)
    #expect(meta.mapToDeviceHeight(identifier: "iphone 11") == 896)
    // default -> host fallback 0
    #expect(meta.mapToDeviceHeight(identifier: "unknown device") == 0)
  }

  // swiftlint:disable:next function_body_length
  @Test func mapToDeviceAllArms() {
    let meta = Metadata()
    let expectations: [(String, String)] = [
      ("iPod5,1", "iPod touch (5th generation)"),
      ("iPod7,1", "iPod touch (6th generation)"),
      ("iPod9,1", "iPod touch (7th generation)"),
      ("iPhone3,1", "iPhone 4"),
      ("iPhone3,2", "iPhone 4"),
      ("iPhone3,3", "iPhone 4"),
      ("iPhone4,1", "iPhone 4s"),
      ("iPhone5,1", "iPhone 5"),
      ("iPhone5,2", "iPhone 5"),
      ("iPhone5,3", "iPhone 5c"),
      ("iPhone5,4", "iPhone 5c"),
      ("iPhone6,1", "iPhone 5s"),
      ("iPhone6,2", "iPhone 5s"),
      ("iPhone7,2", "iPhone 6"),
      ("iPhone7,1", "iPhone 6 Plus"),
      ("iPhone8,1", "iPhone 6s"),
      ("iPhone8,2", "iPhone 6s Plus"),
      ("iPhone9,1", "iPhone 7"),
      ("iPhone9,3", "iPhone 7"),
      ("iPhone9,2", "iPhone 7 Plus"),
      ("iPhone9,4", "iPhone 7 Plus"),
      ("iPhone10,1", "iPhone 8"),
      ("iPhone10,4", "iPhone 8"),
      ("iPhone10,2", "iPhone 8 Plus"),
      ("iPhone10,5", "iPhone 8 Plus"),
      ("iPhone10,3", "iPhone X"),
      ("iPhone10,6", "iPhone X"),
      ("iPhone11,2", "iPhone XS"),
      ("iPhone11,4", "iPhone XS Max"),
      ("iPhone11,6", "iPhone XS Max"),
      ("iPhone11,8", "iPhone XR"),
      ("iPhone12,1", "iPhone 11"),
      ("iPhone12,3", "iPhone 11 Pro"),
      ("iPhone12,5", "iPhone 11 Pro Max"),
      ("iPhone13,1", "iPhone 12 mini"),
      ("iPhone13,2", "iPhone 12"),
      ("iPhone13,3", "iPhone 12 Pro"),
      ("iPhone13,4", "iPhone 12 Pro Max"),
      ("iPhone14,4", "iPhone 13 mini"),
      ("iPhone14,5", "iPhone 13"),
      ("iPhone14,2", "iPhone 13 Pro"),
      ("iPhone14,3", "iPhone 13 Pro Max"),
      ("iPhone14,7", "iPhone 14"),
      ("iPhone14,8", "iPhone 14 Plus"),
      ("iPhone15,2", "iPhone 14 Pro"),
      ("iPhone15,3", "iPhone 14 Pro Max"),
      ("iPhone8,4", "iPhone SE"),
      ("iPhone12,8", "iPhone SE (2nd generation)"),
      ("iPhone14,6", "iPhone SE (3rd generation)"),
      ("iPad2,1", "iPad 2"),
      ("iPad2,2", "iPad 2"),
      ("iPad2,3", "iPad 2"),
      ("iPad2,4", "iPad 2"),
      ("iPad3,1", "iPad (3rd generation)"),
      ("iPad3,2", "iPad (3rd generation)"),
      ("iPad3,3", "iPad (3rd generation)"),
      ("iPad3,4", "iPad (4th generation)"),
      ("iPad3,5", "iPad (4th generation)"),
      ("iPad3,6", "iPad (4th generation)"),
      ("iPad6,11", "iPad (5th generation)"),
      ("iPad6,12", "iPad (5th generation)"),
      ("iPad7,5", "iPad (6th generation)"),
      ("iPad7,6", "iPad (6th generation)"),
      ("iPad7,11", "iPad (7th generation)"),
      ("iPad7,12", "iPad (7th generation)"),
      ("iPad11,6", "iPad (8th generation)"),
      ("iPad11,7", "iPad (8th generation)"),
      ("iPad12,1", "iPad (9th generation)"),
      ("iPad12,2", "iPad (9th generation)"),
      ("iPad13,18", "iPad (10th generation)"),
      ("iPad13,19", "iPad (10th generation)"),
      ("iPad4,1", "iPad Air"),
      ("iPad4,2", "iPad Air"),
      ("iPad4,3", "iPad Air"),
      ("iPad5,3", "iPad Air 2"),
      ("iPad5,4", "iPad Air 2"),
      ("iPad11,3", "iPad Air (3rd generation)"),
      ("iPad11,4", "iPad Air (3rd generation)"),
      ("iPad13,1", "iPad Air (4th generation)"),
      ("iPad13,2", "iPad Air (4th generation)"),
      ("iPad13,16", "iPad Air (5th generation)"),
      ("iPad13,17", "iPad Air (5th generation)"),
      ("iPad2,5", "iPad mini"),
      ("iPad2,6", "iPad mini"),
      ("iPad2,7", "iPad mini"),
      ("iPad4,4", "iPad mini 2"),
      ("iPad4,5", "iPad mini 2"),
      ("iPad4,6", "iPad mini 2"),
      ("iPad4,7", "iPad mini 3"),
      ("iPad4,8", "iPad mini 3"),
      ("iPad4,9", "iPad mini 3"),
      ("iPad5,1", "iPad mini 4"),
      ("iPad5,2", "iPad mini 4"),
      ("iPad11,1", "iPad mini (5th generation)"),
      ("iPad11,2", "iPad mini (5th generation)"),
      ("iPad14,1", "iPad mini (6th generation)"),
      ("iPad14,2", "iPad mini (6th generation)"),
      ("iPad6,3", "iPad Pro (9.7-inch)"),
      ("iPad6,4", "iPad Pro (9.7-inch)"),
      ("iPad7,3", "iPad Pro (10.5-inch)"),
      ("iPad7,4", "iPad Pro (10.5-inch)"),
      ("iPad8,1", "iPad Pro (11-inch) (1st generation)"),
      ("iPad8,2", "iPad Pro (11-inch) (1st generation)"),
      ("iPad8,3", "iPad Pro (11-inch) (1st generation)"),
      ("iPad8,4", "iPad Pro (11-inch) (1st generation)"),
      ("iPad8,9", "iPad Pro (11-inch) (2nd generation)"),
      ("iPad8,10", "iPad Pro (11-inch) (2nd generation)"),
      ("iPad13,4", "iPad Pro (11-inch) (3rd generation)"),
      ("iPad13,5", "iPad Pro (11-inch) (3rd generation)"),
      ("iPad13,6", "iPad Pro (11-inch) (3rd generation)"),
      ("iPad13,7", "iPad Pro (11-inch) (3rd generation)"),
      ("iPad14,3", "iPad Pro (11-inch) (4th generation)"),
      ("iPad14,4", "iPad Pro (11-inch) (4th generation)"),
      ("iPad6,7", "iPad Pro (12.9-inch) (1st generation)"),
      ("iPad6,8", "iPad Pro (12.9-inch) (1st generation)"),
      ("iPad7,1", "iPad Pro (12.9-inch) (2nd generation)"),
      ("iPad7,2", "iPad Pro (12.9-inch) (2nd generation)"),
      ("iPad8,5", "iPad Pro (12.9-inch) (3rd generation)"),
      ("iPad8,6", "iPad Pro (12.9-inch) (3rd generation)"),
      ("iPad8,7", "iPad Pro (12.9-inch) (3rd generation)"),
      ("iPad8,8", "iPad Pro (12.9-inch) (3rd generation)"),
      ("iPad8,11", "iPad Pro (12.9-inch) (4th generation)"),
      ("iPad8,12", "iPad Pro (12.9-inch) (4th generation)"),
      ("iPad13,8", "iPad Pro (12.9-inch) (5th generation)"),
      ("iPad13,9", "iPad Pro (12.9-inch) (5th generation)"),
      ("iPad13,10", "iPad Pro (12.9-inch) (5th generation)"),
      ("iPad13,11", "iPad Pro (12.9-inch) (5th generation)"),
      ("iPad14,5", "iPad Pro (12.9-inch) (6th generation)"),
      ("iPad14,6", "iPad Pro (12.9-inch) (6th generation)"),
      ("AppleTV5,3", "Apple TV"),
      ("AppleTV6,2", "Apple TV 4K"),
      ("AudioAccessory1,1", "HomePod"),
      ("AudioAccessory5,1", "HomePod mini"),
      ("totally-unknown", "totally-unknown")
    ]
    for (identifier, expected) in expectations {
      #expect(meta.mapToDevice(identifier: identifier) == expected, "for \(identifier)")
    }
  }

  @Test func mapToDeviceSimulatorArm() {
    let meta = Metadata()
    // The i386/x86_64/arm64 arm recurses with SIMULATOR_MODEL_IDENTIFIER
    // (unset in tests -> "iOS" -> default arm). Result is prefixed.
    for arch in ["i386", "x86_64", "arm64"] {
      #expect(meta.mapToDevice(identifier: arch).hasPrefix("Simulator "))
    }
  }
}
// swiftlint:enable type_body_length
