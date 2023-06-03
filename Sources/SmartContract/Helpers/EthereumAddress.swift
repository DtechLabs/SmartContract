//
//  EthereumAddress.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import Foundation

public struct EthereumAddress {
    
    private let _address: String
    public var type: AddressType = .normal
    public static let zero = EthereumAddress("0x0000000000000000000000000000000000000000")
    
    var abiData: Data? {
        let address = padAddress()
        guard let data = Data(hex: address.web3.noHexPrefix) else {
            return nil
        }
        return data
    }
    
    /// Raw representation of the address.
    /// If the ``type`` is ``EthereumAddress/AddressType/contractDeployment`` an empty `Data` object is returned.
    public var addressData: Data {
        get {
            switch self.type {
                case .normal:
                    return Data(hex: _address)
                case .contractDeployment:
                    return Data()
            }
        }
    }
    
    private func padAddress() -> String {
        let targetBytesLength = 32
        let current = Data(hex: _address)!
        guard current.count <= targetBytesLength else {
            return _address
        }
        return (Data(repeating: 0, count: targetBytesLength - current.count).bytes + current).web3.hexString
    }
    
    
    /// Checksummed address with `0x` HEX prefix.
    /// If the ``type`` is ``EthereumAddress/AddressType/contractDeployment`` only `0x` prefix is returned.
    public var address: String {
        switch self.type {
        case .normal:
            return EthereumAddress.toChecksumAddress(_address)!
        case .contractDeployment:
            return "0x"
        }
    }

    /// Validates and checksums given `addr`.
    /// If given string is not an address, incomplete address or is invalid validation will fail and `nil` will be returned.
    /// - Parameter addr: address in string format, case insensitive, `0x` prefix is not required.
    /// - Returns: validates and checksums the address. Returns `nil` if checksum has failed or given string cannot be
    /// represented as `ASCII` data. Otherwise, checksummed address is returned with `0x` prefix.
    public static func toChecksumAddress(_ address: String) -> String? {
        let address = address.lowercased().stripHexPrefix()
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString().stripHexPrefix() else {
            return nil
        }
        var ret = "0x"

        for (i, char) in address.enumerated() {
            let startIdx = hash.index(hash.startIndex, offsetBy: i)
            let endIdx = hash.index(hash.startIndex, offsetBy: i+1)
            let hashChar = String(hash[startIdx..<endIdx])
            let c = String(char)
            guard let int = Int(hashChar, radix: 16) else { return nil }
            if int >= 8 {
                ret += c.uppercased()
            } else {
                ret += c
            }
        }
        return ret
    }
    
}

public extension EthereumAddress {
    
    enum AddressType {
        case normal
        case contractDeployment
    }
    
    init?(_ addressData: Data, type: AddressType = .normal) {
        guard addressData.count == 20 else { return nil }
        self._address = addressData.toHexString().web3.withHexPrefix
        self.type = type
    }
    
    init?(_ addressString: String, type: AddressType = .normal, ignoreChecksum: Bool = false) {
        switch type {
            case .normal:
                guard let data = Data(hex: addressString) else {
                    return nil
                }
                guard data.count == 20 else { return nil }
                if !addressString.hasHexPrefix() {
                    return nil
                }
                if !ignoreChecksum {
                    // check for checksum
                    if data.toHexString() == addressString.stripHexPrefix() {
                        self._address = data.toHexString().addHexPrefix()
                        self.type = .normal
                        return
                    } else if data.toHexString().uppercased() == addressString.stripHexPrefix() {
                        self._address = data.toHexString().addHexPrefix()
                        self.type = .normal
                        return
                    } else {
                        let checksummedAddress = EthereumAddress.toChecksumAddress(data.toHexString().addHexPrefix())
                        guard checksummedAddress == addressString else { return nil }
                        self._address = data.toHexString().addHexPrefix()
                        self.type = .normal
                        return
                    }
                } else {
                    self._address = data.toHexString().addHexPrefix()
                    self.type = .normal
                    return
                }
                // TODO: Where it ever set?
            case .contractDeployment:
                self._address = "0x"
                self.type = .contractDeployment
        }
    }
}

extension EthereumAddress: Codable, Hashable {
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self._address = try container.decode(String.self).lowercased()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self._address)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self._address)
    }
    
    public static func ==(lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.addressData == rhs.addressData && lhs.type == rhs.type
    }
}
