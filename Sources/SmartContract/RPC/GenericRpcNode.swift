//
//  GenericRpcNode.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 14.06.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/

import Foundation
import AnyCodable

/// The `RpcApiError` enumeration and the RpcApi protocol are designed to facilitate communication between this library and blockchain nodes,
/// specifically for making remote procedure calls (RPC) to blockchain networks like Ethereum.
public enum RpcApiError: Error {
    
    /// Represents an error related to network communication issues. The URLResponse parameter provides context about the failed request, such as HTTP status codes or server responses.
    case networkError(URLResponse)
    /// Signifies an error returned by the blockchain node itself.
    /// The **AnyCodable?** parameter allows for flexibility in handling various types of error data that nodes might return,
    /// encapsulating error messages or codes specific to the blockchain's RPC implementation.
    case nodeError(AnyCodable?)
    
}

/// The `GenericRpcNode` class is a simple implementation of the`` RpcApi`` protocol,
/// designed primarily for testing purposes and making straightforward RPC calls to Ethereum-based blockchains,
/// such as Polygon or Ethereum. This class facilitates communication with a blockchain node via JSON-RPC,
/// allowing for the execution of smart contract methods or blockchain queries using the network's native RPC interface.
///
/// ## Error handling
/// The class can throw errors of type ``RpcApiError``.
public class GenericRpcNode: RpcApi {
    
    /// The URL of the RPC node to which the calls will be made. This URL points to the specific blockchain network node that the GenericRpcNode instance will interact with.
    public let url: URL
    /// A predefined GenericRpcNode instance configured for the Polygon network
    public static let polygon = GenericRpcNode(URL(string: "https://polygon-rpc.com")!)
    /// A predefined GenericRpcNode instance configured for the Ethereum network.
    public static let ethereum = GenericRpcNode(URL(string: "https://rpc.payload.de")!)
    
    /// Initializes a new instance of GenericRpcNode with a specified RPC node URL.
    /// - Parameter url: The URL of the RPC node.
    public init(_ url: URL) {
        self.url = url
    }
    
    /// Makes an RPC call to the specified address with the provided data and decodes the result to the specified generic type` Result`.
    /// - Parameters:
    ///     - to: The Ethereum address to call.
    ///     - data: The call data, typically the encoded function call to a smart contract.
    /// - Returns: The decoded result of the call as the generic type Result.
    public func call<Result>(to: String, data: Data) async throws -> Result where Result : Decodable, Result : Encodable {
        let request = JsonRpcRequest(
            method: "eth_call",
            params: ["to": to, "data": data.hexString]
        )
        return try await call(request)
    }
    
    /// Performs an RPC call to the specified address with the provided data.
    /// This variant does not return a result and is used for calls that are not expected to return data.
    /// - Parameters:
    ///     - to: The Ethereum address to call.
    ///     - data: The call data, typically the encoded function call to a smart contract.
    public func call(to: String, data: Data) async throws {
        let callData = JsonRpcRequest(
            method: "eth_call",
            params: ["to": to, "data": data.hexString]
        )
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(callData)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonAnswer = try JSONDecoder().decode(JsonRpcResult<Bool>.self, from: data)
        guard jsonAnswer.result != nil else {
            throw RpcApiError.nodeError(jsonAnswer.error)
        }
    }
    
    /// A generic method to perform an RPC call with the provided request data, encoded from a type conforming to Encodable,
    /// and decodes the response into a type conforming to `Decodable`.
    /// - Parameters:
    ///     - data: The request data, encoded from a conforming Request type.
    /// - Returns: The decoded response of the call as the generic type Result.
    public func call<Result: Decodable, Request: Encodable>(_ data: Request) async throws -> Result {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(data)
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        guard
            let httpResponse = urlResponse as? HTTPURLResponse,
            200...299 ~= httpResponse.statusCode
        else {
            throw RpcApiError.networkError(urlResponse)
        }
        
        let jsonAnswer = try JSONDecoder().decode(JsonRpcResult<Result>.self, from: data)
        guard let result = jsonAnswer.result else {
            throw RpcApiError.nodeError(jsonAnswer.error)
        }
        return result
    }
    
}
