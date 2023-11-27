//
//  ERC20ContractTests.swift
//  
//
//  Created by Yuri on 02.06.2023.
//
import XCTest
import BigInt
@testable import SmartContract

class ERC20ContractTests: XCTestCase {
    
    let rpc = GenericRpcNode(URL(string: "https://rpc.payload.de")!)
    let wrappedETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    
    lazy var erc30: ERC20Contract = ERC20Contract(rpc: rpc, address: wrappedETH)
    
    func testCallGenericAbi() async throws {
        let contract = GenericSmartContract.ERC20
        let rawName: String = try await rpc.call(to: wrappedETH, data: try contract.abi("name"))
        let name: String = try contract.decode("name", data: rawName)
        XCTAssertEqual(name, "Wrapped Ether")
        
        let rawDecimals: String = try await rpc.call(to: wrappedETH, data: try erc30.contract.abi("decimals"))
        let decimals: BigUInt = try contract.decode("decimals", data: rawDecimals)
        XCTAssertEqual(decimals, 18)
        
        let rawSymbol: String = try await rpc.call(to: wrappedETH, data: try contract.abi("symbol"))
        let symbol: String = try contract.decode("symbol", data: rawSymbol)
        XCTAssertEqual(symbol, "WETH")
        
    }
    
    func testSingleCall() async throws {
        let name = try await erc30.name()
        XCTAssertEqual(name, "Wrapped Ether")

        let decimals = try await erc30.decimals()
        XCTAssertEqual(decimals, 18)

        let symbol = try await erc30.symbols()
        XCTAssertEqual(symbol, "WETH")
    }

}

