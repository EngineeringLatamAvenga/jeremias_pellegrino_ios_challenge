//
//  Main.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 29/12/2024.
//

import SwiftUI
import CoreLocation

struct Main: View {
    
    @State private var isPortrait: Bool = true
  
    @StateObject var viewModel: CitiesViewModel = CitiesViewModel()
    @State private var imagesStorage = ImagesStorage()
    
    @State var presentMap: Bool = false
    @State var selectedCity: City?
    @State var isSearching: Bool = false
    
    func isPortrait(_ geometry: GeometryProxy) -> Bool {
        geometry.size.width < geometry.size.height
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                NavigationStack {
                    ScrollView {
                        if viewModel.showFavorites && viewModel.filteredCities.isEmpty {
                            Text("No favorites yet")
                        } else {
                            LazyVStack {
                                ForEach(viewModel.filteredCities, id: \.id)
                                { city in
                                    CityCell(city: city)
                                        .onTapGesture {
                                            selectedCity = city
                                            if isPortrait(geometry) {
                                                presentMap = true
                                            }
                                        }
                                        .tint(Color.black)
                                }
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        FilterToolbarContent(filterFavorites: $viewModel.showFavorites,
                                             searchText: $viewModel.searchText,
                                             displaySearchBar: $isSearching)
                    }
                    .navigationDestination(isPresented: $presentMap, destination: {
                        if let binding = Binding<City>($selectedCity) {
                            MapView(city: binding)
                        }
                    })
                }
                if !isPortrait(geometry) {
                    if let binding = Binding<City>($selectedCity) {
                        MapView(city: binding)
                            .onAppear {
                                presentMap = false
                            }
                            .onDisappear {
                                presentMap = true
                            }
                    }
                    else {
                        HStack {
                            Spacer()
                            Text("Please, select a city")
                            Spacer()
                        }
                    }
                }
            }
            .environmentObject(viewModel.favoritesStorage)
            .environment(imagesStorage)
        }
    }
}
