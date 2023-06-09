//
//  RPC.swift
//  
//
//  Created by Yuri on 02.06.2023.
//

import Foundation
import SmartContract

public struct RPC: RpcApi {
    
    let url: URL
    
    public func call<Result: Decodable>(to: String, data: String) async throws -> Result {
        let request = JsonRpcRequest(
            method: "eth_call",
            params: ["to": to, "data": data]
        )
        return try await call(request)
    }
    
    func call<Result: Decodable, Request: Encodable>(_ data: Request) async throws -> Result {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(data)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonAnswer = try JSONDecoder().decode(JsonRpcResult<Result>.self, from: data)
        guard let result = jsonAnswer.result else {
            throw NSError(domain: "RPC", code: 0, userInfo: ["error": jsonAnswer.error?.value ?? ""])
        }
        return result
    }
    
}
