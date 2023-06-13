//
//  QuadratStrategyContract.swift
//  
//
//  Created by Yuri on 13.06.2023.
//
import Foundation
import BigInt

struct QuadratStrategyContract: SmartContract {
    
    public let contract = GenericSmartContract.QuadratStrategy
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
    
    /// - Returns:amount0: BigUInt, amount1: BigUInt, mintAmount: BigUInt, sqrtRatioX96: BigUInt
    public func getMintAmounts(amount0Max: BigUInt, amount1Max: BigUInt) async throws -> [ABIDecodable] {
        return try await runFunction(name: "getMintAmounts", params: amount0Max, amount1Max)
    }

    /// - Returns: *amountA*: BigUInt, *amountB*: BigUInt, *mintAmount*: BigUInt, *liquidityMinted*: BigUInt
    public func mint(amount0Max: BigUInt, amount1Max: BigUInt, receiver: String) async throws -> [ABIDecodable] {
        guard let receiver = EthereumAddress(receiver) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction(name: "mint", params: amount0Max, amount1Max, receiver)
    }
    
    /// - Returns: amountA: BigUInt, amountB: BigUInt, liquidityBurned: BigUInt
    public func burn(burnAmount: BigUInt, receiver: String) async throws -> [ABIDecodable] {
        guard let receiver = EthereumAddress(receiver) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction(name: "burn", params: burnAmount, receiver)
    }
    
    /// - Returns: No Returns
    public func executiveRebalance(
        newLowerTick: BigInt,
        newUpperTick: BigInt,
        swapThresholdPrice: BigUInt,
        swapAmountBPS: BigUInt,
        zeroForOne: Bool
    ) async throws {
        try await callFunction("executiveRebalance", params: newLowerTick, newUpperTick, swapThresholdPrice, swapAmountBPS, zeroForOne)
    }
    
    // MARK: - Static data function
    
    /// - Returns: amount0Current: BigUInt, amount1Current: BigUInt,
    public func getUnderlyingBalances() async throws -> [ABIDecodable] {
        return try await runFunction(name: "getUnderlyingBalances")
    }
    
    
    /// Factory
    /// - Returns: address: EthereumAddress,
    public func factory() async throws -> EthereumAddress {
        return try await runFunction("factory")
    }
    
    /// - Returns: address: EthereumAddress,
    public func pool() async throws -> EthereumAddress {
        return try await runFunction("pool")
    }
    
    /// - Returns: address: EthereumAddress,
    public func manager() async throws -> EthereumAddress {
        return try await runFunction("manager")
    }
    
    /// - Returns: address: EthereumAddress,
    public func token0() async throws -> EthereumAddress {
        return try await runFunction("token0")
    }
    
    /// - Returns: address: EthereumAddress,
    public func token1() async throws -> EthereumAddress {
        return try await runFunction("token1")
    }
    
}
