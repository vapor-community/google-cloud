//
//  CredentialTests.swift
//  Async
//
//  Created by Brian Hatfield on 7/17/18.
//

import Foundation
import XCTest

@testable import GoogleCloudProvider

final class CredentialTests: XCTestCase {
    func testLoadApplicationDefaultCredentials() throws {
        let expandedPath = NSString(string: "~/.config/gcloud/application_default_credentials.json").expandingTildeInPath

        XCTAssertNoThrow(try ApplicationDefaultCredentials(fromFile: expandedPath))

        let creds = try ApplicationDefaultCredentials(fromFile: expandedPath)

        XCTAssert(creds.type == "authorized_user")
    }

    func testLoadServiceAccountCredentials() throws {
        let expandedPath = NSString(string: "~/Documents/misc/test-service-account.json").expandingTildeInPath

        XCTAssertNoThrow(try ServiceAccountCredentials(fromFile: expandedPath))

        let creds = try ServiceAccountCredentials(fromFile: expandedPath)

        XCTAssert(creds.type == "service_account")
    }

    static var allTests = [
        ("testLoadApplicationDefaultCredentials", testLoadApplicationDefaultCredentials),
        ("testLoadServiceAccount", testLoadServiceAccountCredentials)
    ]
}
