//
//  ABIItem.swift
//  
//
//  Created by Yuri on 30.05.2023.
//

import Foundation

public enum ABIItemType: String, Codable {
    case function
    case event
    case fallback
    case constructor
    case receive
}

public struct ABIFunction: Codable {
    
    public struct Input: Codable {
        public let name: String
        public let type: ABIRawType
        public let internalType: String?
        public let components: [Input]?
    }
    
    public struct Output: Codable {
        public let name: String
        public let type: ABIRawType
    }
    
    public let constant: Bool?
    public let anonymous: Bool?
    public let inputs: [Input]
    public let name: String
    public let outputs: [Output]
    public let payable: Bool?
    public let stateMutability: String
    public let type: ABIItemType
    
}

public struct ABIEvent: Codable {
    
    public struct Input: Codable {
        public let indexed: Bool
        public let internalType: String?
        public let name: String
        public let type: ABIRawType
    }
    
    public let anonymous: Bool?
    public let inputs: [Input]
    public let name: String
    public let type: ABIItemType
    
}

public struct ABIFallback: Codable {
    
    public let stateMutability: String
    public let payable: Bool?
    public let type: ABIItemType
    
}

public struct ABIConstructor: Codable {
    
    public struct Input: Codable {
        public let name: String
        public let type: String
    }
    
    public let inputs: [Input]
    public let stateMutability: String
    public let type: ABIItemType
    
}
