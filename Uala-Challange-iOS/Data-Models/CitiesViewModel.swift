//
//  CitiesViewModel.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import Combine
import Foundation

@MainActor
class CitiesViewModel: ObservableObject {
   
    let urlString = "https://gist.githubusercontent.com/hernan-uala/dce8843a8edbe0b0018b32e137bc2b3a/raw/0996accf70cb0ca0e16f9a99e0ee185fafca7af1/cities.json"
    
    //MARK: Helpers
    private let provider: DataProvider = DataProvider()
    private let filter: Filter = Filter()
    
    @Published var filteredCities: [City] = []
    @Published var searchText = ""
    @Published var showFavorites = false
    @Published var favoritesStorage: FavoritesStorage = FavoritesStorage()
        
    init() {

        Task {
            print("init, fetching")
            await fetchAndSetup()
        }
        
        filter.filteredCities.assign(to: &$filteredCities)
        $searchText.assign(to: &filter.$searchText)
        $showFavorites.assign(to: &filter.$showFavorites)
        favoritesStorage.$items.assign(to: &filter.$favorites)
    }
    
    
    private func fetchData() async -> [City] {
        do {
            return try await provider.retrieve(type: [City].self, from: urlString)
        } catch {
            ///Handle error, analytics, etc
            ///There are several options; from the most lightweight like retrieving offline data while displaying a little offline banner, to displaying a fullscreen preventing any user activity
        }
        return []
    }
    
    func fetchAndSetup() async {
        let rawCities = await fetchData()
        filter.setupInitialData(rawCities)
    }
}
