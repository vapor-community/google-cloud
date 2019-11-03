//
//  APIs.swift
//  
//
//  Created by Andrew Edwards on 11/2/19.
//

import Foundation

/// An enum that describes all the currently suported APIs.
/// New APIs that are supported should be added as a new case named after the API.
public enum GoogleCloudAPI: CaseIterable {
    /// The Cloud Storage API.
    case storage
}
