//
//  QuadratStrategyContract.swift
//  
//
//  Created by Yuri on 13.06.2023.
//
import Foundation
import BigInt

public struct QuadratStrategyContract {
    
    public let contract = GenericSmartContract.QuadratStrategy

    public init(rpc: RpcApi, address: String) {
        contract.rpc = rpc
        contract.address = address
    }
    
    /// - Returns:amount0: BigUInt, amount1: BigUInt, mintAmount: BigUInt, sqrtRatioX96: BigUInt
    public func getMintAmounts(amount0Max: BigUInt, amount1Max: BigUInt) async throws -> SmartContractResult {
        return try await contract("getMintAmounts", amount0Max, amount1Max)
    }

    /// - Returns: *amountA*: BigUInt, *amountB*: BigUInt, *mintAmount*: BigUInt, *liquidityMinted*: BigUInt
    public func mint(amount0Max: BigUInt, amount1Max: BigUInt, receiver: String) async throws -> SmartContractResult {
        guard let receiver = EthereumAddress(receiver) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("mint", amount0Max, amount1Max, receiver)
    }
    
    /// - Returns: amountA: BigUInt, amountB: BigUInt, liquidityBurned: BigUInt
    public func burn(burnAmount: BigUInt, receiver: String) async throws -> SmartContractResult {
        guard let receiver = EthereumAddress(receiver) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("burn", burnAmount, receiver)
    }
    
    /// - Returns: No Returns
    public func executiveRebalance(
        newLowerTick: BigInt,
        newUpperTick: BigInt,
        swapThresholdPrice: BigUInt,
        swapAmountBPS: BigUInt,
        zeroForOne: Bool
    ) async throws {
        try await contract("executiveRebalance", newLowerTick, newUpperTick, swapThresholdPrice, swapAmountBPS, zeroForOne)
    }
    
    /// - Returns: uint256
    public func balanceOf(account: String) async throws -> BigUInt {
        guard let account = EthereumAddress(account) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("balanceOf", account).value as! BigUInt
    }
    
    
    // MARK: - Static data function
    
    /// - Returns: amount0Current: BigUInt, amount1Current: BigUInt,
    public func getUnderlyingBalances() async throws -> SmartContractResult {
        return try await contract("getUnderlyingBalances")
    }
    
    
    /// Factory
    /// - Returns: address: EthereumAddress,
    public func factory() async throws -> EthereumAddress {
        return try await contract("factory").value as! EthereumAddress
    }
    
    /// - Returns: address: EthereumAddress,
    public func pool() async throws -> EthereumAddress {
        return try await contract("pool").value as! EthereumAddress
    }
    
    /// - Returns: address: EthereumAddress,
    public func manager() async throws -> EthereumAddress {
        return try await contract("manager").value as! EthereumAddress
    }
    
    /// - Returns: address: EthereumAddress,
    public func token0() async throws -> EthereumAddress {
        return try await contract("token0").value as! EthereumAddress
    }
    
    /// - Returns: address: EthereumAddress,
    public func token1() async throws -> EthereumAddress {
        return try await contract("token1").value as! EthereumAddress
    }
    
    /// - Returns: bytes32 (Data),
    public func getPositionID() async throws -> Data {
        return try await contract("getPositionID").value as! Data
    }
    
    /// - Returns: int24,
    public func lowerTick() async throws -> BigInt {
        return try await contract("lowerTick").value as! BigInt
    }
    
    /// - Returns: int24,
    public func upperTick() async throws -> BigInt {
        return try await contract("upperTick").value as! BigInt
    }
    
    /// - Returns: int16,
    public func managerFeeBPS() async throws -> BigInt {
        return try await contract("managerFeeBPS").value as! BigInt
    }
    
    /// - Returns: uint256,
    public func managerBalance0() async throws -> BigUInt {
        return try await contract("managerBalance0").value as! BigUInt
    }
    
    /// - Returns: uint256,
    public func managerBalance1() async throws -> BigUInt {
        return try await contract("managerBalance1").value as! BigUInt
    }
    
    /// - Returns: uint256,
    public func hyperpoolsBalance0() async throws -> BigUInt {
        return try await contract("hyperpoolsBalance0").value as! BigUInt
    }
    
    /// - Returns: uint256,
    public func hyperpoolsBalance1() async throws -> BigUInt {
        return try await contract("hyperpoolsBalance1").value as! BigUInt
    }
    
    /// - Returns: uint256,
    public func totalSupply() async throws -> BigUInt {
        return try await contract("totalSupply").value as! BigUInt
    }
    
    /// - Returns: uint256,
    public func getLiquidity() async throws -> BigUInt {
        return try await contract("getLiquidity").value as! BigUInt
    }
 
    public func whiteListEnabled() async throws -> Bool {
        return try await contract("whiteListEnabled").value as! Bool
    }
    
    public func whiteList(address: String) async throws -> Bool {
        guard let address = EthereumAddress(address) else {
            throw SmartContractError.invalidAddress
        }
        return try await contract("whiteList",  address).value as! Bool
    }
}
