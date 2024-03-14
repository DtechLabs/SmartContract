//
//  ABI.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 30.05.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
//

import Foundation

/// The `ABIItemType` enum is a Swift representation that categorizes different types of items defined within an Ethereum smart contract's Application Binary Interface (ABI).
/// Each case in this enumeration corresponds to a specific type of ABI item, allowing for differentiated handling of these items in the context of encoding, decoding, and interacting with smart contracts.
public enum ABIItemType: String, Codable {
    /// Represents a function in the smart contract. Functions are the most common ABI items and include both read-only (call) and state-changing (transaction) operations.
    case function
    /// Represents an event. Events are used in smart contracts to emit logs, which are then indexed and accessible outside the blockchain.
    /// They are crucial for tracking contract activity and changes in state.
    case event
    /// Represents a fallback function.
    /// The fallback function is a default function in a smart contract that is called when no other function matches the provided function signature,
    /// or if Ether is sent to the contract without any data.
    case fallback
    /// Represents the constructor of the smart contract. The constructor is a special function that is executed once upon contract creation and is used to initialize contract state.
    case constructor
    /// Represents a receive function. Introduced in Solidity 0.6.0, the receive function is a special type of fallback function that is executed when the contract receives Ether with no data.
    case receive
}

/// The `ABIFunction` struct represents the definition of a function in a smart contract's Application Binary Interface (ABI) in the Ethereum ecosystem.
/// This structure is essential for encoding and decoding calls to the blockchain, understanding the inputs and outputs of smart contract functions, and for introspection of smart contracts.
///
/// ## Usage
/// The `ABIFunction` structure is used to programmatically interact with smart contracts
/// by encoding function calls to send transactions or query state and decoding the data returned by these calls.
public struct ABIFunction: Codable {
    
    public struct Input: Codable {
        /// The name of the input parameter.
        public let name: String
        /// The ``ABIRawType`` of the input parameter, describing the solidity type.
        public let type: ABIRawType
        /// An optional String representing the internal type in Solidity, providing more detail about the type for complex types.
        public let internalType: String?
        /// An optional array of Input for types that are composed of multiple components, like structs or tuples.
        public let components: [Input]?
    }
    
    public struct Output: Codable {
        /// The name of the output parameter.
        public let name: String
        /// The ``ABIRawType`` of the output parameter, describing the solidity type.
        public let type: ABIRawType
    }
    
    /// A **Bool** indicating whether the function is constant (i.e., it does not modify the contract state).
    public let constant: Bool?
    /// A **Bool** indicating whether the event is anonymous (relevant for ABI events).
    public let anonymous: Bool?
    /// An array of  ``Input`` representing the input parameters of the function.
    public let inputs: [Input]
    /// The name of the function
    public let name: String
    /// An array of ``Output`` representing the output parameters of the function.
    public let outputs: [Output]
    /// A **Bool** indicating whether the function is payable (i.e., it can receive Ether).
    public let payable: Bool?
    /// A String describing the state mutability of the function (e.g., `pure`, `view`, `nonpayable`, `payable`).
    public let stateMutability: String
    /// An instance of ``ABIItemType`` indicating the type of the ABI item (e.g., function, event).
    public let type: ABIItemType
    
    /// A computed String that represents the function's signature, constructed from the function's name and the types of its inputs.
    public var signature: String {
        [name, "(", inputs.map { $0.type.description}.joined(separator: ","), ")"].joined()
    }
}

/// The `ABIEvent` struct is represent an event in a smart contract's Application Binary Interface (ABI) within Ethereum-based applications.
/// Events in Ethereum serve as a mechanism for emitting logs from smart contracts, which are a crucial feature for tracking contract activity
/// and state changes without modifying the blockchain state. This structure facilitates the encoding and decoding of such events,
/// allowing developers to interact with smart contract events in a type-safe and clear manner.
///
/// ## Usage
/// The `ABIEvent` struct is particularly useful in applications that need to decode logs generated by smart contract events.
public struct ABIEvent: Codable {
    
    public struct Input: Codable {
        /// A **Bool** indicating whether the input is indexed. Indexed inputs are part of the log’s topics
        /// and can be used to filter logs when querying event logs emitted by smart contracts.
        public let indexed: Bool
        /// An optional **String** that provides the internal type of the input in Solidity.
        /// This is more descriptive and specific compared to the `type`, which is more generic.
        public let internalType: String?
        /// The **String** representing the name of the input parameter. This can be used for identifying parameters when events are logged.
        public let name: String
        /// An ``ABIRawType`` representing the Solidity type of the input parameter. This is crucial for decoding the data stored in event logs.
        public let type: ABIRawType
    }
    
    /// A **Bool** optional indicating whether the event is anonymous.
    /// Anonymous events do not include the event signature as part of the log topic, which affects how these events are filtered and listened for.
    public let anonymous: Bool?
    /// An array of ``Input``, where each Input represents an input parameter of the event.
    /// Event parameters can be either indexed or not, affecting how they are stored and how they can be queried.
    public let inputs: [Input]
    /// The String representing the name of the event. This is used when emitting the event in the smart contract.
    public let name: String
    /// An instance of ``ABIItemType``, expected to be .event for ABIEvent structures.
    /// This property facilitates type safety and consistency within systems handling various ABI item types.
    public let type: ABIItemType
    
}

/// The `ABIFallback` struct is represent the fallback function within an Ethereum smart contract's Application Binary Interface (ABI).
/// The fallback function is a special feature in Ethereum smart contracts that allows the contract to react to Ethereum transactions that do not match any of the defined functions in the contract.
/// This includes transactions that are simply sending Ether to the contract without any data.
/// The ABIFallback struct provides a way to describe these fallback functions in terms of their mutability, whether they can receive Ether, and their type within the ABI framework.
public struct ABIFallback: Codable {
    
    /// A **String** indicating the mutability type of the fallback function. This can be one of several values such as "nonpayable" or "payable",
    /// indicating whether the fallback function can alter the contract's state and whether it can receive Ether, respectively.
    public let stateMutability: String
    /// A **Bool** optional that specifically indicates whether the fallback function is designed to receive Ether.
    /// This is directly related to the stateMutability property, providing a clear, boolean representation of the fallback function's ability to handle Ether transactions.
    public let payable: Bool?
    /// An instance of ``ABIItemType``, which should be .fallback for ABIFallback structures.
    /// This ensures consistency within the ABI representation, clearly identifying the item as a fallback function.
    public let type: ABIItemType
    
}

/// The `ABIConstructor` struct represents the constructor of an Ethereum smart contract within its Application Binary Interface (ABI).
/// The constructor is a special function that is executed only once when the contract is deployed to the blockchain,
/// and it's often used for initializing the contract's state, setting up initial values, or configuring access control.
public struct ABIConstructor: Codable {
    
    /// Nested Structure: Input
    public struct Input: Codable {
        /// The name of the input parameter. 
        /// While parameters in constructors often don't have names in the ABI, this property allows for named parameters in higher-level abstractions
        public let name: String
        /// The type of the input parameter as a String.
        /// This corresponds to Solidity's type system and determines how the parameter should be encoded or decoded.
        public let type: String
    }
    
    /// An array of Input instances, each representing an input parameter to the constructor.
    /// Constructors can have zero or more input parameters, allowing for dynamic initialization of the contract.
    public let inputs: [Input]
    /// A **String** indicating the state mutability of the constructor.
    /// Possible values are "nonpayable" and "payable", determining whether the constructor can receive Ether during the deployment transaction.
    public let stateMutability: String
    /// An instance of ``ABIItemType``, which for ABIConstructor structures, should always be .constructor.
    /// This property categorizes the ABI item as a constructor, distinguishing it from functions, events, and fallbacks.
    public let type: ABIItemType
    
}
