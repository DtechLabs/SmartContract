//
//  GenericRpcNode.swift
//  
//
//  Created by Yuri on 14.06.2023.
//

import Foundation

public class GenericRpcNode: RpcApi {
    
    public func call<Result>(to: String, data: String) async throws -> Result where Result : Decodable, Result : Encodable {
        throw NSError()
    }
    
    public func call(to: String, data: String) async throws {
        throw NSError()
    }
    
}
