//
//  City.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import SwiftUI
import CoreLocation

struct Coord: Codable, Hashable {
    let lon: CLLocationDegrees
    let lat: CLLocationDegrees
}

struct City: Codable {
    
    let coord: Coord
    let country: String
    var id: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case coord
        case country
        case id = "_id"
        case name
    }
    
    init(coord: Coord,
         country: String,
         id: Int,
         name: String,
         isFavorite: Bool = false) {
        self.coord = coord
        self.country = country
        self.id = id
        self.name = name
    }
    
    static func dummy(coord: Coord = Coord(lon: 0, lat: 0),
                      country: String = "CT",
                      id: Int = 1,
                      name: String = "City name",
                      isFavorite: Bool = false) -> City {

        ///It's necessary to have same ID's for what's considered "same" cities. Another solution could be implement exaclty this as the Hashable == method but that may introduce some unwanted behaviour.
        var hasher = Hasher()
        hasher.combine(name+country)
        return City(coord: coord, country: country, id: hasher.finalize(), name: name, isFavorite: isFavorite)
    }
    
}

extension City: Hashable, Identifiable {
    static func == (lhs: City, rhs: City) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//MARK: utils
extension Array where Element == City {
    /**
     Noticed many sneaky duplicated values of the same City and Country even with different IDs.
     This helper method remove those.
    */
    func removeDuplicates() -> [Element] {
        var uniqueCities = [String: Element]()
        
        for city in self {
            let key = "\(city.country.lowercased())-\(city.name.lowercased())"
            uniqueCities[key] = city
        }
        
        return Array(uniqueCities.values)
    }
    
    func sortedByNameAndCountry() -> [Element] {
        self.sorted {
            let v0 = $0.name.lowercased()
            let v1 = $1.name.lowercased()
            if v0 == v1 { return $0.country.lowercased() < $1.country.lowercased() }
            else { return v0 < v1 }
        }
    }
}
