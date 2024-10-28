import Foundation
import Hippolyte

class NetworkHelpers {

  static func start(requests: [StubRequest]) {
    for request in requests {
      Hippolyte.shared.add(stubbedRequest: request)
    }
    Hippolyte.shared.start()
  }

  static func stubHealthcheck(
    success: Bool = true, percyCLIHostname: String = "percy.cli", percyCLIPort: Int = 5338
  ) -> StubRequest {
    let responseCode = success ? 204 : 500
    let response = StubResponse.Builder()
      .stubResponse(withStatusCode: responseCode)
      .build()
    // The request that will match this URL and return the stub response
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .GET, url: URL(string: "http://\(percyCLIHostname):\(percyCLIPort)/percy/healthcheck")!)
      .addResponse(response)
      .build()
    return request
  }

  static func stubPostComparison(
    success: Bool = true, percyCLIHostname: String = "percy.cli", percyCLIPort: Int = 5338
  ) -> StubRequest {
    let responseCode = success ? 200 : 500
    let response = StubResponse.Builder()
      .stubResponse(withStatusCode: responseCode)
      .addBody(Data("{\"link\": \"https://some-link\"}".utf8))
      .build()

    // The request that will match this URL and return the stub response
    let request = StubRequest.Builder()
      .stubRequest(withMethod: .POST, url: URL(string: "http://\(percyCLIHostname):\(percyCLIPort)/percy/comparison")!)
      .addResponse(response)
      .build()
    return request
  }

  static func stop() {
    Hippolyte.shared.stop()
  }
}
