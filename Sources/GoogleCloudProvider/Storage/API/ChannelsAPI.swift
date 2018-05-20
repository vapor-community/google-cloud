//
//  ChannelsAPI.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 5/19/18.
//

import Vapor

public protocol ChannelsAPI {
    func stop(channelId: String, resourceId: String, queryParameters: [String: String]?) throws -> Future<EmptyResponse>
}

public class GoogleChannelsAPI: ChannelsAPI {
    let endpoint = "https://www.googleapis.com/storage/v1/channels"
    let request: GoogleCloudStorageRequest
    
    init(request: GoogleCloudStorageRequest) {
        self.request = request
    }
    
    public func stop(channelId: String, resourceId: String, queryParameters: [String: String]? = nil) throws -> Future<EmptyResponse> {
        var queryParams = ""
        if let queryParameters = queryParameters {
            queryParams = queryParameters.queryParameters
        }
        
        let requestBody = try JSONEncoder().encode(["id": channelId, "resourceid": resourceId]).convert(to: String.self)
        
        return try request.send(method: .POST, path: "\(endpoint)/stop)", query: queryParams, body: requestBody)
    }
}
