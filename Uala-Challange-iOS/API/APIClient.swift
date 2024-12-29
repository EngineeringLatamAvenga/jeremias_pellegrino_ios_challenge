//
//  APIClient.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import Foundation

struct HTTPResponseCode {
    
    enum HTTPResponseCategory: Error {
        case informativeResponse(Int)
        case satisfactoryResponse(Int)
        case clientError(Int)
        case redirection(Int)
        case serverError(Int)
        case other(Int)
    }
    
    let category: HTTPResponseCategory
    var isSatisfactory: Bool = false
    
    init(_ code: Int) {
        switch code {
        case 100...199:
            category = .informativeResponse(code)
        case 200...299:
            category = .satisfactoryResponse(code)
            isSatisfactory = true
        case 300...399:
            category = .redirection(code)
        case 400...499:
            category = .clientError(code)
        case 500...599:
            category = .serverError(code)
        default:
            category = .other(code)
        }
    }
}

class APIClient {
    
    init() {
        ///Persist at least 30mb of disk cache between launches to store the list and some images
        let cache = URLCache(memoryCapacity: 30 * 1024 * 1024,
                         diskCapacity: 30 * 1024 * 1024,
                         diskPath: nil)
        URLCache.shared = cache
    }
    
    /**
     May want add check conditions to verify data correctnes, etc.
     For the purposes of this challenge, the data it's loaded just once and remains constant, so... it's safe to assume we don't need to.
     */
    func requestData(with url: URL) async throws -> Data {
        if let cachedResponse = URLCache.shared.cachedResponse(for: URLRequest(url: url)) {
            return cachedResponse.data
        }
        return try await startDataTask(url: url)
    }
    
    func startDataTask(url: URL) async throws -> Data {
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let validResponse = response as? HTTPURLResponse
        else {
            throw URLError(.badServerResponse, userInfo: [:])
        }
        let responseCode = HTTPResponseCode(validResponse.statusCode)
        if !responseCode.isSatisfactory {
            throw responseCode.category
        }
        
        URLCache.shared.storeCachedResponse(CachedURLResponse(response: validResponse, data: data), for: request)
        return data
    }
}
