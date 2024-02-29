import Foundation

public class Tile {
  let content: String
  let statusBarHeight: Int
  let navBarHeight: Int
  let headerHeight: Int
  let footerHeight: Int
  let fullScreen: Bool

  public init(
    content: String, statusBarHeight: Int, navBarHeight: Int, headerHeight: Int, footerHeight: Int,
    fullScreen: Bool
  ) {
    self.content = content
    self.statusBarHeight = statusBarHeight
    self.navBarHeight = navBarHeight
    self.headerHeight = headerHeight
    self.footerHeight = footerHeight
    self.fullScreen = fullScreen
  }

  public static func getTileJSON(tiles: [Tile]) -> Any {
    var tileJson: [[String: Any]] = []

    for tile: Tile in tiles {
      let jsonObject: [String: Any] = [
        "content": tile.content,
        "statusBarHeight": tile.statusBarHeight,
        "navBarHeight": tile.navBarHeight,
        "headerHeight": tile.headerHeight,
        "footerHeight": tile.footerHeight,
        "fullscreen": tile.fullScreen
      ]
      tileJson.append(jsonObject)
    }
//    let valid: Bool = JSONSerialization.isValidJSONObject(tileJson)
    return tileJson
  }
}
