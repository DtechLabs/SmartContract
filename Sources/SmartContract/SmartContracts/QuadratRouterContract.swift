//
//  QuadratRouterContract.swift
//  
//
//  Created by Yuri on 08.06.2023.
//

import Foundation
import BigInt

public struct QuadratRouterContract {
    
    public let contract = GenericSmartContract.QuadratRouter

    public init(rpc: RpcApi, address: String) {
        contract.rpc = rpc
        contract.address = address
    }
    
    /// **GetMintAmount**
    /// - Returns:
    ///  - amount0: BigUint,
    ///  - amount1: BigUInt,
    ///  - token0: EthereumAddress,
    ///  - token1: EthereumAddress,
    ///  - paymentAmount0: BigUInt,
    ///  - paymentAmount1: BigUInt
    public func getMintAmounts(hyperpool: String, paymentToken: String, paymentAmount: BigUInt) async throws -> SmartContractResult {
        guard let hyperpool = EthereumAddress(hyperpool), let token = EthereumAddress(paymentToken) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("getMintAmounts", hyperpool, token, paymentAmount)
    }
    
    public func getPrice(tokenIn: String, tokenOut: String, uniFee: BigUInt, sqrtRatioX96: BigUInt) async throws -> BigUInt {
        guard let tokenIn = EthereumAddress(tokenIn), let tokenOut = EthereumAddress(tokenOut) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("getPrice", tokenIn, tokenOut, uniFee, sqrtRatioX96).value as! BigUInt
    }
    
    public func getSwapAmount(tokenIn: String, tokenOut: String, uniFee: BigUInt, sqrtRatioX96: BigUInt) async throws -> BigUInt {
        guard let tokenIn = EthereumAddress(tokenIn), let tokenOut = EthereumAddress(tokenOut) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("getSwapAmount", tokenIn, tokenOut, uniFee, sqrtRatioX96).value as! BigUInt
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
    ) async throws -> SmartContractResult {
        guard let hyperpool = EthereumAddress(hyperpool), let token = EthereumAddress(paymentToken) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("min", hyperpool, token, paymentAmount, sqrtPriceLimitX960, sqrtPriceLimitX961)
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
    ) async throws -> SmartContractResult {
        guard
            let hyperpool = EthereumAddress(hyperpool),
            let token = EthereumAddress(paymentToken),
            let hyperDex = EthereumAddress(hyperDex)
        else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("mintHyper", hyperpool, token, paymentAmount, hyperDex, callData1, callData2)
    }
    
    /// - Returns:
    ///  - returnTokenReturn: BigUint,
    ///  - token0Return: BigUInt,
    ///  - token1Return: BigUInt,
    public func estimateBurnReturn(
        hyperpool: String,
        burnAmount: BigUInt,
        returnToken: String,
        sqrtPriceX960: BigUInt,
        sqrtPriceX961: BigUInt
    ) async throws -> SmartContractResult {
        guard
            let hyperpool = EthereumAddress(hyperpool),
            let returnToken = EthereumAddress(returnToken)
        else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("estimateBurnReturn", hyperpool, burnAmount, returnToken, sqrtPriceX960, sqrtPriceX961)
    }
    
    /// - Returns:
    ///  - returnAmount: BigUint (unit256),
    ///  - liquidityBurned: BigUInt (uint128),
    public func burn(
        hyperpool: String,
        burnAmount: BigUInt,
        returnToken: String,
        sqrtPriceX960: BigUInt,
        sqrtPriceX961: BigUInt
    ) async throws -> SmartContractResult {
        guard
            let hyperpool = EthereumAddress(hyperpool),
            let returnToken = EthereumAddress(returnToken)
        else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("burn", hyperpool, burnAmount, returnToken, sqrtPriceX960, sqrtPriceX961)
    }
    
}
