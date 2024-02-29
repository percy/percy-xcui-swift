import XCTest

@testable import PercyXcui

final class MetadataTests: XCTestCase {
  var meta: Metadata = Metadata()
  
  class MockMetadata: Metadata {
    var mockName: String = "iPhone 14 Pro"
    override func deviceName() -> String {
      return mockName
    }
  }
  
  override func setUp() {
    meta = Metadata()
  }
  
  func testOsName() throws {
    XCTAssertEqual(meta.osName(), "iOS")
  }
  
  func testPlatformVersion() throws {
    XCTAssertEqual(meta.platformVersion(), String(UIDevice.current.systemVersion.split(separator: ".").first ?? ""))
  }
  
  func testOrientation() throws {
    XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
    XCTAssertEqual(XCUIDevice.shared.orientation.isPortrait, true)
    
    XCTAssertEqual(meta.orientation(), "portrait")
    
    XCUIDevice.shared.orientation = UIDeviceOrientation.landscapeLeft
    XCTAssertEqual(meta.orientation(), "landscape")
    
    // reset
    XCUIDevice.shared.orientation = UIDeviceOrientation.portrait
  }
  
  func testDeviceScreenWidth() throws {
    XCTAssertEqual(meta.deviceScreenWidth(), UIScreen.main.bounds.width * UIScreen.main.scale)
  }
  
  func testDeviceScreenHeight() throws {
    let mockMetadata = MockMetadata()
    mockMetadata.mockName = "iPhone 14 Pro"
    XCTAssertEqual(mockMetadata.deviceScreenHeight(), CGFloat(852 * Int(UIScreen.main.scale)))
  }
  
  func testDeviceScreenWidth2() throws {
    let mockMetadata = MockMetadata()
    mockMetadata.mockName = "iPhone 14 Pro"
    XCTAssertEqual(mockMetadata.deviceScreenWidth(), CGFloat(393 * Int(UIScreen.main.scale)))
  }
  
  func testStatusBarHeight() throws {
    let mockMetadata = MockMetadata()
    mockMetadata.mockName = "iPhone 14 Pro"
    XCTAssertEqual(mockMetadata.statBarHeight(), 54 * Int(UIScreen.main.scale))
    // with options set
    let options = ScreenshotOptions()
    options.statusBarHeight = 100
    meta = Metadata(options: options)
    XCTAssertEqual(meta.statBarHeight(), options.statusBarHeight)
  }
  
  func testNavigationBarHeight() throws {
    XCTAssertEqual(meta.navBarHeight(), 0)
    
    // with options set
    let options = ScreenshotOptions()
    options.navigationBarHeight = 100
    meta = Metadata(options: options)
    XCTAssertEqual(meta.navBarHeight(), options.navigationBarHeight)
  }
  
  func testDeviceName() throws {
    XCTAssertTrue(meta.deviceName().contains("iPhone"))
  }
  
  func testMapToDeviceHeight() throws {
    XCTAssertEqual(meta.mapToDeviceHeight(identifier: "iphone 14 pro max"), 932)
  }
  
  func testMapToDeviceWidth() throws {
    XCTAssertEqual(meta.mapToDeviceWidth(identifier: "iphone 14 pro max"), 430)
  }
  
  func testMapToDeviceStatusBar() throws {
    XCTAssertEqual(meta.mapToDeviceWidth(identifier: "iphone 14 pro max"), 54)
  }
  
  func testGetDefaultStatusBarHeight() throws {
    XCTAssertEqual(meta.getDefaultStatusBarHeight(forDevice: "ipad"), 20)
    XCTAssertEqual(meta.getDefaultStatusBarHeight(forDevice: "iphone"), 44)
    XCTAssertEqual(meta.getDefaultStatusBarHeight(forDevice: "itest"), 44)
  }
}
