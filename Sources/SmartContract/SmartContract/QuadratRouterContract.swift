//
//  QuadratRouterContract.swift
//  
//
//  Created by Yuri on 08.06.2023.
//

import Foundation
import BigInt

public struct QuadratRouterContract: SmartContract {
    
    public let contract = GenericSmartContract.QuadratRouter
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
    
    /// - Returns:
    ///  - amount0: BigUint,
    ///  - amount1: BigUInt,
    ///  - token0: EthereumAddress,
    ///  - token1: EthereumAddress,
    ///  - paymentAmount0: BigUInt,
    ///  - paymentAmount1: BigUInt
    public func getMintAmounts(hyperpool: String, paymentToken: String, paymentAmount: BigUInt) async throws -> [ABIDecodable] {
        guard let hyperpool = EthereumAddress(hyperpool), let token = EthereumAddress(paymentToken) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction(name: "getMintAmounts", params: hyperpool, token, paymentAmount)
    }
    
    public func getPrice(tokenIn: String, tokenOut: String, uniFee: BigUInt, sqrtRatioX96: BigUInt) async throws -> BigUInt {
        guard let tokenIn = EthereumAddress(tokenIn), let tokenOut = EthereumAddress(tokenOut) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("getPrice", params: tokenIn, tokenOut, uniFee, sqrtRatioX96)
    }
    
    public func getSwapAmount(tokenIn: String, tokenOut: String, uniFee: BigUInt, sqrtRatioX96: BigUInt) async throws -> BigUInt {
        guard let tokenIn = EthereumAddress(tokenIn), let tokenOut = EthereumAddress(tokenOut) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction("getSwapAmount", params: tokenIn, tokenOut, uniFee, sqrtRatioX96)
    }
    
    /// - Returns:
    ///  - amount0: BigUint,
    ///  - amount1: BigUInt,
    ///  - token0: EthereumAddress,
    ///  - token1: EthereumAddress,
    ///  - paymentAmount0: BigUInt,
    ///  - paymentAmount1: BigUInt
    public func mint(
        hyperpool: String,
        paymentToken: String,
        paymentAmount: BigUInt,
        sqrtPriceLimitX960: BigUInt,
        sqrtPriceLimitX961: BigUInt
    ) async throws -> [ABIDecodable] {
        guard let hyperpool = EthereumAddress(hyperpool), let token = EthereumAddress(paymentToken) else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction(name: "min", params: hyperpool, token, paymentAmount, sqrtPriceLimitX960, sqrtPriceLimitX961)
    }
    
    /// - Returns:
    ///  - amount0: BigUint,
    ///  - amount1: BigUInt,
    ///  - mintAmount: BigUInt,
    ///  - liquidityMinted: BigUInt
    public func mintHyper(
        hyperpool: String,
        paymentToken: String,
        paymentAmount: BigUInt,
        hyperDex: String,
        callData1: Data,
        callData2: Data
    ) async throws -> [ABIDecodable] {
        guard
            let hyperpool = EthereumAddress(hyperpool),
            let token = EthereumAddress(paymentToken),
            let hyperDex = EthereumAddress(hyperDex)
        else {
            throw SmartContractError.invalidAddress
        }
        return try await runFunction(name: "mintHyper", params: hyperpool, token, paymentAmount, hyperDex, callData1, callData2)
    }
    
}
