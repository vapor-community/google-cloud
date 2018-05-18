//
//  StorageBucketList.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/18/18.
//

import Vapor

public struct GoogleStorageBucketList: GoogleCloudModel {
    public var kind: String
    public var nextPageToken: String
    public var items: [GoogleStorageBucket]
}
