//
//  Data+Ext.swift
//  
//
//  Created by Yuri on 05.06.2023.
//

import Foundation

public extension Data {
    
    var hexString: String { web3.hexString }
    
    func rightZeroPadding(to size: Int = 32) -> Data {
        let needSize = self.count < 32 ? 32 - self.count : 32 - self.count % 32
        return needSize == 0 ? self : self + Data(repeating: 0, count: needSize)
    }
    
    func leftZeroPadding(to size: Int = 32) -> Data {
        let needSize = self.count < 32 ? 32 - self.count : self.count - self.count % 32
        return needSize == 0 ? self : Data(repeating: 0, count: needSize) + self
    }
}
