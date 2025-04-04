//
//  AnkleHealApp.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

@main
struct AnkleHealApp: App {
    @StateObject private var authManager = AuthStateManager.shared
    @State private var shouldReset = false
    
    var body: some Scene {
        WindowGroup {
            ContentContainer(shouldReset: $shouldReset)
        }
    }
}

// Separate container view to properly apply view modifiers
struct ContentContainer: View {
    @ObservedObject private var authManager = AuthStateManager.shared
    @Binding var shouldReset: Bool
    
    var body: some View {
        ZStack {
            if authManager.shouldShowRoleSelection || shouldReset {
                // Show role selection when signed out
                RoleSelectionView()
                    .onAppear {
                        // Reset this flag after showing role selection
                        if authManager.shouldShowRoleSelection {
                            authManager.shouldShowRoleSelection = false
                        }
                    }
            } else if authManager.isLoggedIn {
                // User is signed in, show main app based on user role
                if authManager.userRole == .physiotherapist {
                    // Show physiotherapist interface
                    PhysiotherapistAppView()
                } else {
                    // Show patient interface
                    PatientAppView()
                }
            } else {
                // Default entry point
                RoleSelectionView()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidSignOut"))) { _ in
            // Force a view reset when user signs out
            shouldReset = true
            
            // Small delay to ensure clean state change
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                shouldReset = false
            }
        }
    }
}

struct PatientAppView: View {
    @ObservedObject private var authManager = AuthStateManager.shared
    
    var body: some View {
        // Use the existing HomeView which already has the TabView structure
        HomeView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                // This ensures we have access to the correct user ID
                // throughout the patient side of the app
                if let patient = AnkleHealDataModel.shared.getPatient(by: authManager.currentUserID) {
                    print("Logged in as patient: \(patient.name)")
                } else {
                    print("Warning: Could not find patient with ID \(authManager.currentUserID)")
                }
            }
    }
}

struct PhysiotherapistAppView: View {
    @ObservedObject private var authManager = AuthStateManager.shared
    
    var body: some View {
        // Use the existing AppTabView
        AppTabView()
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                // Ensure the correct physiotherapist ID is accessible
                if let physio = AnkleHealDataModel.shared.getPhysiotherapist(by: authManager.currentUserID) {
                    print("Logged in as physiotherapist: \(physio.name)")
                } else {
                    print("Warning: Could not find physiotherapist with ID \(authManager.currentUserID)")
                }
            }
    }
}
