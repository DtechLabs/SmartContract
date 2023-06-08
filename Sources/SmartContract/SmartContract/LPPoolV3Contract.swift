//
//  LPPoolV3Contract.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import Foundation
import BigInt

public struct LPPoolV3Contract: SmartContract {
    
    public let contract = GenericSmartContract.LPPoolV3
    public var rpc: RpcApi?
    public var address: String?
    
    public init() {
        self.rpc = nil
        self.address = nil
    }
    
    public init(rcp: RpcApi, address: String) {
        self.rpc = rcp
        self.address = address
    }
    
    /// The first of the two tokens of the pool, sorted by address
    /// - Returns: The token0 contract address **EthereumAddress**
    public func token0() async throws -> String {
        try await runFunction("token0")
    }
    
    /// The second of the two tokens of the pool, sorted by address
    /// - Returns: The token1 contract address **EthereumAddress**
    public func token1() async throws -> String {
        try await runFunction("token1")
    }
    
    /// The pool's fee in hundredths of a bip, i.e. 1e-6
    /// - Returns: The fee **BigUInt**
    public func fee() async throws -> BigUInt {
        try await runFunction("fee")
    }
    
    /// The contract that deployed the pool, which must adhere to the IUniswapV3Factory
    /// - Returns: The contract address **EthereumAddress**
    public func factory() async throws -> EthereumAddress {
        try await runFunction("factory")
    }
    
    public func liquidity() async throws -> BigUInt {
        try await runFunction("liquidity")
    }
    
    public func slot0() async throws -> [ABIDecodable] {
        try await runFunction(name: "slot0")
    }
    
}
