//
//  JsonRPC.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import AnyCodable

public struct JsonRpcRequest: Encodable {
    
    public var jsonrpc = "2.0"
    public let method: String
    public let params: AnyCodable
    public let id = 1
    
    public init(method: String, params: [String: Any]) {
        self.method = method
        self.params = AnyCodable([params, "latest"] as [Any])
    }
    
}

public struct JsonRpcResult<T: Decodable>: Decodable {
    
    public let jsonrpc: String
    public let result: T?
    public let error: AnyCodable?
    public let id: Int
    
}
