//
//  LoadingSmartContractTests.swift
//  
//
//  Created by Yury Dryhin on 05.03.2024.
//
import XCTest
@testable import SmartContract

final class LoadingSmartContractTests: XCTestCase {
    
    let USDT = "0xdAC17F958D2ee523a2206206994597C13D831ec7"
    let USDT_Polygon = "0x7FFB3d637014488b63fb9858E279385685AFc1e2"
    

    func testLoadingChains() async throws {
        
        let _ = ChainsDataStorage()
        XCTAssertFalse(ChainsDataStorage.chains.isEmpty)
        print("Chains count", ChainsDataStorage.chains.count)

        try await Task.sleep(for: .seconds(2))
        XCTAssertTrue(FileManager.default.fileExists(atPath: ChainsDataStorage.fileURL.path()))
        print(ChainsDataStorage.fileURL)
        
    }
    
    func testGetExplorer() async throws {
        
        let _ = ChainsDataStorage()
        let chainData = ChainsDataStorage.chains.first { $0.chainId == 1 }!
        let explorer = chainData.explorers!.first { $0.standard == .EIP3091 }!
        
        let loader = try SmartContractAbiLoader(explorer)
        XCTAssertNotNil(loader.explorerURL.url)
        let abi = try await loader.loadAbi(address: USDT)
        XCTAssertFalse(abi.isEmpty)
 
        let contract = try GenericSmartContract(abiJson: abi)
        XCTAssertTrue(contract.hasFunction(withName: "name"))
        XCTAssertTrue(contract.hasFunction(withName: "decimals"))
        XCTAssertTrue(contract.hasFunction(withName: "symbol"))
        
        let explorerPolygon = ChainsDataStorage.chains.first { $0.chainId == 137 }!.explorers!.first { $0.standard == .EIP3091 }!
        let loaderPolygon = try SmartContractAbiLoader(explorerPolygon)
        XCTAssertNotNil(loaderPolygon.explorerURL.url)
        let abiPolygon = try await loaderPolygon.loadAbi(address: USDT_Polygon)
        XCTAssertFalse(abiPolygon.isEmpty)
        
        let contractPolygon = try GenericSmartContract(abiJson: abiPolygon)
        XCTAssertTrue(contractPolygon.hasFunction(withName: "name"))
        XCTAssertTrue(contractPolygon.hasFunction(withName: "decimals"))
        XCTAssertTrue(contractPolygon.hasFunction(withName: "symbol"))
        
    }
    
}
