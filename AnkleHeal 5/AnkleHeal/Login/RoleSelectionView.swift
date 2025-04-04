//
//  RoleSelectionView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI

struct RoleSelectionView: View {
    // State to control navigation
    @State private var navigateToPhysioLogin = false
    @State private var navigateToPatientLogin = false
    
    // Subscribe to the auth state manager
    @StateObject private var authManager = AuthStateManager.shared
    
    // Colors - matching the app's design system
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // App logo and title
                    VStack(spacing: 15) {
                        Image(systemName: "figure.walk")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(primaryColor)
                        
                        Text("AnkleHeal")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(textColor)
                        
                        Text("Choose your role to continue")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                            .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                    
                    // Role selection buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: PhysiotherapistLoginView(), isActive: $navigateToPhysioLogin) {
                            Button(action: {
                                navigateToPhysioLogin = true
                            }) {
                                RoleButton(title: "Physiotherapist", systemImage: "stethoscope", color: primaryColor)
                            }
                        }
                        
                        // For patient login
                        NavigationLink(destination: PatientLoginView(), isActive: $navigateToPatientLogin) {
                            Button(action: {
                                navigateToPatientLogin = true
                            }) {
                                RoleButton(title: "Patient", systemImage: "person", color: primaryColor)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 60)
                .onAppear {
                    // Reset auth state when this view appears
                    if authManager.shouldShowRoleSelection {
                        authManager.shouldShowRoleSelection = false
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Custom role button component
struct RoleButton: View {
    var title: String
    var systemImage: String
    var color: Color
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
                .font(.system(size: 22))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .clipShape(Circle())
                .padding(.trailing, 12)
            
            Text(title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2)) // Dark gray
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.5)) // Medium gray
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct RoleSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        RoleSelectionView()
    }
}
