//
//  ERC20Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct ERC20Contract {

    public let contract = GenericSmartContract.ERC20
    
    public init(rpc: RpcApi, address: String) {
        contract.rpc = rpc
        contract.address = address
    }
    
    public func name() async throws -> String {
        try await contract("name").value as! String
    }
    
    public func symbols() async throws -> String {
        try await contract("symbol").value as! String
    }
    
    public func decimals() async throws -> BigUInt {
        try await contract("decimals").value as! BigUInt
    }
    
    public func approve(spender: String, value: BigUInt) async throws -> Bool {
        guard let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("approve", spender, value).value as! Bool
    }
    
    public func totalSupply() async throws -> BigUInt {
        try await contract("totalSupply").value as! BigUInt
    }
    
    @discardableResult
    public func transferFrom(from: String, to: String, value: BigUInt) async throws -> Bool {
        guard let from = EthereumAddress(from), let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("transferFrom", from, to, value).value as! Bool
    }
    
    public func balanceOf(address: String) async throws -> BigUInt {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("balanceOf", address).value as! BigUInt
    }
    
    @discardableResult
    public func transfer(to: String, value: BigUInt) async throws -> Bool {
        guard let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("transfer", to, value).value as! Bool
    }
    
    public func allowance(owner: String, spender: String) async throws -> BigUInt {
        guard let owner = EthereumAddress(owner), let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("allowance", owner, spender).value as! BigUInt
    }

}
