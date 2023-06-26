//
//  ERC20Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct ERC20Contract: SmartContract {

    public let contract = GenericSmartContract.ERC20
    public var rpc: RpcApi?
    public var address: String?
    
    public init() {
        self.rpc = nil
        self.address = nil
    }
    
    public init(rpc: RpcApi, address: String) {
        self.rpc = rpc
        self.address = address
    }
    
    public func name() async throws -> String {
        try await runFunction("name")
    }
    
    public func symbols() async throws -> String {
        try await runFunction("symbol")
    }
    
    public func decimals() async throws -> BigUInt {
        try await runFunction("decimals")
    }
    
    public func approve(spender: String, value: BigUInt) async throws -> Bool {
        guard let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("approve", params: spender, value)
    }
    
    public func totalSupply() async throws -> BigUInt {
        try await runFunction("totalSupply")
    }
    
    @discardableResult
    public func transferFrom(from: String, to: String, value: BigUInt) async throws -> Bool {
        guard let from = EthereumAddress(from), let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("transferFrom", params: from, to, value)
    }
    
    public func balanceOf(address: String) async throws -> BigUInt {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("balanceOf", params: address)
    }
    
    @discardableResult
    public func transfer(to: String, value: BigUInt) async throws -> Bool {
        guard let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("transfer", params: to, value)
    }
    
    public func allowance(owner: String, spender: String) async throws -> BigUInt {
        guard let owner = EthereumAddress(owner), let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("allowance", params: owner, spender)
    }
    
}