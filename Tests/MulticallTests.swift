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
    let url =  URL(string: "https://rpc.payload.de")!
    let address = "0xeefba1e63905ef1d7acba5a8513c70307c1ce441"
    
    func testEncodeCallAbi() throws {
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
        
        let abi = try contract.aggregateAbi(calls).hexString
        XCTAssertEqual(abi, sample)
    }
    
    func testDecodeAggregate() throws {
        let answer = "000000000000000000000000000000000000000000000000000000000109d0b200000000000000000000000000000000000000000000000000000000000000400000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000c000000000000000000000000000000000000000000000000000000000000000600000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000d57726170706564204574686572000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000045745544800000000000000000000000000000000000000000000000000000000"
        
        let values = try MulticallContract().contract.function("aggregate").decodeOutput(answer)
        XCTAssertEqual(values.count, 2)
        let raw = (values[1] as! [Data])[0]
        let name = try ABIDecoder.decodeDynamicOutput(types: [.string], data: raw)
        XCTAssertEqual(name[0] as! String, "Wrapped Ether")
    }
    
    func testCall() async throws {
        let rpc = RPC(url: url)
        let contract = MulticallContract(rpc: rpc, address: address)
        let erc20 = ERC20Contract()
        var calls = [
            try MulticallContract.call(erc20.function("name"), address: wrappedETH.address),
            try MulticallContract.call(erc20.function("symbol"), address: wrappedETH.address)
        ]
        
        _ = try await contract.aggregate(&calls)
        
        XCTAssertEqual(calls[0].result[0] as! String, "Wrapped Ether")
        XCTAssertEqual(calls[1].result[0] as! String, "WETH")
    }
    
    func testGetResult() async throws {
        let rpc = RPC(url: url)
        let contract = MulticallContract(rpc: rpc, address: address)
        let erc20 = ERC20Contract()
        var calls = [
            try MulticallContract.call(erc20.function("name"), address: wrappedETH.address),
            try MulticallContract.call(erc20.function("symbol"), address: wrappedETH.address)
        ]
        
        _ = try await contract.aggregate(&calls)
        
        let name: String = try calls[0].getResult("")
        let symbol: String = try calls[1].getResult(by: 0)
        XCTAssertEqual(name, "Wrapped Ether")
        XCTAssertEqual(symbol, "WETH")
    }
    
}
