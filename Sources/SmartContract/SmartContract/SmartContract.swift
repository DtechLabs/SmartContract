//
//  SmartContract.swift
//  
//
//  Created by Yuri on 03.06.2023.
//

import Foundation

public protocol SmartContract {
    
    var contract: GenericSmartContract { get }
    var rpc: RpcApi? { get set }
    var address: String? { get set }
    func function(_ name: String) throws -> SmartContractFunction
    
}

extension SmartContract {

    func runFunction<T>(_ functionName: String) async throws -> T {
        let function = try contract.function(functionName)
        let abi = try function.encode()
        let data = try await call(abi.hexString)
        
        guard let value = try function.decodeOutput(data)[0] as? T else {
            throw SmartContractError.invalidData(data)
        }
        return value
    }
    
    func runFunction<T>(_ functionName: String, params: Any...) async throws -> T {
        let function = try contract.function(functionName)
        let abi = try function.encode(params)
        let data = try await call(abi.hexString)
        
        guard let value = try function.decodeOutput(data)[0] as? T else {
            throw SmartContractError.invalidData(data)
        }
        return value
    }
    
    func call(_ abi: String) async throws -> String {
        guard let rpc = rpc, let address = address else {
            throw SmartContractError.contractOrRpcDidNotSet
        }
        return try await rpc.call(to: address, data: abi)
    }
    
    public func function(_ name: String) throws -> SmartContractFunction {
        try contract.function(name)
    }
    
    public func abi(_ functionName: String) throws -> Data {
        try contract.function(functionName).encode()
    }
    
    public func abi(_ functionName: String, params: Any...) throws -> String {
        try contract.function(functionName).encode(params).hexString
    }
    
    public func decode<T>(_ functionName: String, data: String) throws -> T {
        guard let value = try contract.function(functionName).decodeOutput(data)[0] as? T else {
            throw SmartContractError.invalidData(data)
        }
        return value
    }
    
}
