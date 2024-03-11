//
// SmartContractAbiLoader.swift
// SmartContract Framework
//
// Created by Yury Dryhin aka DTechLabs on 16.08.2023.
// email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
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

/// The SmartContractAbiLoader struct is a utility designed to load the ABI (Application Binary Interface) of a smart contract from a blockchain explorer.
/// It simplifies the process of fetching the ABI for a given smart contract address by automating the request to a compatible blockchain explorer API.
///
/// ## Initialization
/// The struct can be initialized using two different methods:
///
/// ### URL Initialization:
/// Initializes the loader with a specific blockchain explorer URL.
/// ```swift
/// public init(explorerUrl: URL) throws
/// ```
///
/// ### ChainsData.Explorer Initialization:
/// ```swift
/// public init(_ explorer: ChainsData.Explorer) throws
/// ```
/// Both initializers modify the provided URL to ensure it targets the API endpoint for ABI retrieval, adding necessary query parameters to facilitate the request.
///
/// ## Error Handling
/// The struct defines and uses specific errors ``SmartContractAbiLoaderError`` to handle failures during the initialization and ABI loading processes, 
/// including errors related to URL generation, API responses, and decoding issues.
public struct SmartContractAbiLoader {
    
    let explorerURL: URLComponents
    
    /// Initializes the loader with a specific blockchain explorer URL.
    /// - Parameter explorerUrl: The complete URL of the blockchain explorer.
    /// - Throws: SmartContractAbiLoaderError.errorGenerateExplorerURL if the URL cannot be properly formatted into the required API endpoint.
    public init(explorerUrl: URL) throws {
        guard
            var components = URLComponents(url: explorerUrl, resolvingAgainstBaseURL: false),
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
        
    /// Initializes the loader with a ``ChainsData.Explorer`` instance, which contains the URL and standard information of the blockchain explorer.
    /// - Parameters:
    ///     - explorer: A ChainsData.Explorer object representing the blockchain explorer.
    /// - Throws: SmartContractAbiLoaderError.unsupportedEIP3091 if the explorer does not conform to the EIP-3091 standard.
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
    
    /// Asynchronously fetches the ABI for a smart contract at a specified address.
    /// - Parameters:
    ///     - address: The smart contract address for which the ABI is requested.
    /// - Returns: The ABI of the smart contract as a String.
    ///
    /// - Throws: ``SmartContractAbiLoaderError``
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
