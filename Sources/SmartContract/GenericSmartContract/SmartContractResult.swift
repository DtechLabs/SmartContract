//
//  SmartContractResult.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 16.08.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
//

import Foundation

/// **SmartContractResult** is a structure that encapsulates the output values returned from a smart contract function call. This structure provides a flexible way to access the outputs, catering to both named and unnamed output values.
///
/// To retrieve a specific output value, you can access it by its `name`. This is particularly useful when dealing with smart contract functions that return multiple named outputs. On the other hand, if the function returns a single unnamed output, you can obtain it using the `value` property.
///
/// Examples:
///
/// - Accessing a single unnamed output:
/// ```swift
/// // Call a smart contract function that returns a single unnamed output (e.g., the name of an ERC20 token).
/// let result = erc20("name")
/// // Assuming the output is of type String, you can access it directly via the `value` property.
/// let name: String = result.value!
/// ```
///
/// - Accessing multiple named outputs:
/// ```swift
/// // Call a smart contract function that returns multiple named outputs.
/// // Example: A function that returns the minting amounts and token addresses for a given strategy, token address, and amount.
/// let result = try await contract("getMintAmounts", strategy, tokenAddress, amount)
/// // Access each output by its name. Here, we assume the outputs are of types BigUInt and EthereumAddress.
/// let amount0: BigUInt = result.amount0!
/// let amount1: BigUInt = result.amount1!
/// let token0: EthereumAddress = result.token0!
/// let token1: EthereumAddress = result.token1!
/// ```
@dynamicMemberLookup public struct SmartContractResult {
    
    let values: [String: ABIDecodable]
    let outputs: [ABIFunction.Output]
    
    init(values: [ABIDecodable], outputs: [ABIFunction.Output]) throws {
        guard outputs.count == values.count else {
            throw SmartContractError.wrongFunctionOutputsCount
        }
        
        self.outputs = outputs
        
        if outputs.count == 1 && outputs.first?.name == "" {
            self.values = ["value": values[0]]
        } else {
            self.values = Dictionary(uniqueKeysWithValues: zip(outputs.map { $0.name }, values))
        }
    }
    
    public subscript<T: ABIDecodable>(dynamicMember name: String) -> T? {
        return values[name] as? T
    }
    
    /// Return  a single unnamed output:
    ///
    /// ```swift
    /// let result = erc20("name")
    /// // Assuming the output is of type String, you can access it directly via the `value` property.
    /// let name: String = result.value!
    /// ```
    ///
    /// - Returns: Unnamed output value supported ABIDecodable
    public var value: ABIDecodable? {
        values["value"]
    }
    
}
