//
//  DataProvider.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import Foundation

class DataProvider {
    
    @Published var isLoading: Bool
    private(set) var apiClient: APIClient
    
    init(isLoading: Bool = false, apiClient: APIClient = APIClient()) {
        self.isLoading = isLoading
        self.apiClient = apiClient
    }
    
    func retrieve<T: Decodable>(type: T.Type, from url: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw URLError(.badURL)
        }
        let data = try await requestData(from: url)
        return try JSONDecoder().decode(type.self, from: data)
    }
    
    func requestData(from url: URL) async throws -> Data {
        isLoading = true
        
        defer {
            self.isLoading = false
        }
        
        return try await apiClient.requestData(with: url)
    }
}
