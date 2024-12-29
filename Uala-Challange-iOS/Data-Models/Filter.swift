//
//  Filter.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 28/12/2024.
//

import Foundation
import Combine

class Filter {
    /**
     Consider this a kind of a real dictionary index where you can jump directly to the array of words (cities) that starts with certain prefix.
     ie: citiesIndex["A"] -> [A Cañiza, A Coruna, A Dos Francos, etc.]
     */
    var citiesIndex: [Character: [City]] = [:]
    var noFilterCities: [City] = []

    @Published var searchText: String = ""
    @Published var showFavorites: Bool = false
    @Published var favorites: [City] = []
    
    var pageSize = 100
    
    var filteredCities: AnyPublisher<[City],Never> {
        Publishers.CombineLatest3( $searchText , $showFavorites, $favorites)
            .map { [weak self] (searchText, showFavorites, favorites) in
                guard let self = self else {
                    return []
                }
                
                //Base simplest case
                if searchText.isEmpty {
                    return showFavorites ? favorites : self.noFilterCities
                }
                
                //Filter case
                var results = self.filterPrefix(searchText, self.citiesIndex)
                
                results = showFavorites ? results.filter { favorites.contains($0) }.sortedByNameAndCountry() : results
                
                return results
            }
            .eraseToAnyPublisher()
    }
    
    private func filterPrefix(_ prefix: String, _ index: [Character: [City]]) -> [City] {
        let lowercased = prefix.lowercased()
        if index.isEmpty {
            return []
        }
        guard
            let firstLetter = lowercased.first,
            let citiesStartingWithLetter = index[firstLetter]
        else {
            return []
        }
        
        return citiesStartingWithLetter.filter {
            $0.name.lowercased().hasPrefix(lowercased)
        }
    }
    
    func setupInitialData(_ rawCities: [City]) {
        let orderedCities = rawCities.removeDuplicates().sortedByNameAndCountry()
        
        print("\(#function) count: ", orderedCities.count)
        citiesIndex = feedIndex(orderedCities)
        
        let firstIndices = citiesIndex
            .sorted { $0.key < $1.key }
            
        var landingCities = [City]()
        
        var i = 0
        while landingCities.count < pageSize && i < firstIndices.count {
            let key = firstIndices[i].key
                if let cities = citiesIndex[key] {
                    landingCities.append(contentsOf: cities)
                }
            i += 1
        }
    
        landingCities = Array(landingCities.prefix(pageSize)).sortedByNameAndCountry()
        
        print("Setting landing cities:", landingCities.count)
        noFilterCities = landingCities
        searchText = ""
    }
    
    
    func feedIndex(_ cities: [City]) -> [Character: [City]] {
        var citiesIndex: [Character: [City]] = [:]
        for city in cities {
            guard
                /**
                 Since dicts are Case-Senstive by default, and we can't rely with absolute certainty that the whole data will come properly formatted to our needs, it's necessary to canonicalizate the entry data to make sure we're storing all the cities that should match a case insenstive search prefix.
                 Otherwise, citiesIndex["a"] and citiesIndex["A"] will return different results.
                 This approach it's more simpler and error-proof than checking all the different representations cases for every input later on
                 .*/
                let char = city.name.lowercased().first
            else {
                continue
            }
            if citiesIndex[char] == nil {
                citiesIndex[char] = [city]
            }
            else {
                citiesIndex[char]?.append(city)
            }
        }
        return citiesIndex
    }
}
