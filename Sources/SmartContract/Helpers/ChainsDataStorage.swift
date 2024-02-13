//
// ChainsDataStorage.swift
// SmartContract
//
// Created by Yury Dryhin on 28.11.2023
// email: yuri.drigin@icloud.com
// LinkedIn: https://www.linkedin.com/in/dtechlabs/
// Copyright © 2023  DTechLabs. All rights reserved.
//
        
import Foundation

public enum EIP: String, Codable {
    case EIP155
    case EIP1559
    case EIP3091
    case none
}

struct ChainsData: Codable {
    
    struct Feature: Codable {
        var name: EIP
    }
    
    struct Currency: Codable {
        let name: String
        let symbol: String
        let decimals: UInt8
    }
    
    struct ENS: Codable {
        let registry: EthereumAddress
    }
    
    struct Explorer: Codable {
        let name: String
        let url: URL
        let icon: String?
        let standard: EIP
    }
    
    let name: String
    let chain: String
    let icon: String?
    let rpc: [String]
    let features: [Feature]?
    let faucets: [String]
    let nativeCurrency: Currency
    let infoURL: String
    let shortName: String
    let chainId: UInt
    let networkId: UInt
    let slip44: UInt?
    let ens: ENS?
    let explorers: [Explorer]?
    
}
 
enum ChainsDataStorageError: Error {
    
    case savedDataNotFound
    case missedChainData(UInt)
    
}

struct ChainsDataStorage {
    
    static var chains: [ChainsData] = []
    
    init() {
            
        if let chains = try? Self.load() {
            Self.chains = chains
        } else {
            try? Self.loadFromBundle()
        }
        
        Task(priority: .utility) {
            let (data, _) = try await URLSession.shared.data(from: URL(string: "https://chainid.network/chains.json")!)
            let chains = try JSONDecoder().decode([ChainsData].self, from: data)
            Self.chains = chains
            try Self.save(chains)
        }
    }
    
//    func getExplorer(for chainId: UInt) async throws -> ChainsData.Explorer {
//        guard
//            let chain = Self.chains.first(where: { $0.chainId == chainId }),
//            let explorers = chain.explorers?.filter({ $0.standard == .EIP3091 }),
//            !explorers.isEmpty
//        else {
//            throw ChainsDataStorageError.missedChainData(chainId)
//        }
//        
//        let request = URLRequest(url: <#T##URL#>)
//        for explorer in explorers {
//            
//        }
//    }
    
    static func loadFromBundle() throws {
        let path = Bundle.module.path(forResource: "chains", ofType: "json")!
        let json = try Data(contentsOf: URL(filePath: path))
        chains = try JSONDecoder().decode([ChainsData].self, from: json)
    }
    
    static func load() throws -> [ChainsData] {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "SmartContracts").appending(path: "chains.json")
        guard FileManager.default.fileExists(atPath: url.path()) else {
            throw ChainsDataStorageError.savedDataNotFound
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ChainsData].self, from: data)
    }
    
    static func save(_ chains: [ChainsData]) throws {
        let url =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "SmartContracts")
        if !FileManager.default.fileExists(atPath: url.path()) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
        let data = try JSONEncoder().encode(chains)
        try data.write(to: url.appending(path: "chains.json"))
    }
    
}
