//
//  PhysiotherapistProfileView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct PhysiotherapistProfileView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var isEditing = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var editedMobile = ""
    
    var physiotherapistID: Int
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let signOutColor = Color.red
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Image
                    Circle()
                        .fill(primaryColor)
                        .frame(width: 100, height: 100)
                        .overlay(
                            Image(systemName: "person.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        )
                        .padding(.vertical, 20)
                    
                    // User Info
                    VStack(spacing: 0) {
                        if isEditing {
                            // Editable name
                            HStack {
                                Image(systemName: "person.crop.square")
                                    .foregroundColor(secondaryTextColor)
                                    .frame(width: 30)
                                Text("Name")
                                    .foregroundColor(textColor)
                                    .frame(width: 90, alignment: .leading)
                                
                                TextField("Full Name", text: $editedName)
                                    .foregroundColor(textColor)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                            
                            Divider()
                            
                            // Editable email
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(secondaryTextColor)
                                    .frame(width: 30)
                                Text("Email")
                                    .foregroundColor(textColor)
                                    .frame(width: 90, alignment: .leading)
                                
                                TextField("Email", text: $editedEmail)
                                    .foregroundColor(textColor)
                                    .keyboardType(.emailAddress)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                            
                            Divider()
                            
                            // Editable mobile
                            HStack {
                                Image(systemName: "phone")
                                    .foregroundColor(secondaryTextColor)
                                    .frame(width: 30)
                                Text("Mobile")
                                    .foregroundColor(textColor)
                                    .frame(width: 90, alignment: .leading)
                                
                                TextField("Mobile Number", text: $editedMobile)
                                    .foregroundColor(textColor)
                                    .keyboardType(.phonePad)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                        } else {
                            // Read-only name
                            HStack {
                                HStack {
                                    Image(systemName: "person.crop.square")
                                        .foregroundColor(secondaryTextColor)
                                        .frame(width: 30)
                                    Text("Name")
                                        .foregroundColor(textColor)
                                }
                                .frame(width: 120, alignment: .leading)
                                
                                Text(physiotherapist?.name ?? "Dr. Ankush Pt")
                                    .foregroundColor(textColor)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                            
                            Divider()
                            
                            // Age
                            HStack {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(secondaryTextColor)
                                        .frame(width: 30)
                                    Text("Age")
                                        .foregroundColor(textColor)
                                }
                                .frame(width: 120, alignment: .leading)
                                
                                Text("\(calculateAge(from: physiotherapist?.dob ?? Date()))")
                                    .foregroundColor(textColor)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                            
                            Divider()
                            
                            // Email
                            HStack {
                                HStack {
                                    Image(systemName: "envelope")
                                        .foregroundColor(secondaryTextColor)
                                        .frame(width: 30)
                                    Text("Email")
                                        .foregroundColor(textColor)
                                }
                                .frame(width: 120, alignment: .leading)
                                
                                Text(physiotherapist?.email ?? "pt.ashok@gmail.com")
                                    .foregroundColor(primaryColor)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                            
                            // Mobile (added)
                            Divider()
                            
                            HStack {
                                HStack {
                                    Image(systemName: "phone")
                                        .foregroundColor(secondaryTextColor)
                                        .frame(width: 30)
                                    Text("Mobile")
                                        .foregroundColor(textColor)
                                }
                                .frame(width: 120, alignment: .leading)
                                
                                Text(physiotherapist?.mobile ?? "555-111-0000")
                                    .foregroundColor(textColor)
                                
                                Spacer()
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                    }
                    .cornerRadius(10)
                    .padding(.bottom, 20)
                    
                    // Settings
                    VStack(spacing: 0) {
                        NavigationLink(destination: AppointmentSettingsView()) {
                            HStack {
                                Text("Appointment Settings")
                                    .foregroundColor(textColor)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                        
                        Divider()
                        
                        NavigationLink(destination: SubscriptionPlanView()) {
                            HStack {
                                Text("Subscription Plan")
                                    .foregroundColor(textColor)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.vertical, 15)
                            .padding(.horizontal)
                            .background(Color.white)
                        }
                    }
                    .cornerRadius(10)
                    
                    Spacer()
                    
                    // Sign Out Button using the helper component
                    SignOutButton()
                    
                    Spacer()
                        .frame(height: 70) // Space for tab bar
                }
                .padding(.horizontal)
            }
            .navigationBarTitle("Profile", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                },
                trailing: Button(action: {
                    if isEditing {
                        saveChanges()
                    } else {
                        startEditing()
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(primaryColor)
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            .onAppear {
                // Initialize editable fields
                if let physio = physiotherapist {
                    editedName = physio.name
                    editedEmail = physio.email
                    editedMobile = physio.mobile
                }
            }
        }
    }
    
    // Helper properties
    private var physiotherapist: Physiotherapist? {
        return dataModel.getPhysiotherapist(by: physiotherapistID)
    }
    
    // Calculate age from DOB
    private func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
    
    // Start editing - prepare fields
    private func startEditing() {
        if let physio = physiotherapist {
            editedName = physio.name
            editedEmail = physio.email
            editedMobile = physio.mobile
        }
    }
    
    // Save changes
    private func saveChanges() {
        if var physio = physiotherapist {
            physio.name = editedName
            physio.email = editedEmail
            physio.mobile = editedMobile
            
            dataModel.updatePhysiotherapist(physio)
        }
    }
}

struct PhysiotherapistProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PhysiotherapistProfileView(physiotherapistID: 1)
        }
    }
}
