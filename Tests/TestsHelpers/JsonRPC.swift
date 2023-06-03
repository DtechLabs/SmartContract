//
//  JsonRPC.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import AnyCodable

public struct JsonRpcRequest: Encodable {
    
    let jsonrpc = "2.0"
    let method: String
    let params: AnyCodable
    let id = 1
    
    init(method: String, params: [String: Any]) {
        self.method = method
        self.params = AnyCodable([params, "latest"] as [Any])
    }
    
}

public struct JsonRpcResult<T: Decodable>: Decodable {
    
    let jsonrpc: String
    let result: T?
    let error: AnyCodable?
    let id: Int
    
}
