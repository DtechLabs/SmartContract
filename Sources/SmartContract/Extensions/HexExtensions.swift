//
//  HexExtensions.swift
//  
//
//  Created by Yuri on 31.05.2023.
//
import Foundation
import BigInt

public extension BigUInt {
    init?(hex: String) {
        self.init(hex.web3.noHexPrefix.lowercased(), radix: 16)
    }
}

public extension Web3Extensions where Base == BigUInt {
    var hexString: String {
        return String(bytes: base.web3.bytes)
    }
}

public extension BigInt {
    init?(hex: String) {
        self.init(hex.web3.noHexPrefix.lowercased(), radix: 16)
    }
}

public extension Int {
    init?(hex: String) {
        self.init(hex.web3.noHexPrefix, radix: 16)
    }
}

public extension UInt {
    init?(hex: String) {
        self.init(hex.web3.noHexPrefix, radix: 16)
    }
}

public extension Web3Extensions where Base == Int {
    var hexString: String {
        return "0x" + String(format: "%x", base)
    }
}

public extension Data {
    init?(hex: String) {
        var raw = hex.web3.noHexPrefix
        if raw.count % 2 > 0 {
           raw = "0" + raw
        }
        if let byteArray = try? HexUtil.byteArray(fromHex: raw) {
            self.init(bytes: byteArray, count: byteArray.count)
        } else {
            return nil
        }
    }
}

public extension Web3Extensions where Base == Data {
    var hexString: String {
        let bytes = Array<UInt8>(base)
        return "0x" + bytes.map { String(format: "%02hhx", $0) }.joined()
    }
}

public extension String {
    init(bytes: [UInt8]) {
        self.init("0x" + bytes.map { String(format: "%02hhx", $0) }.joined())
    }
}

public extension Web3Extensions where Base == String {
    var noHexPrefix: String {
        base.hasPrefix("0x") ? String(base.dropFirst(2)) : base
    }
    
    var withHexPrefix: String {
        !base.hasPrefix("0x") ? "0x" + base : base
    }
    
    var stringValue: String {
        if let byteArray = try? HexUtil.byteArray(fromHex: base.web3.noHexPrefix), let str = String(bytes: byteArray, encoding: .utf8) {
            return str
        }
        
        return base
    }
    
    var hexData: Data? {
        let noHexPrefix = self.noHexPrefix
        guard let bytes = try? HexUtil.byteArray(fromHex: noHexPrefix) else {
            return nil
        }
        return Data(bytes)
    }
}
