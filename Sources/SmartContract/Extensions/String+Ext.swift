//
//  String+Ext.swift
//  
//
//  Created by Yuri on 31.05.2023.
//

import Foundation

public extension String {
    
    func hasHexPrefix() -> Bool {
        self.hasPrefix("0x")
    }

    func stripHexPrefix() -> String {
        self.hasPrefix("0x") ? String(self.dropFirst(2)) : self
    }

    func addHexPrefix() -> String {
        self.hasPrefix("0x") ? self : "0x" + self
    }
    
}
