//
//  GenericSmartContract.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 16.08.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/

import Foundation

/// The `GenericSmartContract` class serves as a dynamic interface for interacting with smart contracts on the Ethereum blockchain.
/// It enables the encoding and decoding of contract calls and responses using the contract's **ABI** (Application Binary Interface).
///
/// ## Initialization
/// ### From ABI Data:
/// ```swift
/// let contract = try GenericSmartContract(abi: abiData, rpc: rpcInteractor, address: contractAddress)
/// // or
/// let contract = try GenericSmartContract(abi: abiData)
/// ```
///
/// ### From ABI JSON File:
/// ```swift
/// let contract = try GenericSmartContract(abiJson: {String})
/// ```
///
/// ## Error Handling
/// The class throws errors for various failure scenarios, including invalid JSON, unknown function names, mismatched arguments, and unconfigured RPC or contract addresses, as defined by ``SmartContractError``.
///
/// ## Usage
/// GenericSmartContract facilitates dynamic calling of smart contract functions directly in Swift, making it easier to interact with Ethereum smart contracts without manually encoding or decoding call data or outputs.
/// It simplifies the process of integrating Ethereum blockchain functionalities into Swift applications.
@dynamicCallable public class GenericSmartContract {

    public var address: String?
    public var rpc: RpcApi?
    
    var functions: [ABIFunction] = []
    var events: [ABIEvent] = []
    
    /// Initializes the contract interface with ABI data.
    /// - Parameter abi: ABI of the smart contract in Data format.
    public init(abi: Data) throws {
        guard let items = try JSONSerialization.jsonObject(with: abi) as? [[String: Any]] else {
            throw SmartContractError.invalidJson
        }
        
        try items.forEach {
            let data = try JSONSerialization.data(withJSONObject: $0)
            guard let itemType = $0["type"] as? String, let type = ABIItemType(rawValue: itemType) else {
                assertionFailure("Unknown type \($0)")
                return
            }
            switch type {
                case .function:
                    let function = try JSONDecoder().decode(ABIFunction.self, from: data)
                    functions.append(function)
                case .event:
                    let event = try JSONDecoder().decode(ABIEvent.self, from: data)
                    events.append(event)
                case .fallback, .constructor, .receive:
                    // Nothing todo right now
                    break
            }
        }
    }
    
    /// Initializes the contract interface with ABI data.
    /// - Parameters
    ///     - abi: ABI of the smart contract in Data format.
    ///     - rpc: An ``RpcApi`` instance for making calls to the blockchain.
    ///     - address: The address of the smart contract.
    public convenience init(abi: Data, rpc: RpcApi, address: String) throws {
        try self.init(abi: abi)
        
        self.address = address
        self.rpc = rpc
    }
    
    /// Initializes the contract interface with a JSON string representation of the ABI.
    /// - Parameter abiJson: ABI of the smart contract as a JSON string.
    public convenience init(abiJson: String) throws {
        guard let data = abiJson.data(using: .utf8) else {
            throw SmartContractError.invalidJson
        }
        
        try self.init(abi: data)
    }
    
    /// Initializes the contract interface with a JSON string representation of the ABI.
    /// - Parameters
    ///     - abiJson: ABI of the smart contract as a JSON string.
    ///     - rpc: An ``RpcApi`` instance for making calls to the blockchain.
    ///     - address: The address of the smart contract.
    public convenience init(abiJson: String, rpc: RpcApi, address: String) throws {
        try self.init(abiJson: abiJson)
        
        self.address = address
        self.rpc = rpc
    }
        
    convenience init(_ jsonFile: String) throws {
        guard let path = Bundle.module.path(forResource: jsonFile, ofType: "json") else {
            throw SmartContractError.jsonNotFound
        }
        
        let data = try Data(contentsOf: URL(filePath: path))
        try self.init(abi: data)
    }
    
    convenience init(_ jsonFile: String, rpc: RpcApi, address: String) throws {
        try self.init(jsonFile)
        
        self.address = address
        self.rpc = rpc
    }
    
    ///  Retrieves a specific smart contract function by name.
    /// - Parameter name: The name of the function.
    /// - Returns: A ``SmartContractFunction`` instance representing the function.
    public func function(_ name: String) throws -> SmartContractFunction {
        guard let function = functions.first(where: { $0.name == name }) else {
            throw SmartContractError.invalidFunctionName(name)
        }
        
        return SmartContractFunction(abi: function)
    }
    
    public func dynamicallyCall(withArguments args: [Any]) async throws -> SmartContractResult {
        guard  let name = args.first as? String else {
            throw SmartContractError.missedFunctionName
        }
        
        let function = try function(name)
        let params = args[1...].compactMap { $0 as? ABIEncodable }
        guard params.count == function.inputs.count else {
            throw SmartContractError.wrongFunctionArgumentsCountOrType
        }
        
        guard let rpc = rpc, let address = address else {
            throw SmartContractError.contractOrRpcDidNotSet
        }
        
        let abi = try function.encode(params: params)
        let result: String = try await rpc.call(to: address, data: abi)
        let outputs = try function.decodeOutput(result)
        return try SmartContractResult(values: outputs, outputs: function.outputs)
    }
    
    public func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, [ABICodable]>) async throws -> SmartContractResult {
        guard args.count == 1 else {
            throw SmartContractError.invalidFunctionNameOrArguments
        }
        
        guard
            let address = address,
            let rpc = rpc
        else {
            throw SmartContractError.contractOrRpcDidNotSet
        }
        
        let function = try function(args[0].key)
        let abi = try function.encode(params: args[0].value)
        let rawAnswer: String = try await rpc.call(to: address, data: abi)
        let outputs = try function.decodeOutput(rawAnswer)
        return try SmartContractResult(values: outputs, outputs: function.outputs)
    }
    
    /// Checks if the ABI includes a function with the specified name.
    /// - Parameter name: The name of the function.
    /// - Returns: **true** if the function exists, otherwise **false**.
    public func hasFunction(withName name: String) -> Bool {
        functions.first { $0.name == name } != nil
    }
    
    /// Checks if the ABI includes a function with the specified signature.
    /// - Parameter signature: The signature of the function.
    /// - Returns: **true** if the function exists, otherwise **false**.
    public func hasFunction(withSignature signature: String) -> Bool {
        functions.first { $0.signature == signature } != nil
    }
    
    /// Encodes the ABI for a specific function without arguments.
    /// - Returns: The encoded ABI as Data.
    public func abi(_ functionName: String) throws -> Data {
        try function(functionName).encode()
    }
    
    /// Encodes the ABI for a specific function with provided arguments.
    /// - Parameter functionName: The name of the function.
    /// - Parameter params: The arguments for the function.
    /// - Returns: The encoded ABI as Data.
    public func abi(_ functionName: String, params: ABIEncodable...) throws -> Data {
        try function(functionName).encode(params: params)
    }
    
    
    /// Decodes the output data from a smart contract function call.
    /// - Parameter functionName: The name of the function whose output is being decoded.
    /// - Parameter data: The data string to decode.
    /// - Returns: The decoded data as a generic type T.
    public func decode<T>(_ functionName: String, data: String) throws -> T {
        guard let value = try function(functionName).decodeOutput(data)[0] as? T else {
            throw SmartContractError.invalidData(data)
        }
        return value
    }
}

// MARK: Preloaded Contract
public extension GenericSmartContract {
    
    static let ERC20 = try! GenericSmartContract("erc20")
    static let LPPoolV3 = try! GenericSmartContract("lp-pool-v3")
    static let Multicall = try! GenericSmartContract("multicall")
    static let QuadratRouter = try! GenericSmartContract("quadrat-router")
    static let QuadratStrategy = try! GenericSmartContract("quadrat-strategy")
    static let HyperDexRouter = try! GenericSmartContract("hyper-dex-router")
    
}
