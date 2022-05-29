//
//  HttpService.swift
//  MoviesApp
//
//  Created by Andrés Ruiz on 29/5/22.
//

import Foundation

protocol HttpService {
    func executeRequest(url: URL) async throws -> Data
}

// Default implementation to execute http requests
class DefaultHttpService: HttpService {
    func executeRequest(url: URL) async throws -> Data {
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}

// Implementation of the HttpService that delays requests by X seconds, for debugging and testing purposes
class SlowConnectionHttpService: HttpService {
    
    let delayNanoseconds: UInt64
    
    init(delaySeconds: UInt64 = 1) {
        self.delayNanoseconds = delaySeconds * 1_000_000_000
    }
    
    func executeRequest(url: URL) async throws -> Data {
        try? await Task.sleep(nanoseconds: delayNanoseconds)
        let (data, _) = try await URLSession.shared.data(from: url)
        return data
    }
}
