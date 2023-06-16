//
//  UniswapPoolTests.swift
//  
//
//  Created by Yuri on 16.06.2023.
//
import XCTest
@testable import SmartContract

final class UniswapPoolTests: XCTestCase {

    let address = "0xa374094527e1673a86de625aa59517c5de346d32"
    let url = URL(string: "https://polygon-rpc.com")!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    func testSingleCall() async throws {
        let rpc = RPC(url: url)
        let contract = LPPoolV3Contract(rcp: rpc, address: address)
        let token0 = try await contract.token0()
        XCTAssertEqual(token0.address.lowercased(), "0x0d500b1d8e8ef31e21c99d1db9a6444d3adf1270")
        let token1 = try await contract.token1()
        XCTAssertEqual(token1.address.lowercased(), "0x2791bca1f2de4661ed88a30c99a7a9449aa84174")
        let fee = try await contract.fee()
        XCTAssertEqual(fee, 500)
        let factory = try await contract.factory()
        XCTAssertEqual(factory.address.lowercased(), "0x1f98431c8ad98523631ae4a59f267346ea31f984")
        let liquidity = try await contract.liquidity()
        XCTAssertGreaterThan(liquidity, 0)
        let slot0 = try await contract.slot0()
        XCTAssertEqual(slot0[6] as? Bool, true)
    }

}
