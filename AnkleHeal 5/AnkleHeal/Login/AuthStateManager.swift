//
//  AuthStateManager.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI
import Combine

enum UserRole {
    case patient
    case physiotherapist
}

class AuthStateManager: ObservableObject {
    static let shared = AuthStateManager()
    
    // Use @Published properties to trigger view updates
    @Published var isLoggedIn = false
    @Published var shouldShowRoleSelection = false
    @Published var userRole: UserRole = .physiotherapist
    @Published var currentUserID: Int = 0
    
    // Sign out function that any view can call
    func signOut() {
        // Clear any user data or tokens if needed
        currentUserID = 0
        
        // Update state to trigger navigation
        isLoggedIn = false
        shouldShowRoleSelection = true
        
        // Post a notification that can be observed by other views
        NotificationCenter.default.post(name: Notification.Name("UserDidSignOut"), object: nil)
    }
    
    // Mark user as logged in
    func signIn(as role: UserRole, userID: Int) {
        userRole = role
        currentUserID = userID
        isLoggedIn = true
        shouldShowRoleSelection = false
    }
    
    // Keep the original signIn method for backward compatibility
    func signIn() {
        isLoggedIn = true
        shouldShowRoleSelection = false
    }
}
