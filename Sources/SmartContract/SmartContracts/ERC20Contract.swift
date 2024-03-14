//
//  ERC20Contract.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 16.08.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
//

import Foundation
import BigInt

/// The `ERC20Contract` struct provides a Swift interface for interacting with an ERC20 token smart contract on the Ethereum blockchain.
/// It utilizes a ``GenericSmartContract`` instance configured for ERC20 interactions, simplifying the process of calling standard ERC20 functions.
///
/// The struct is designed to be used with `async/await` syntax in Swift, allowing for easy integration into iOS apps.
/// It requires an ``RpcApi`` instance for network communication and the address of the `ERC20` token contract to interact with.
///
/// ### Initialization:
/// ```swift
/// public init(rpc: RpcApi, address: String)
/// ```
///
/// ### Error Handling:
/// All methods are async and can throw errors ``SmartContractError``
public struct ERC20Contract {

    public let contract = GenericSmartContract.ERC20
    
    /// Initializes a new ERC20Contract instance.
    ///
    /// - Parameters:
    ///     - rpc: An RpcApi instance for making RPC calls to the Ethereum network.
    ///     - address: The Ethereum address of the ERC20 token contract.
    public init(rpc: RpcApi, address: String) {
        contract.rpc = rpc
        contract.address = address
    }
    
    /// Retrieves the name of the token.
    public func name() async throws -> String {
        try await contract("name").value as! String
    }
    
    /// Retrieves the symbol of the token.
    public func symbols() async throws -> String {
        try await contract("symbol").value as! String
    }
    
    /// Retrieves the number of decimals the token uses.
    public func decimals() async throws -> BigUInt {
        try await contract("decimals").value as! BigUInt
    }
    
    /// Approves the spender to withdraw from your account, multiple times, up to the value amount.
    /// - Parameter spender: The address of the account able to transfer the tokens.
    /// - Parameter value: The amount of tokens to be approved for transfer.
    public func approve(spender: String, value: BigUInt) async throws -> Bool {
        guard let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("approve", spender, value).value as! Bool
    }
    
    /// Returns the total token supply.
    public func totalSupply() async throws -> BigUInt {
        try await contract("totalSupply").value as! BigUInt
    }
    
    /// Transfers value amount of tokens from address from to address to.
    /// - Parameters:
    ///     - from: The address to transfer tokens from.
    ///     - to: The address to transfer tokens to.
    ///     - value: The amount of tokens to be transferred.
    @discardableResult
    public func transferFrom(from: String, to: String, value: BigUInt) async throws -> Bool {
        guard let from = EthereumAddress(from), let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("transferFrom", from, to, value).value as! Bool
    }
    
    /// Returns the account balance of another account with address `address`.
    public func balanceOf(address: String) async throws -> BigUInt {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("balanceOf", address).value as! BigUInt
    }
    
    /// Transfers value amount of tokens to address `to`.
    /// - Parameters:
    ///     - to: The address to transfer tokens to.
    ///     - value: The amount of tokens to be transferred.
    @discardableResult
    public func transfer(to: String, value: BigUInt) async throws -> Bool {
        guard let to = EthereumAddress(to) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("transfer", to, value).value as! Bool
    }
    
    /// Returns the amount which spender is still allowed to withdraw from owner.
    /// - Parameters:
    ///     - owner: The address of the account owning tokens.
    ///     - spender: The address of the account able to transfer the tokens.
    public func allowance(owner: String, spender: String) async throws -> BigUInt {
        guard let owner = EthereumAddress(owner), let spender = EthereumAddress(spender) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("allowance", owner, spender).value as! BigUInt
    }

}
