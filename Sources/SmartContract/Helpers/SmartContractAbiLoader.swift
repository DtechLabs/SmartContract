//
// SmartContractAbiLoader.swift
// 
//
// Using Swift 5.0
// Created by Yury Dryhin on 30.11.2023
// email: yuri.drigin@icloud.com
// LinkedIn: https://www.linkedin.com/in/dtechlabs/
// Copyright © 2023  DTechLabs. All rights reserved.
//
        
import Foundation


public enum SmartContractAbiLoaderError: Error {

    /// Explorer doesn't support EIP3091
    case unsupportedEIP3091
    
    case errorGenerateExplorerURL
    case apiError(Int?, Data)
    case decodingError(Data, Error)
    
}



struct AbiResponse: Decodable {
    
    let status: String
    let message: String
    let result: String
    
}

public struct SmartContractAbiLoader {
    
    let explorerURL: URLComponents
    
    public init(explorer: URL) throws {
        guard 
            var components = URLComponents(url: explorer, resolvingAgainstBaseURL: false),
            let host = components.host
        else {
            throw SmartContractAbiLoaderError.errorGenerateExplorerURL
        }
        
        if !host.hasPrefix("api") {
            components.host = "api." + host
        }
        
        if components.path != "api" {
            components.path = "api"
        }
        
        components.queryItems = [
            URLQueryItem(name: "module", value: "contract"),
            URLQueryItem(name: "action", value: "getabi")
        ]
        
        self.explorerURL = components
    }
        
    public init(_ explorer: ChainsData.Explorer) throws {
        guard
            explorer.standard == .EIP3091,
            var urlComponents = URLComponents(url: explorer.url, resolvingAgainstBaseURL: false)
        else {
            throw SmartContractAbiLoaderError.unsupportedEIP3091
        }
        
        urlComponents.host = "api." + urlComponents.host!
        urlComponents.path = "/api"
        urlComponents.queryItems = [
            URLQueryItem(name: "module", value: "contract"),
            URLQueryItem(name: "action", value: "getabi")
        ]
        
        self.explorerURL = urlComponents
    }
    
    public func loadAbi(address: String) async throws -> String {
        var components = explorerURL
        components.queryItems?.append(URLQueryItem(name: "address", value: address))
        
        guard let url = components.url else {
            throw SmartContractAbiLoaderError.errorGenerateExplorerURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard
            let urlResponse = response as? HTTPURLResponse,
            200...299 ~= urlResponse.statusCode
        else {
            throw SmartContractAbiLoaderError.apiError((response as? HTTPURLResponse)?.statusCode, data)
        }
        
        do {
            let abiResponse = try JSONDecoder().decode(AbiResponse.self, from: data)
            return abiResponse.result
        } catch {
            throw SmartContractAbiLoaderError.decodingError(data, error)
        }
        
    }
    
}
