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
    
    let rpc =  URL(string: "https://rpc.payload.de")!
    let wrappedETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"
    
    func testCallGenericAbi() async throws {
        
        let rpc = RPC(url: rpc)
        let contract = ERC20Contract()
        let rawName: String = try await rpc.call(to: wrappedETH, data: try contract.abi("name"))
        let name: String = try contract.decode("name", data: rawName)
        XCTAssertEqual(name, "Wrapped Ether")
        
        let rawDecimals: String = try await rpc.call(to: wrappedETH, data: try contract.abi("decimals"))
        let decimals: BigUInt = try contract.decode("decimals", data: rawDecimals)
        XCTAssertEqual(decimals, 18)
        
        let rawSymbol: String = try await rpc.call(to: wrappedETH, data: try contract.abi("symbol"))
        let symbol: String = try contract.decode("symbol", data: rawSymbol)
        XCTAssertEqual(symbol, "WETH")
        
    }
    
    func testSingleCall() async throws {
        
        let rpc = RPC(url: rpc)
        let contract = ERC20Contract(rcp: rpc, address: wrappedETH)
        let name = try await contract.name()
        XCTAssertEqual(name, "Wrapped Ether")

        let decimals = try await contract.decimals()
        XCTAssertEqual(decimals, 18)

        let symbol = try await contract.symbols()
        XCTAssertEqual(symbol, "WETH")
    }

}

