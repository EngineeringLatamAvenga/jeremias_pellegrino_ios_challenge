//
//  CityCell.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 28/12/2024.
//

import SwiftUI
import CoreLocation

struct CityCell: View {

    @Environment(ImagesStorage.self) var imagesStorage
    @EnvironmentObject var favorites: FavoritesStorage
    
    var city: City
    
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("\(city.name),")
                    Text(city.country)
                        .font(Fonts.avenir.font(size: 18)).bold()
                    if let data = imagesStorage.get(city.id),
                       let uiImage = UIImage(data: data)  {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                    } else {
                        if let url = URL(string: "https://flagsapi.com/\(city.country)/flat/64.png") {
                            AsyncImage(url:url) { image in
                                image.image?
                                    .resizable()
                                    
                                    .frame(width: 20, height: 20, alignment: .center)
                                    .onAppear() {
                                        if let data = ImageRenderer(content: image.image)
                                            .uiImage?.jpegData(compressionQuality: 1) {
                                            imagesStorage.add(city.id, data)
                                        }
                                    }
                            }
                        }
                    }
                    Spacer()
                    Image(systemName: favorites.contains(city) ? "star.fill" : "star")
                        .onTapGesture {
                            favorites.contains(city) ? favorites.remove(city) : favorites.add(city)
                        }
                        .foregroundStyle(favorites.contains(city) ? Color.yellow : Color.gray)
                }
                .padding(3)
                Text("\(city.coord.lat.toStr()), \(city.coord.lon.toStr())")
                    .padding(3)
                    .font(Fonts.avenir.font(size: 16))
            }
            .padding(3)
            Spacer()
        }
        .background(Color.gray.opacity(0.1))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .cornerRadius(8)
        .padding(1)
        
    }
}

extension CLLocationDegrees {
    func toStr(format: String = "%.2f") -> String {
        return String(format: format, self)
    }
}

