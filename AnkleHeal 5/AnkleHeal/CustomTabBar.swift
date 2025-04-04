//
//  CustomTabBar.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

// Centralized TabItem enum
public enum TabItem {
    case home, library, chat
    
    var iconName: String {
        switch self {
        case .home:
            return "house.fill"
        case .library:
            return "figure.strengthtraining.functional"
        case .chat:
            return "bubble.left.fill"
        }
    }
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .library:
            return "Library"
        case .chat:
            return "Chat"
        }
    }
}
