//
//  ABIDecoderTests.swift
//  
//
//  Created by Yuri on 01.06.2023.
//
import XCTest
import BigInt
@testable import SmartContract

final class ABIDecoderTests: XCTestCase {

    func testValueDecoderUInt256() throws {
        let expected: BigUInt = "1234567890987654321"
        let inputs = [
            "000000000000000000000000000000000000000000000000112210f4b16c1cb1",
            "000000000000000000000000000000000000000000000000112210f4b16c1cb10000000000000000000000000000000000000000000000000000000000000000"
        ]
        
        for input in inputs {
            let data = Data(hex: input)!
            XCTAssertEqual(expected, try ABIDecoder.decodeSingleType(type: .uint256, data: data).value as? BigUInt, input)
            XCTAssertEqual(32, try ABIDecoder.decodeSingleType(type: .uint(bits: 256), data: data).bytesConsumed, input)
        }
    }

    func testValueDecoderValue() throws {
        let data42 = Data(hex: "000000000000000000000000000000000000000000000000000000000000002a")!
        XCTAssertEqual(BigUInt(42), try ABIDecoder.decodeSingleType(type: .uint256, data: data42).value as? BigUInt)
        let data24 = Data(hex: "0000000000000000000000000000000000000000000000000000000000000018")!
        XCTAssertEqual(BigUInt(24), try ABIDecoder.decodeSingleType(type: .uint8, data: data24).value as? BigUInt)
        let addressData = Data(hex: "000000000000000000000000f784682c82526e245f50975190ef0fff4e4fc077")!
        XCTAssertEqual(EthereumAddress("0xf784682c82526e245f50975190ef0fff4e4fc077"), try ABIDecoder.decodeSingleType(type: .address, data: addressData).value as? EthereumAddress)
        let stringData = Data(hex: "000000000000000000000000000000000000000000000000000000000000002c48656c6c6f20576f726c64212020202048656c6c6f20576f726c64212020202048656c6c6f20576f726c64210000000000000000000000000000000000000000")!
        let decodedString = try ABIDecoder.decodeSingleType(type: .string, data: stringData)
        XCTAssertEqual("Hello World!    Hello World!    Hello World!", decodedString.value as? String)
        XCTAssertEqual(UInt64(stringData.count), decodedString.bytesConsumed)
        
        let bytesData = Data(hex: "3132333435363738393000000000000000000000000000000000000000000000")!
        let original = try ABIDecoder.decodeSingleType(type: .bytes(bits: 10), data: bytesData)
        XCTAssertEqual("0x31323334353637383930", (original.value as? Data)?.web3.hexString)
    }
    
    func testValueDecoderArrayUInt8() throws {
        let input = Data(hex: "0000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000003100000000000000000000000000000000000000000000000000000000000000320000000000000000000000000000000000000000000000000000000000000033")!
        let array = try ABIDecoder.decodeSingleType(type: .array(type: .uint8), data: input)
        XCTAssertEqual([49,50,51], array.value as? [BigUInt])
    }

    func testValueDecoderArrayAddress() throws {
        let input = Data(hex: "0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000f784682c82526e245f50975190ef0fff4e4fc0770000000000000000000000002e00cd222cb42b616d86d037cc494e8ab7f5c9a3")!
        let array = try ABIDecoder.decodeSingleType(type: .array(type: .address), data: input)
        let sample = [
            EthereumAddress("0xf784682c82526e245f50975190ef0fff4e4fc077")!,
            EthereumAddress("0x2e00cd222cb42b616d86d037cc494e8ab7f5c9a3")!,
        ]
        XCTAssertEqual(sample, array.value as? [EthereumAddress])
    }
    
    func testValueDecoderArrayBytes() throws {
        let input = Data(hex: "0000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000004000000000000000000000000000000000000000000000000000000000000000800000000000000000000000000000000000000000000000000000000000000002101100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000031022220000000000000000000000000000000000000000000000000000000000")!
        let sample = [Data(hex: "0x1011")!, Data(hex: "0x102222")!]
        let array = try ABIDecoder.decodeSingleType(type: .array(type: .bytes(bits: 0)), data: input)
        XCTAssertEqual(sample, array.value as? [Data])
    }

}
