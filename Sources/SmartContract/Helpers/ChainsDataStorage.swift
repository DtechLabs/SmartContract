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

public struct ChainsData: Codable {
    
    public struct Feature: Codable {
        public var name: EIP
    }
    
    public struct Currency: Codable {
        public let name: String
        public let symbol: String
        public let decimals: UInt8
    }
    
    public struct ENS: Codable {
        public let registry: EthereumAddress
    }
    
    public struct Explorer: Codable {
        public let name: String
        public let url: URL
        public let icon: String?
        public let standard: EIP
    }
    
    public let name: String
    public let chain: String
    public let icon: String?
    public let rpc: [String]
    public let features: [Feature]?
    public let faucets: [String]
    public let nativeCurrency: Currency
    public let infoURL: String
    public let shortName: String
    public let chainId: UInt
    public let networkId: UInt
    public let slip44: UInt?
    public let ens: ENS?
    public let explorers: [Explorer]?
    
}
 
enum ChainsDataStorageError: Error {
    
    case savedDataNotFound
    case missedChainData(UInt)
    
}

struct ChainsDataStorage {
    
    public static var chains: [ChainsData] = []
    
    static let storageFolderURL: URL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appending(path: "SmartContracts")
    
    static let fileURL = storageFolderURL.appending(path: "chains.json")
    
    public init() {
            
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
    
    public static func loadFromBundle() throws {
        let path = Bundle.module.path(forResource: "chains", ofType: "json")!
        let json = try Data(contentsOf: URL(filePath: path))
        chains = try JSONDecoder().decode([ChainsData].self, from: json)
    }
    
    static func load() throws -> [ChainsData] {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            throw ChainsDataStorageError.savedDataNotFound
        }
        let data = try Data(contentsOf: fileURL)
        return try JSONDecoder().decode([ChainsData].self, from: data)
    }
    
    static func save(_ chains: [ChainsData]) throws {
        if !FileManager.default.fileExists(atPath: storageFolderURL.path()) {
            try FileManager.default.createDirectory(at: storageFolderURL, withIntermediateDirectories: true)
        }
        let data = try JSONEncoder().encode(chains)
        try data.write(to: fileURL)
    }
    
}
