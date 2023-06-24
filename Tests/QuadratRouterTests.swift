//
//  QuadratRouterTests.swift
//  
//
//  Created by Yuri on 23.06.2023.
//
import XCTest
import BigInt
@testable import SmartContract

final class QuadratRouterTests: XCTestCase {
    
    let url = URL(string: "https://polygon-rpc.com")!

    func testGetMintAmount() async throws {
        let rpc = RPC(url: url)
        let contract = QuadratRouterContract(rpc: rpc, address: "0xB9B0E67242F68E2CDe01cf6198C5Cf3b64917FB3")
        let strategy = "0xff0ea927edf3f83380c28d842d873da7d422025b"
        let token = "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270"
        let amount: BigUInt = 5000000000000000000
        
        let result = try await contract.getMintAmounts(hyperpool: strategy, paymentToken: token, paymentAmount: amount)
        let amount0 = result[0] as! BigUInt
        let amount1 = result[1] as! BigUInt
        let token0 = result[2] as! EthereumAddress
        let token1 = result[3] as! EthereumAddress
        print("Amount0", amount0, "Amount1", amount1)
        XCTAssertGreaterThan(amount0, 0)
        XCTAssertGreaterThan(amount1, 0)
        XCTAssertEqual(token0.address, "0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270")
        XCTAssertEqual(token1.address, "0xc2132D05D31c914a87C6611C10748AEb04B58e8F")
    }


}
