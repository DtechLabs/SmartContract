//
//  LPPoolV3Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct LPPoolV3Contract {
    
    public let contract = GenericSmartContract.LPPoolV3

    public init(rpc: RpcApi, address: String) {
        contract.rpc = rpc
        contract.address = address
    }
    
    /// The first of the two tokens of the pool, sorted by address
    /// - Returns: The token0 contract address **EthereumAddress**
    public func token0() async throws -> EthereumAddress {
        try await contract("token0").value as! EthereumAddress
    }
    
    /// The second of the two tokens of the pool, sorted by address
    /// - Returns: The token1 contract address **EthereumAddress**
    public func token1() async throws -> EthereumAddress {
        try await contract("token1").value as! EthereumAddress
    }
    
    /// The pool's fee in hundredths of a BIP, i.e. 1e-6
    /// - Returns: The fee **BigUInt**
    public func fee() async throws -> BigUInt {
        try await contract("fee").value as! BigUInt
    }
    
    /// The contract that deployed the pool, which must adhere to the IUniswapV3Factory
    /// - Returns: The contract address **EthereumAddress**
    public func factory() async throws -> EthereumAddress {
        try await contract("factory").value as! EthereumAddress
    }
    
    public func liquidity() async throws -> BigUInt {
        try await contract("liquidity").value as! BigUInt
    }
    
    public func slot0() async throws -> SmartContractResult {
        try await contract("slot0")
    }
    
}
