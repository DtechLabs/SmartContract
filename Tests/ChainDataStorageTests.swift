//
//  ChainDataStorageTests.swift
//  
//
//  Created by Yuri on 28.11.2023.
//

import XCTest
@testable import SmartContract

final class ChainDataStorageTests: XCTestCase {

    func testInitStorage() throws {
        let storage = ChainsDataStorage()
        
        XCTAssertEqual(ChainsDataStorage.chains.count, 1133)
        
        let exp = XCTestExpectation()
        Task {
            try await Task.sleep(for: .seconds(1))
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3)
        
        let url =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "SmartContracts").appending(path: "chains.json")
        print(url)
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path()))
    }
    
}
