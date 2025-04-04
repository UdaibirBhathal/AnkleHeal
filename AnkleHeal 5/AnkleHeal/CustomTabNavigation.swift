//
//  CustomTabNavigation.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

// Main navigation view
struct MainView: View {
    @State private var selectedTab: TabItem = .home
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content based on selected tab
            VStack {
                switch selectedTab {
                case .home:
                    NavigationView {
                        PhysiotherapistHomeView()
                    }
                case .library:
                    NavigationView {
                        PhysioExerciseLibraryView()
                    }
                case .chat:
                    NavigationView {
                        ChatTabView()
                    }
                }
            }
            
            // Custom tab bar at the bottom
            ModifiedTabBar(selectedTab: $selectedTab)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

// Modified tab bar with binding
struct ModifiedTabBar: View {
    @Binding var selectedTab: TabItem
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                ForEach([TabItem.home, TabItem.library, TabItem.chat], id: \.self) { tab in
                    Spacer()
                    tabButton(tab)
                    Spacer()
                }
            }
            .padding(.vertical, 10)
            .background(Color.white)
        }
    }
    
    private func tabButton(_ tab: TabItem) -> some View {
        VStack(spacing: 4) {
            Image(systemName: tab.iconName)
                .font(.system(size: 24))
                .foregroundColor(selectedTab == tab ? primaryColor : secondaryTextColor)
            
            Text(tab.title)
                .font(.caption2)
                .foregroundColor(selectedTab == tab ? primaryColor : secondaryTextColor)
        }
        .padding(.vertical, 8)
        .onTapGesture {
            withAnimation(.easeInOut) {
                selectedTab = tab
            }
        }
    }
}

// Preview
struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
