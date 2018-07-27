//
//  StorageTests.swift
//  GoogleCloud
//
//  Created by Brian Hatfield on 7/18/18.
//

import Foundation
import XCTest

import Vapor

@testable import GoogleCloud

final class StorageTests: XCTestCase {
    var GCSProject: String?
    var CredentialFile: String?

    override func setUp() {
        super.setUp()

        let env = ProcessInfo.processInfo.environment

        // Because these tests actually hit Google Cloud Storage, you must configure your scheme to include
        // the following environment variables:
        // - STORAGE_TEST_PROJECT: your google cloud project name
        // - STORAGE_TEST_SERVICEACCOUNT: a path to a service account JSON file

        guard let project = env["STORAGE_TEST_PROJECT"] else {
            XCTFail("GCS project environment variable 'STORAGE_TEST_PROJECT' not configured")
            return
        }

        GCSProject = project

        guard let credentialFile = env["STORAGE_TEST_SERVICEACCOUNT"] else {
            XCTFail("GCS credentials environment variable 'STORAGE_TEST_SERVICEACCOUNT' not configured")
            return
        }

        CredentialFile = credentialFile
    }

    func testWithApplicationDefaultCredentials() throws {
        let app = try Application()
        let req = Request(using: app)
        let client = try req.client()

        let providerConfig = GoogleCloudConfig(project: GCSProject!)

        let storageClient = try GoogleCloudStorageClient(providerconfig: providerConfig, client: client)

        try storageClient.buckets.list().map({ buckets in
            guard let bucketList = buckets.items else {
                XCTFail("Buckets optional is nil")
                return
            }

            XCTAssert(bucketList.count > 0)
        }).catch({ err in
            XCTFail(err.localizedDescription)
        }).wait()
    }

    func testWithServiceAccountCredentials() throws {
        let app = try Application()
        let req = Request(using: app)
        let client = try req.client()

        let providerConfig = GoogleCloudConfig(project: GCSProject!, credentialFile: CredentialFile!)

        let storageClient = try GoogleCloudStorageClient(providerconfig: providerConfig, client: client)

        try storageClient.buckets.list().map({ buckets in
            guard let bucketList = buckets.items else {
                XCTFail("Buckets optional is nil")
                return
            }

            XCTAssert(bucketList.count > 0)
        }).catch({ err in
            XCTFail(err.localizedDescription)
        }).wait()
    }

    static var allTests = [
        ("testWithApplicationDefaultCredentials", testWithApplicationDefaultCredentials),
        ("testWithServiceAccountCredentials", testWithServiceAccountCredentials)
    ]
}
