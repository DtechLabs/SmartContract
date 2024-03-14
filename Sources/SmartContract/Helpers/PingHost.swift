//
// Ping.swift
// 
// Created by Yury Dryhin on 30.11.2023
// email: yuri.drigin@icloud.com
// LinkedIn: https://www.linkedin.com/in/dtechlabs/
// Copyright © 2023 Yury Dryhin (DTechLabs). All rights reserved.
//
        
import Foundation

enum PingError: Error {
    case pingFailure
}

struct Ping {
    
    static func measure(to url: URL) async throws -> Int {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            _ = try await URLSession.shared.data(for: request)
            let endTime = CFAbsoluteTimeGetCurrent()
            return Int(endTime - startTime) * 100
        }
        catch {
            throw PingError.pingFailure
        }
    }
    
}
