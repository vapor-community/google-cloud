//
//  Extensions.swift
//  GoogleCloudProvider
//
//  Created by Andrew Edwards on 4/21/18.
//

import Vapor

public protocol GoogleCloudModel: Content {
    func toEncodedBody() throws -> String
}

extension GoogleCloudModel {
    public func toEncodedBody() throws -> String {
        return try JSONEncoder().encode(self).convert(to: String.self)
    }
}

public struct AnyDecodable: Decodable {
    public var value: Any
    
    private struct CodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int?
        init?(intValue: Int) {
            self.stringValue = "\(intValue)"
            self.intValue = intValue
        }
        init?(stringValue: String) { self.stringValue = stringValue }
    }
    
    public init(from decoder: Decoder) throws {
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            var result = [String: Any]()
            try container.allKeys.forEach { (key) throws in
                result[key.stringValue] = try container.decode(AnyDecodable.self, forKey: key).value
            }
            value = result
        } else if var container = try? decoder.unkeyedContainer() {
            var result = [Any]()
            while !container.isAtEnd {
                result.append(try container.decode(AnyDecodable.self).value)
            }
            value = result
        } else if let container = try? decoder.singleValueContainer() {
            if let intVal = try? container.decode(Int.self) {
                value = intVal
            } else if let doubleVal = try? container.decode(Double.self) {
                value = doubleVal
            } else if let boolVal = try? container.decode(Bool.self) {
                value = boolVal
            } else if let stringVal = try? container.decode(String.self) {
                value = stringVal
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "the container contains nothing serialisable")
            }
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not serialise"))
        }
    }
}

extension Dictionary {
    
    var queryParameters: String {
        guard let me = self as? [String: Any] else
        { return "" }
        return query(parameters: me)
    }
    
    func query(parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        
        for key in parameters.keys {
            let value = parameters[key]!
            components += queryComponents(key: key, value)
        }
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }
    
    public func queryComponents(key: String, _ value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(key: "\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [Any] {
            for i in 0..<array.count {
                components += queryComponents(key: "\(key)[\(i)]", array[i])
            }
        } else {
            components.append((key, "\(value)"))
        }
        
        return components
    }
}
