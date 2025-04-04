//
//  PhysiotherapistSignUpView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI

struct PhysiotherapistSignUpView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    
    // Sign up form fields
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var experience = ""
    @State private var specialty = ""
    @State private var clinic = ""
    
    // State for navigation and alerts
    @State private var navigateToHome = false
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
            
            NavigationLink(
                destination: AppTabView()
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true),
                isActive: $navigateToHome
            ) {
                EmptyView()
            }
            
            ScrollView {
                VStack(spacing: 22) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Create Professional Account")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                        
                        Text("Sign up as a healthcare professional")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Name field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Full Name")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        TextField("Enter your name", text: $name)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
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
                        
                        SecureField("Create a password", text: $password)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Confirm Password field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        SecureField("Confirm your password", text: $confirmPassword)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Experience field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Experience (Years)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        TextField("Enter years of experience", text: $experience)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Specialty field (optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Specialty (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        TextField("e.g., Sports Rehabilitation", text: $specialty)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Clinic/Hospital field (optional)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clinic/Hospital (Optional)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(textColor)
                        
                        TextField("Enter your workplace", text: $clinic)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    
                    // Sign up button
                    Button(action: {
                        attemptSignUp()
                    }) {
                        Text("Create Account")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isFormValid ? primaryColor : primaryColor.opacity(0.5))
                            .cornerRadius(10)
                    }
                    .disabled(!isFormValid)
                    .padding(.top, 10)
                    
                    // Or sign up with text
                    Text("Or sign up with")
                        .font(.system(size: 14))
                        .foregroundColor(secondaryTextColor)
                        .padding(.vertical, 10)
                    
                    // Social sign up buttons
                    HStack(spacing: 20) {
                        // Google sign up
                        Button(action: {
                            signUpWithGoogle()
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill") // Use proper Google logo in a real app
                                    .foregroundColor(.red)
                                Text("Google")
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
                        
                        // Apple sign up
                        Button(action: {
                            signUpWithApple()
                        }) {
                            HStack {
                                Image(systemName: "apple.logo")
                                    .foregroundColor(.black)
                                Text("Apple")
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
                    
                    // Already have an account
                    HStack(spacing: 5) {
                        Text("Already have an account?")
                            .foregroundColor(secondaryTextColor)
                        
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Sign In")
                                .foregroundColor(primaryColor)
                                .fontWeight(.medium)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitle("Sign Up", displayMode: .inline)
        .navigationBarBackButtonHidden(true)
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
                title: Text("Sign Up Failed"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Computed property to check if form is valid
    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 6 && // Simple password validation
        !experience.isEmpty
    }
    
    // Attempt to sign up with provided information
    private func attemptSignUp() {
        // Validate all required fields
        if name.isEmpty || email.isEmpty || password.isEmpty || experience.isEmpty {
            errorMessage = "Please fill in all required fields."
            showingErrorAlert = true
            return
        }
        
        // Validate password match
        if password != confirmPassword {
            errorMessage = "Passwords do not match."
            showingErrorAlert = true
            return
        }
        
        // Validate password strength
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            showingErrorAlert = true
            return
        }
        
        // In a real app, you would register the user in your database
        // For now, we'll just navigate to the physiotherapist home
        navigateToHome = true
    }
    
    // Sign up with Google
    private func signUpWithGoogle() {
        // In a real app, implement Google Sign In SDK integration
        // For now, just simulate success
        navigateToHome = true
    }
    
    // Sign up with Apple
    private func signUpWithApple() {
        // In a real app, implement Apple Sign In SDK integration
        // For now, just simulate success
        navigateToHome = true
    }
}

struct PhysiotherapistSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhysiotherapistSignUpView()
        }
    }
}
