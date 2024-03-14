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
    
    let contract = "0xAd17d367679f0DBdf23209A70640Cff3c58f4E99"

    func testFee() async throws {
        let data: [BigUInt] = [0, 1, 2, 3]
        let hyperDex = GenericSmartContract.HyperDexRouter
        hyperDex.address = contract
        hyperDex.rpc = GenericRpcNode.ethereum
        
        async let result0 = hyperDex("feeReferrals", data[0]).value as? BigUInt
        async let result1 = hyperDex("feeReferrals", data[1]).value as? BigUInt
        async let result2 = hyperDex("feeReferrals", data[2]).value as? BigUInt
        async let result3 = hyperDex("feeReferrals", data[3]).value as? BigUInt
        let fees = try await [result0, result1, result2, result3]
        XCTAssertEqual(fees.count, 4)
    }
    
    func testFeeBeneficiary() async throws {
        let hyperDex = GenericSmartContract.HyperDexRouter
        hyperDex.address = contract
        hyperDex.rpc = GenericRpcNode.ethereum
        
        let result = try await hyperDex("feeBeneficiary").value as? BigUInt
        
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!, BigUInt.zero)
    }

}
