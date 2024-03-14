//
//  ABIRawType.swift
//  SmartContract Framework
//
//  Created by Yury Dryhin aka DTechLabs on 31.05.2023.
//  email: yuri.drigin@icloud.com; LinkedIn: https://www.linkedin.com/in/dtechlabs/
//

import Foundation
import BigInt

/// The EVM operates on 256-bit words, which is equivalent to 32 bytes.
/// It was built this way in order to handle large numbers efficiently, which is often required in cryptographic computations.
public let EVMWordSize: UInt = 32

public enum ABIRawType: Codable, Equatable {
    /// An unsigned integer between 8 and 256 bits long, padded left to 32 bytes while encoding.
    case uint(bits: Int)
    /// A two’s complement signed integer between 8 and 256 bits long, padded left to 32 bytes while encoding.
    case int(bits: Int)
    /// A 20 bytes hexadecimal, encoded like an uint160.
    case address
    /// A string is encoded in UTF8 and then treated has a bytes type. The number of bytes represents here the number of characters in the string.
    case string
    /// An uint8 where 0 is used for false and 1 for true.
    case bool
    /// Static bytes array
    case bytes(count: Int)
    /// Dynamic Bytes array
    case dynamicBytes
    /// structure that should be defined in *component* field on **inputs**
    indirect case tuple(types: [ABIRawType])
    ///
    indirect case array(type: ABIRawType, length: UInt)
    indirect case dynamicArray(ofType: ABIRawType)
    
    public enum ArraySize { // bytes for convenience
        case staticSize(UInt)
        case dynamicSize
        case notArray
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        do {
            self = try ABIRawTypeParser.parse(rawValue)
        } catch {
            throw DecodingError.typeMismatch(ABIRawType.self, DecodingError.Context(codingPath: container.codingPath, debugDescription: rawValue))
        }
    }
    
    var isUnsignedInteger: Bool {
        switch self {
            case .uint: return true
            default: return false
        }
    }
    
    var isSignedInteger: Bool {
        switch self {
            case .int: return true
            default: return false
        }
    }
    
    var bitsCount: Int {
        switch self {
            case .int(let bits), .uint(let bits): return bits
            case .address: return 32
            case .bool: return 256
            default: return -1
        }
    }
    
    var isFixedSize: Bool {
        switch self {
            case .string: return false
            case .bytes: return true
            case .dynamicBytes: return false
            case .array(type: let type, _), .dynamicArray(let type):
                return type.isFixedSize
            case .tuple(let types):
                for t in types {
                    if !t.isFixedSize {
                        return false
                    }
                }
                return true
            default:
                return true
        }
    }
    
    var isArray: Bool {
        switch self {
            case .dynamicArray, .array: return true
            default: return false
        }
    }
    
    var memoryUsage: UInt {
        switch self {
        case .array(_, let length):
                if self.isFixedSize {
                    return 32 * length
                }
                return 32
            case .dynamicArray:
                return 32
        case .tuple(let types):
            if !self.isFixedSize {
                return 32
            }
            var sum: UInt = 0
            for t in types {
                sum = sum + t.memoryUsage
            }
            return sum
        default:
            return 32
        }
    }
    
    var decodableType: ABIDecodable.Type? {
        switch self {
            case .uint: return BigUInt.self
            case .int: return BigInt.self
            case .bool: return Bool.self
            case .address: return EthereumAddress.self
            case .string: return String.self
            case .bytes, .dynamicBytes: return Data.self
            default:
                return nil
        }
    }
    
    /// Type of Element in Array
    var innerType: ABIRawType? {
        switch self {
        case .array(let type, _), .dynamicArray(let type):
            return type
        default:
            return nil
        }
    }

    var isTuple: Bool {
        switch self {
        case .tuple:
            return true
        default:
            return false
        }
    }
    
    var arraySize: ArraySize {
        switch self {
        case .array(_, let length):
            if length == 0 {
                return .dynamicSize
            }
            return .staticSize(length)
        default:
            return .notArray
        }
    }
}

// MARK: - Useful type alias
public extension ABIRawType {
    
    static let uint8 = ABIRawType.uint(bits: 8)
    static let uint16 = ABIRawType.uint(bits: 16)
    static let uint32 = ABIRawType.uint(bits: 32)
    static let uint64 = ABIRawType.uint(bits: 64)
    static let uint160 = ABIRawType.uint(bits: 160)
    static let uint256 = ABIRawType.uint(bits: 256)
    
}

// MARK: - String convertible
extension ABIRawType: CustomStringConvertible {
    
    public var description: String {
        switch self {
            case .uint(let bits): return "uint\(bits)"
            case .int(let bits): return "int\(bits)"
            case .address: return "address"
            case .string: return "string"
            case .bool: return "bool"
            case .bytes(let bits): return "bytes\(bits)"
            case .dynamicBytes: return "bytes"
            case .array(let type, let length): return "\(type)[\(length)]"
            case .dynamicArray(let type): return "\(type)[]"
            case .tuple: return "tuple[]"
        }
    }
    
}
