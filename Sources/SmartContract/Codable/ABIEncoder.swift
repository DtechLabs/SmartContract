//
//  ABIEncoder.swift
//  
//
//  Created by Yuri on 06.06.2023.
//

import Foundation
import BigInt

public enum ABIEncoder {
    
    static func encodeDynamic(_ values: (ABIRawType, ABIEncodable)...) throws -> Data {
        var head = Data(repeating: 0x0, count: 32 * values.count)
        var tail = Data()
        
        var offset = head.count
        var headOffset = head.startIndex
        for (rawType, value) in values {
            let elementHeadRange = headOffset..<(headOffset + 32)
            let encodedElement = try value.encode(as: rawType)
            if rawType.isFixedSize {
                guard encodedElement.count == 32 else {
                    throw ABIEncoderError.tupleEncodingError
                }
                head.replaceSubrange(elementHeadRange, with: encodedElement)
            } else {
                tail.append(try value.encode(as: rawType))
                let elementOffset = try BigUInt(offset).encode()
                head.replaceSubrange(elementHeadRange, with: elementOffset)
                offset = head.count + tail.count
            }
            headOffset += 32
        }
        head.append(tail)
        return head
    }
    
    static func encodeDynamic(arrayOf type: ABIRawType, values: [ABIEncodable]) throws -> Data {
        guard !type.isFixedSize else {
            throw ABIEncoderError.shouldByDynamic
        }
        var head = Data(repeating: 0x0, count: 32 * values.count)
        var tail = Data()
        
        var offset = head.count
        var headOffset = head.startIndex
        for value in values {
            let elementHeadRange = headOffset..<(headOffset + 32)
            tail.append(try value.encode(as: type))
            let elementOffset = try BigUInt(offset).encode()
            head.replaceSubrange(elementHeadRange, with: elementOffset)
            offset = head.count + tail.count
            headOffset += 32
        }
        head.append(tail)
        // 32 - Offset for elements of array
        return try BigUInt(32).encode() + BigUInt(values.count).encode() + head
    }
    
}
