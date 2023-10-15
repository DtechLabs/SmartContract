//
//  HyperDexRouterTests.swift
//  
//
//  Created by Yuri on 15.10.2023.
//

import XCTest
import BigInt
@testable import SmartContract

final class HyperDexRouterTests: XCTestCase {
    
    let rpcURL =  URL(string: "https://rpc.payload.de")!
    let contract = "0xAd17d367679f0DBdf23209A70640Cff3c58f4E99"

    func testFee() async throws {
        let data: [BigUInt] = [0, 1, 2, 3]
        let hyperDex = GenericSmartContract.HyperDexRouter
        hyperDex.address = contract
        hyperDex.rpc = RPC(url: rpcURL)
        
        async let result0: BigUInt? = hyperDex("feeReferrals", data[0]).value
        async let result1: BigUInt? = hyperDex("feeReferrals", data[1]).value
        async let result2: BigUInt? = hyperDex("feeReferrals", data[2]).value
        async let result3: BigUInt? = hyperDex("feeReferrals", data[3]).value
        let fees = try await [result0, result1, result2, result3]
        
        XCTAssertEqual(fees.count, 4)
        print(fees)
    }
    
    func testFeeBeneficiary() async throws {
        let hyperDex = GenericSmartContract.HyperDexRouter
        hyperDex.address = contract
        hyperDex.rpc = RPC(url: rpcURL)
        
        let result: BigUInt? = try await hyperDex("feeBeneficiary").value
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!, BigUInt.zero)
    }

}
