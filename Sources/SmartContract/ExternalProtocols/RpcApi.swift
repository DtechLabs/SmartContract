//
//  RpcApi.swift
//  
//
//  Created by Yuri on 02.06.2023.
//

import Foundation

public protocol RpcApi {
    
    func call<Result: Codable>(to: String, data: String) async throws -> Result
    
}
