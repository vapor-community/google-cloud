import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(GoogleCloudTests.allTests),
        testCase(CredentialTests.allTests),
    ]
}
#endif
