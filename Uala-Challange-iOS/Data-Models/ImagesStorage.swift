//
//  ImagesStorage.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 29/12/2024.
//

import Foundation
import SwiftUI
import BackgroundTasks

@Observable
class ImagesStorage {
    
    class UserDefaultsStorage {
        func encodeAndSave(item: Codable, to key: String) throws {
            let encoded = try JSONEncoder().encode(item)
            UserDefaults.standard.set(encoded, forKey: key)
        }
        
        func loadAndDecode<T: Codable>(from key: String, to modelOfType: T.Type) throws -> T? {
            if let savedCityData = UserDefaults.standard.data(forKey: key) {
                return try JSONDecoder().decode(T.self, from: savedCityData)
            }
            return nil
        }
    }

    private var storage = UserDefaultsStorage()
    private let key = "Images"
    public private(set) var images: [Int: Data] = [:]
    
    var batchThreshold = 10
    
    init() {
        guard let images = try? storage.loadAndDecode(from: key, to: [Int: Data].self) else { return }
        self.images = images
    }
    
    func contains(_ id: Int) -> Bool {
        return images[id] != nil
    }
    
    func get (_ id: Int) -> Data? {
        images[id]
    }
    
    func add(_ id: Int, _ data: Data) {
        if let img = images[id] { return }
        images[id] = data
        save()
    }
    
    func remove(_ id: Int) {
        images.removeValue(forKey: id)
    }
    
    deinit {
        save()
    }
    
    func save() {
        if batchThreshold < 1 {
            Task {
                try? storage.encodeAndSave(item: images, to: key)
            }
            batchThreshold = 10
        } else {
            batchThreshold -= 1
            return
        }
    }
}
