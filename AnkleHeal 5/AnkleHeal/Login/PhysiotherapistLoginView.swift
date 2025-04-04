//
//  PhysiotherapistLoginView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI

struct PhysiotherapistLoginView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject private var authManager = AuthStateManager.shared
    
    // Login credentials
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    
    // State for navigation and alerts
    @State private var navigateToHome = false
    @State private var navigateToSignUp = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // Colors - matching the app's design system
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        ZStack {
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            // Reset any leftover navigation state
            .onAppear {
                authManager.shouldShowRoleSelection = false
            }
            
            NavigationLink(
                destination: AppTabView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
            
            // Navigation to Sign Up
            NavigationLink(
                destination: PhysiotherapistSignUpView(),
                isActive: $navigateToSignUp
            ) {
                EmptyView()
            }
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Welcome Back")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(textColor)
                        
                        Text("Sign in to continue")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        TextField("Enter your email", text: $email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        SecureField("Enter your password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Remember me and Forgot password
                    HStack {
                        Toggle("Remember me", isOn: $rememberMe)
                            .toggleStyle(CheckboxToggleStyle())
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        Button(action: {
                            // Forgot password action
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.bottom, 10)
                    
                    // Sign in button
                    Button(action: {
                        attemptLogin()
                    }) {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(email.isEmpty || password.isEmpty ? primaryColor.opacity(0.5) : primaryColor)
                            .cornerRadius(10)
                    }
                    .disabled(email.isEmpty || password.isEmpty)
                    .padding(.top, 10)
                    
                    // Or sign in with
                    VStack(spacing: 15) {
                        Text("Or sign in with")
                            .font(.system(size: 14))
                            .foregroundColor(secondaryTextColor)
                            .padding(.vertical, 10)
                        
                        HStack(spacing: 20) {
                            // Google sign in
                            Button(action: {
                                signInWithGoogle()
                            }) {
                                HStack {
                                    Image(systemName: "g.circle.fill") // Use proper Google logo in a real app
                                        .foregroundColor(.red)
                                    Text("")
                                        .foregroundColor(textColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                            
                            // Apple sign in
                            Button(action: {
                                signInWithApple()
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .foregroundColor(.black)
                                    Text("")
                                        .foregroundColor(textColor)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                    }
                    
                    // Don't have an account
                    HStack(spacing: 5) {
                        Text("Don't have an account?")
                            .foregroundColor(secondaryTextColor)
                        
                        Button(action: {
                            navigateToSignUp = true
                        }) {
                            Text("Sign Up")
                                .foregroundColor(primaryColor)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarBackButtonHidden(true) // Hide default back button
        .navigationBarItems(
            leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(primaryColor)
            }
        )
        .alert(isPresented: $showingErrorAlert) {
            Alert(
                title: Text("Login Failed"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Attempt to login with provided credentials
    private func attemptLogin() {
        // Check if fields are empty
        if email.isEmpty || password.isEmpty {
            errorMessage = "Please enter both email and password."
            showingErrorAlert = true
            return
        }
        
        // Find physiotherapist by email (case insensitive)
        let foundPhysio = dataModel.getAllPhysiotherapists().first { physio in
            physio.email.lowercased() == email.lowercased()
        }
        
        if let physio = foundPhysio {
            // In a real app, you would verify the password
            // Here we're accepting any password for demo purposes
            authManager.signIn(as: .physiotherapist, userID: physio.id)
            navigateToHome = true
        } else {
            // For demo mode
            if email == "demo" && password == "demo" {
                if let firstPhysio = dataModel.getAllPhysiotherapists().first {
                    authManager.signIn(as: .physiotherapist, userID: firstPhysio.id)
                    navigateToHome = true
                    return
                }
            }
            
            // Failed login
            errorMessage = "Invalid email or password. Please try again."
            showingErrorAlert = true
        }
    }
    
    // Sign in with Google
    private func signInWithGoogle() {
        // In a real app, implement Google Sign In SDK integration
        // For now, just simulate success with the first physiotherapist
        if let firstPhysio = dataModel.getAllPhysiotherapists().first {
            authManager.signIn(as: .physiotherapist, userID: firstPhysio.id)
            navigateToHome = true
        }
    }
    
    // Sign in with Apple
    private func signInWithApple() {
        // In a real app, implement Apple Sign In SDK integration
        // For now, just simulate success with the first physiotherapist
        if let firstPhysio = dataModel.getAllPhysiotherapists().first {
            authManager.signIn(as: .physiotherapist, userID: firstPhysio.id)
            navigateToHome = true
        }
    }
}

// Custom toggle style for "Remember me" checkbox
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .foregroundColor(configuration.isOn ? Color(red: 0.35, green: 0.64, blue: 0.90) : .gray)
                .font(.system(size: 18))
                .onTapGesture {
                    configuration.isOn.toggle()
                }
            
            configuration.label
                .font(.system(size: 14))
        }
    }
}

struct PhysiotherapistLoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhysiotherapistLoginView()
        }
    }
}
