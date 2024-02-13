import Foundation

@dynamicCallable
public class GenericSmartContract {

    public var address: String?
    public var rpc: RpcApi?
    
    var functions: [ABIFunction] = []
    var events: [ABIEvent] = []
    
    init(_ jsonFile: String) throws {
        guard let path = Bundle.module.path(forResource: jsonFile, ofType: "json") else {
            throw SmartContractError.jsonNotFound
        }
        
        let data = try Data(contentsOf: URL(filePath: path))
        guard let items = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
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
    
    convenience init(_ jsonFile: String, rpc: RpcApi, address: String) throws {
        try self.init(jsonFile)
        
        self.address = address
        self.rpc = rpc
    }
    
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
        let result: String = try await rpc.call(to: address, data: abi.hexString)
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
        let rawAnswer: String = try await rpc.call(to: address, data: abi.hexString)
        let outputs = try function.decodeOutput(rawAnswer)
        return try SmartContractResult(values: outputs, outputs: function.outputs)
    }
    
    // MARK: Working with raw data
    public func abi(_ functionName: String) throws -> Data {
        try function(functionName).encode()
    }
    
    public func abi(_ functionName: String, params: ABIEncodable...) throws -> String {
        try function(functionName).encode(params: params).hexString
    }
    
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
