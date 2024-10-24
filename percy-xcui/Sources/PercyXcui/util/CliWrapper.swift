import Foundation

public class CliWrapper {
  // swiftlint:disable:next identifier_name
  var PERCY_SERVER_ADDRESS: String = "http://\(AppPercy.percyCLIHostname):\(AppPercy.percyCLIPort)"

  public func healthcheck() -> Bool {
    var ret: Bool = false
    let url: URL? = URL(string: PERCY_SERVER_ADDRESS + "/percy/healthcheck")
    guard let requestUrl: URL = url else { return false }

    var request: URLRequest = URLRequest(url: requestUrl)
    request.httpMethod = "GET"
    let sem: DispatchSemaphore = DispatchSemaphore.init(value: 0)

    let task: URLSessionDataTask = URLSession.shared.dataTask(
      with: request,
      completionHandler: { (_: Data?, response: URLResponse?, error: Error?) in
        defer { sem.signal() }
        if let error: Error = error {
          Log.error(msg: "Error took place \(error)")
          return
        }
        if let response: HTTPURLResponse = response as? HTTPURLResponse {
          Log.debug(msg: "Healthcheck statusCode: \(response.statusCode)")
          ret = true

          if let version: String = response.allHeaderFields["X-Percy-Core-Version"] as? String {
            let versionArr = version.components(separatedBy: ".")
            let majorVersion: Int = Int(versionArr[0]) ?? 0
            let minorVersion: Int = Int(versionArr[1]) ?? 0

            if majorVersion < 1 {
              Log.info(msg: "Unsupported Percy CLI version, \(version)")
              ret = false
            } else {
              if minorVersion < 24 {
                  Log.info(msg: "Percy CLI version, \(version) is not the minimum version required," +
                    "some features might not work as expected.")
              }
            }
          }
        }
      })
    task.resume()
    sem.wait()

    if ret == false {
      Log.info(msg: "Percy CLI is not running, disabling screenshots.")
    }

    return ret
  }

  // swiftlint:disable:next function_body_length
  public func postScreenshot(name: String, tag: [String: Any], tiles: [Tile], testCase: String, labels: String) throws -> [String:
    Any] {
    var ret: [String: Any] = [String: Any]()
    let url: URL = URL(string: PERCY_SERVER_ADDRESS + "/percy/comparison")!

    let parameters: [String: Any] = [
      "name": name,
      "tag": tag,
      "tiles": Tile.getTileJSON(tiles: tiles),
      "testCase": testCase,
      "labels": labels,
      "clientInfo": "XCUI", "environmentInfo": "XCUI"
    ]

    let session: URLSession = URLSession.shared
    let sem: DispatchSemaphore = DispatchSemaphore.init(value: 0)

    var request: URLRequest = URLRequest(url: url)
    request.httpMethod = "POST"

    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    do {
      request.httpBody = try JSONSerialization.data(
        withJSONObject: parameters, options: .prettyPrinted)
    } catch let error {
      Log.error(msg: error.localizedDescription)
      return ret
    }

    let task: URLSessionDataTask = session.dataTask(with: request) { data, response, error in
      defer { sem.signal() }
      if let error = error {
        Log.error(msg: "Post Request Error: \(error.localizedDescription)")
        return
      }

      guard let httpResponse: HTTPURLResponse = response as? HTTPURLResponse,
        (200...299).contains(httpResponse.statusCode)
      else {
        Log.error(msg: "Invalid Response received from the server")
        return
      }

      guard let responseData = data else {
        Log.error(msg: "nil Data received from the server")
        return
      }

      do {
        Log.debug(msg: "Comparison post response: " + String(decoding: responseData, as: UTF8.self))
        if let jsonResponse: [String: Any] = try JSONSerialization.jsonObject(
          with: responseData, options: .mutableContainers) as? [String: Any] {
          ret = jsonResponse
        } else {
          Log.error(msg: "data maybe corrupted or in wrong format")
          throw URLError(.badServerResponse)
        }
      } catch let error {
        Log.error(msg: error.localizedDescription)
      }
    }

    task.resume()
    sem.wait()

    if ret.isEmpty {
      throw AppPercyError.postScreenshotError("Failed to post screenshot")
    }

    return ret
  }
}
