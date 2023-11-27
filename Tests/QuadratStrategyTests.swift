//
//  QuadratStrategyTests.swift
//  
//
//  Created by Yuri on 24.06.2023.
//
import XCTest
import BigInt
@testable import SmartContract

final class QuadratStrategyTests: XCTestCase {

    /// WMATIC / USDT
    let strategy = "0xff0ea927edf3f83380c28d842d873da7d422025b"
    
    func testGetMintAmount() async throws {
        let contract = QuadratStrategyContract(rpc: RPC.polygon, address: strategy)
        let amount0 = BigUInt("2083746537199521078")
        let amount1 = BigUInt("1970407")
        let mintResult = try await contract.getMintAmounts(amount0Max: amount0, amount1Max: amount1)
        let mintAmount: BigUInt = mintResult.mintAmount!
        XCTAssertLessThanOrEqual(mintResult.amount0!, amount0)
        XCTAssertLessThanOrEqual(mintResult.amount1!, amount1)
        print("Mint amount", mintAmount)
        XCTAssertGreaterThan(mintAmount, .zero)
    }

}
