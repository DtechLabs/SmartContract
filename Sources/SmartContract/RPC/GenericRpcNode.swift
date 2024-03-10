//
//  GenericRpcNode.swift
//  
//
//  Created by Yuri on 14.06.2023.
//

import Foundation

public class GenericRpcNode: RpcApi {
    
    public let url: URL
    public static let polygon = GenericRpcNode(URL(string: "https://polygon-rpc.com")!)
    public static let ethereum = GenericRpcNode(URL(string: "https://rpc.payload.de")!)
    
    public init(_ url: URL) {
        self.url = url
    }
    
    public func call<Result>(to: String, data: Data) async throws -> Result where Result : Decodable, Result : Encodable {
        let request = JsonRpcRequest(
            method: "eth_call",
            params: ["to": to, "data": data.hexString]
        )
        return try await call(request)
    }
    
    public func call(to: String, data: Data) async throws {
        let callData = JsonRpcRequest(
            method: "eth_call",
            params: ["to": to, "data": data.hexString]
        )
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(callData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonAnswer = try JSONDecoder().decode(JsonRpcResult<Bool>.self, from: data)
        guard jsonAnswer.result != nil else {
            throw RpcApiError.nodeError(jsonAnswer.error)
        }
    }
    
    public func call<Result: Decodable, Request: Encodable>(_ data: Request) async throws -> Result {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(data)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else {
            throw RpcApiError.networkError(urlResponse)
        }
        
        let jsonAnswer = try JSONDecoder().decode(JsonRpcResult<Result>.self, from: data)
        guard let result = jsonAnswer.result else {
            throw RpcApiError.nodeError(jsonAnswer.error)
        }
        return result
    }
    
}
