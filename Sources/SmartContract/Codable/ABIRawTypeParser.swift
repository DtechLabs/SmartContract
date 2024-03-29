//
//  ABIRawTypeCoder.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import Foundation

enum ABIRawTypeParser {
    
    enum BaseType: String {
        case int
        case uint
        
        case address
        case string
        case bool
        case bytes
        case tuple
    }
    
    static func parse(_ rawValue: String) throws -> ABIRawType {
        let string = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        #if DEBIG
        if string == "uint32[]" {
            print("Here is")
        }
        #endif
        if let parsed = parseArray(string) {
            let innerType = try parse(parsed.0)
            if case .tuple = innerType {
                return .tuple(types: [])
            } else {
                return parsed.1 == 0 ? .dynamicArray(ofType: innerType) : .array(type: innerType, length: parsed.1)
            }
        } else {
            if let rangeOfDigits = string.rangeOfCharacter(from: .decimalDigits) {
                // Extract the type and bit length
                let type = String(string[..<rangeOfDigits.lowerBound])
                let bitsString = String(string[rangeOfDigits.lowerBound...])
                
                guard let bits = Int(bitsString) else {
                    throw SmartContractError.rawTypeParser(rawValue)
                }
                switch type {
                    case "uint": return .uint(bits: bits)
                    case "int": return .int(bits: bits)
                    case "bytes": return .bytes(count: Int(bits))
                    default:
                        throw SmartContractError.rawTypeParser(rawValue)
                    }
            } else {
                // No digits, so it must be one of the simple types without parameters
                switch string {
                    case "address": return .address
                    case "string": return .string
                    case "bool": return .bool
                    case "tuple": return .tuple(types: [])
                    case "bytes": return .dynamicBytes
                    default:
                        throw SmartContractError.rawTypeParser(rawValue)
                }
            }
        }
    }
    
    static func parseArray(_ rawValue: String) -> (String, UInt)? {
        let regex = try! NSRegularExpression(pattern: "\\[(\\d*)\\]$", options: [])
        
        if let match = regex.firstMatch(in: rawValue, options: [], range: NSRange(rawValue.startIndex..., in: rawValue)),
           let range = Range(match.range(at: 1), in: rawValue) {
            let rawDigits = String(rawValue[range])
            let length = UInt(rawDigits) ?? 0
            return (String(rawValue.dropLast(2 + rawDigits.count)), length)
        } else {
            return nil
        }
    }
    
}
