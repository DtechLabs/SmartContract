//
//  MulticallTests.swift
//  
//
//  Created by Yuri on 03.06.2023.
//
import XCTest
@testable import SmartContract

final class MulticallTests: XCTestCase {

    let wrappedETH = EthereumAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")!
    
    func testEncodeCall() throws {
        let contract = MulticallContract()
        let erc20 = ERC20Contract()
        let calls: [MulticallContract.Call] = [
            .init(address: wrappedETH, bytes: try erc20.abi("name")),
            .init(address: wrappedETH, bytes: try erc20.abi("symbol"))
        ]

        XCTAssertEqual(try contract.contract.function("aggregate").methodName, "aggregate((address,bytes)[])")
        XCTAssertEqual(try contract.contract.function("aggregate").signature(), "0x252dba42")
        
        let sample =
        """
        0x252dba42
        0000000000000000000000000000000000000000000000000000000000000020
        0000000000000000000000000000000000000000000000000000000000000002
        0000000000000000000000000000000000000000000000000000000000000040
        00000000000000000000000000000000000000000000000000000000000000c0
        000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
        0000000000000000000000000000000000000000000000000000000000000040
        0000000000000000000000000000000000000000000000000000000000000004
        06fdde0300000000000000000000000000000000000000000000000000000000
        000000000000000000000000c02aaa39b223fe8d0a0e5c4f27ead9083c756cc2
        0000000000000000000000000000000000000000000000000000000000000040
        0000000000000000000000000000000000000000000000000000000000000004
        95d89b4100000000000000000000000000000000000000000000000000000000
        """.split(separator: "\n").joined()
        
        let abi = try contract.aggregateAbi(calls)
        XCTAssertEqual(abi, sample)
    }
    
}
