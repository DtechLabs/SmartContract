//
//  ABIRawType.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation

public enum ABIRawType: Codable, Equatable {
    case uint(bits: Int)
    case int(bits: Int)
    
    case address
    case string
    case bool
    /// if 0 - dynamic length
    case bytes(bits: UInt64)
    /// structure that should be defined in *component* field on **inputs**
    case tuple
    /// if 0 - dynamic length
    indirect case array(type: ABIRawType, length: UInt64 = 0)
    
    public enum ArraySize { // bytes for convenience
        case staticSize(UInt64)
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
    
    var isStatic: Bool {
        switch self {
        case .string: return false
        case .bytes(let bits): return bits > 0
        case .array(type: let type, length: let length):
            if length == 0 {
                return false
            }
            if !type.isStatic {
                return false
            }
            return true
        case .tuple:
//            for t in types {
//                if !t.isStatic {
//                    return false
//                }
//            }
            return true
        default:
            return true
        }
    }
    
    var memoryUsage: UInt64 {
        switch self {
        case .array(_, let length):
            if length == 0 {
                return 32
            }
            if self.isStatic {
                return 32 * length
            }
            return 32
        case .tuple:
//            if !self.isStatic {
                return 32
//            }
//            var sum: UInt64 = 0
//            for t in types {
//                sum = sum + t.memoryUsage
//            }
//            return sum
        default:
            return 32
        }
    }

    var isArray: Bool {
        switch self {
        case .array(type: _, length: _):
            return true
        default:
            return false
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
            case .bytes(let bits): return bits == 0 ? "bytes" : "bytes\(bits)"
            case .array(let type, let length): return "\(type)[\(length > 0 ? length.description : "")]"
            case .tuple: return "tuple[]"
        }
    }
    
}
