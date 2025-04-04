//
//  SignOutHelper.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI

// A helper view that handles sign out logic
import SwiftUI

struct SignOutButton: View {
    @ObservedObject private var authManager = AuthStateManager.shared
    @State private var showingSignOutAlert = false
    
    var body: some View {
        Button(action: {
            showingSignOutAlert = true
        }) {
            Text("Sign Out")
                .foregroundColor(.red)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                )
                .padding()
        }
        .alert(isPresented: $showingSignOutAlert) {
            Alert(
                title: Text("Sign Out"),
                message: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign Out")) {
                    // Perform sign out using the auth manager
                    authManager.signOut()
                },
                secondaryButton: .cancel()
            )
        }
    }
}
