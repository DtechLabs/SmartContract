//
//  RpcApi.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import AnyCodable

public enum RpcApiError: Error {
    
    case networkError(URLResponse)
    case nodeError(AnyCodable?)
    
}

public protocol RpcApi {
    
    func call<Result: Codable>(to: String, data: Data) async throws -> Result
    func call(to: String, data: Data) async throws
    
}
