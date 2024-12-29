//
//  FavoritesStorage.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 28/12/2024.
//

import Foundation
import Combine

class FavoritesStorage: ObservableObject {
    
    typealias T = City
    
    /**Since UserDefaults could release memory on certain conditions
    we store the data in disk to make sure it doesn't get lost.*/
    private var storage = Storage()
    let key = "Favorites"
    @Published private(set) var items: [City]
    
    init() {
        self.items = []
        guard let cities = try? storage.loadAndDecode(from: key, to: [City].self)
        else { return }
        self.items = cities
    }

    func contains(_ city: City) -> Bool {
        items.contains(city)
    }

    func add(_ city: City) {
        items.append(city)
        save()
    }

    func remove(_ city: City) {
        items.removeAll { $0.id == city.id }
        save()
    }

    func save() {
       try? storage.encodeAndSave(item: items, to: key)
    }
}
