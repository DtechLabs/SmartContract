import Foundation

public struct GenericSmartContract {

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
    
    func function(_ name: String) throws -> SmartContractFunction {
        guard let function = functions.first(where: { $0.name == name }) else {
            throw SmartContractError.invalidFunctionName(name)
        }
        
        return SmartContractFunction(abi: function)
    }
    
}

// MARK: Preloaded Contract
public extension GenericSmartContract {
    
    static let ERC20 = try! GenericSmartContract("erc20")
    static let LPPoolV3 = try! GenericSmartContract("lp-pool-v3")
    static let Multicall = try! GenericSmartContract("multicall")
    static let QuadratRouter = try! GenericSmartContract("quadrat-router")
    static let QuadratStrategy = try! GenericSmartContract("quadrat-strategy")
    
}
