//
//  AppTabView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct AppTabView: View {
    @State private var selectedTab: TabItem = .home
    @ObservedObject private var authManager = AuthStateManager.shared
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            NavigationView {
                PhysiotherapistHomeView()
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }
            .tag(TabItem.home)
            
            // Library Tab
            NavigationView {
                PhysioExerciseLibraryView()
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "figure.strengthtraining.functional")
                Text("Library")
            }
            .tag(TabItem.library)
            
            // Chat Tab
            NavigationView {
                ChatTabView()
                    .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "bubble.left.fill")
                Text("Chat")
            }
            .tag(TabItem.chat)
        }
        .accentColor(Color(red: 0.35, green: 0.64, blue: 0.90)) // Match your primary blue color
    }
}

struct AppTabView_Previews: PreviewProvider {
    static var previews: some View {
        AppTabView()
    }
}
