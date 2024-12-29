//
//  Fonts+Utils.swift
//  Uala-Challange-iOS
//
//  Created by Jeremias on 27/12/2024.
//

import SwiftUI

enum Fonts {
    case sfCompact
    case avenir
    
    func font(size: CGFloat = 20) -> Font {
        switch self {
        case .sfCompact:
            return .custom("SFCompactText-Regular", size: size)
        case .avenir:
            return .custom("Avenir-Book", size: size)
        }
    }
}

struct FontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.font(Fonts.avenir.font()
            .weight(.medium))
    }
}
