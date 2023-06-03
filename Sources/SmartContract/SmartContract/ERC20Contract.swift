//
//  ERC20Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct ERC20Contract: SmartContract {

    let contract = GenericSmartContract.ERC20
    var rpc: RpcApi?
    var address: String?
    
    public init() {
        self.rpc = nil
        self.address = nil
    }
    
    public init(rcp: RpcApi, address: String) {
        self.rpc = rcp
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
    
    public func approve() async throws -> Bool {
        try await runFunction("approve")
    }
    
    public func totalSupply() async throws -> BigUInt {
        try await runFunction("totalSupply")
    }
    
    public func transferFrom(from: EthereumAddress, to: EthereumAddress, value: BigUInt) async throws -> Bool {
        try await runFunction("transferFrom", params: from, to, value)
    }
    
    public func balanceOf(address: EthereumAddress) async throws -> BigUInt {
        try await runFunction("balanceOf", params: address)
    }
    
    public func transfer(to: EthereumAddress, value: BigUInt) async throws -> Bool {
        try await runFunction("transfer", params: to, value)
    }
    
    public func allowance(owner: EthereumAddress, spender: EthereumAddress) async throws -> BigUInt {
        try await runFunction("allowance", params: owner, spender)
    }
    
}
