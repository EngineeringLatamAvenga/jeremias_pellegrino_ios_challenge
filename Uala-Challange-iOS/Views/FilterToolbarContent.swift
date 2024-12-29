//
//  FilterToolbarContent.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 29/12/2024.
//

import SwiftUI

struct FilterToolbarContent: ToolbarContent {
    
    @Binding var filterFavorites: Bool
    @Binding var searchText: String
    @Binding var displaySearchBar: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
                if displaySearchBar {
                    HStack(spacing: 0) {
                        TextField("Search cities... ", text: $searchText)
                            .padding(.leading, 4)
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                        Image(systemName: "delete.backward")
                            .resizable()
                            .scaledToFit()
                            .onTapGesture {
                                searchText = ""
                            }
                        Spacer()
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                    .frame(height: 14)
                } else {
                    Text("Cities")
                }
        }
        ToolbarItem(placement: .topBarTrailing) {
            HStack {
                Image(systemName: displaySearchBar ? "magnifyingglass.circle.fill": "magnifyingglass.circle" )
                    .onTapGesture {
                        displaySearchBar.toggle()
                        if !displaySearchBar {
                            searchText = ""
                        }
                    }
                    .foregroundStyle(displaySearchBar ? Color.gray : Color.black)
                Image(systemName: filterFavorites ? "star.fill" : "star")
                    .onTapGesture {
                        filterFavorites.toggle()
                    }
                    .foregroundStyle(filterFavorites ? Color.yellow : Color.black)
            }
        }
    }
}
