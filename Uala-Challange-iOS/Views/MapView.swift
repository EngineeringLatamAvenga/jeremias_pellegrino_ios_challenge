//
//  MapView.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 29/12/2024.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    
    @Binding var city: City
    @EnvironmentObject var favorites: FavoritesStorage
    
    private var position = MapCameraPosition.automatic
    
    init(city: Binding<City>) {
        self._city = city
        let location = CLLocationCoordinate2D(latitude: self.city.coord.lat,
                                              longitude: self.city.coord.lon)
        let region = MKCoordinateRegion(
            center: location,
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        position = .region(region)
        print(city.wrappedValue.name, city.wrappedValue.coord)
    }
  
    var body: some View {
        Map(position: Binding.constant(position)) {
            Marker(city.name, coordinate: CLLocationCoordinate2D(latitude: city.coord.lat, longitude: city.coord.lon))
        }
        .navigationTitle(city.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: favorites.contains(city) ? "star.fill" : "star")
                    .onTapGesture {
                        favorites.contains(city) ? favorites.remove(city) : favorites.add(city)
                    }
                    .foregroundStyle(favorites.contains(city) ? Color.yellow : Color.gray)
            }
        }
    }
}
