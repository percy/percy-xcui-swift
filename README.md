# percy-xcui-swift
XCUI Swift SDK for App Percy

Note: Please check how to use SDK in the README inside `percy-xcui` folder.

# Development
This repo is devided into following parts.
- `percy-xcui` folder, which contains the base package for percy XCUI SDK.
- `xcui-sdk-test-app` contains a default swift iOS app
- `xcui-sdk-test-appUITests` contains tests for the package. The reason this package contain sdk tests is because `percy-xcui` is a standard swift package compilable to iOS and we could not add XCUI test files directly to the package tests [ it only supported XCTest files and failed execution of all UI actions ]. So we added a test app and XCUI tests against it which tests SDK functionality in context of XCUI tests [ similar to the end user ]

## Toolchain
- Formatter: `brew install swift-format` [ used along with vscode extenstion `apple-swift-format`]
- Linter: `brew install swiftlint` [ used along with vscode extenstion `SwiftLint`]

## Configuration
- `Percy CLI HostName and Port` - By default percy cli hostname is `percy.cli` and port is `5338`
    - Below is the code snippet to change this.
  ```
    AppPercy.percyCLIHostname = "app-percy.cli"
    AppPercy.percyCLIPort = 5448
    var percy = AppPercy()
  ``` 
