//
//  SmartContractDynamically.swift
//  
//
//  Created by Yuri on 16.08.2023.
//
import XCTest
@testable import SmartContract

final class SmartContractDynamically: XCTestCase {

    let rpcURL =  URL(string: "https://rpc.payload.de")!
    let wrappedETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    
    func testDynamicResult() async throws {
        let erc20 = GenericSmartContract.ERC20
        erc20.address = wrappedETH
        erc20.rpc = RPC(url: rpcURL)
        
        let result = try await erc20("name")
        XCTAssertEqual(result.values.count, 1)
        XCTAssertEqual(result.value as? String, "Wrapped Ether")
    }

}
