//
//  ProfileView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var dataModel = AnkleHealDataModel.shared
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var editedEmail: String = ""
    @State private var editedMobile: String = ""
    let patientID: Int

    var patient: Patient? {
        dataModel.getPatient(by: patientID)
    }

    var physiotherapist: Physiotherapist? {
        if let physioID = patient?.currentPhysiotherapistID {
            return dataModel.getPhysiotherapist(by: physioID)
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            VStack {
                Spacer().frame(height: 20)

                // Profile avatar
                Circle()
                    .fill(AppColors.primaryColor)
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "person.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white)
                    )
                    .padding(.vertical, 20)

                Spacer().frame(height: 20)

                if let patient = patient {
                    List {
                        if isEditing {
                            Section {
                                TextField("Name", text: $editedName)
                                    .foregroundColor(AppColors.textColor)
                                TextField("Email", text: $editedEmail)
                                    .foregroundColor(AppColors.textColor)
                                TextField("Mobile", text: $editedMobile)
                                    .keyboardType(.numberPad)
                                    .foregroundColor(AppColors.textColor)
                            }
                        } else {
                            Section {
                                ProfileRow(label: "Name", value: patient.name, icon: "person.fill")
                                ProfileRow(label: "Date of Birth", value: formatDate(patient.dob), icon: "calendar")
                                ProfileRow(label: "Email", value: patient.email, icon: "envelope.fill")
                                ProfileRow(label: "Mobile", value: patient.mobile, icon: "phone.fill")
                                ProfileRow(label: "Doctor", value: physiotherapist?.name ?? "Not Assigned", icon: "stethoscope")
                            }
                        }

                        Section {
                            SignOutButton()
                                .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                    .scrollContentBackground(.hidden)
                    .background(AppColors.backgroundColor)
                } else {
                    Text("Patient data not available")
                        .foregroundColor(AppColors.rescheduleColor)
                        .font(.headline)
                        .padding()
                }
            }
            .background(AppColors.backgroundColor)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        saveChanges()
                    } else {
                        if let patient = patient {
                            editedName = patient.name
                            editedEmail = patient.email
                            editedMobile = patient.mobile
                        }
                    }
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Save" : "Edit")
                        .foregroundColor(AppColors.primaryColor)
                }
            }
        }
        .accentColor(AppColors.primaryColor)
    }

    func saveChanges() {
        guard var patient = patient else { return }

        patient.name = editedName
        patient.email = editedEmail
        patient.mobile = editedMobile

        dataModel.updatePatient(patient)
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}

struct ProfileRow: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        HStack {
            Label {
                Text(label)
                    .foregroundColor(AppColors.textColor)
            } icon: {
                Image(systemName: icon)
                    .foregroundColor(AppColors.secondaryTextColor)
            }
            
            Spacer()
            
            Text(value)
                .foregroundColor(AppColors.secondaryTextColor)
        }
    }
}

// MARK: - Updated SignOutButton to use consistent colors
struct UpdatedSignOutButton: View {
    @ObservedObject private var authManager = AuthStateManager.shared
    @State private var showingSignOutAlert = false
    
    var body: some View {
        Button(action: {
            showingSignOutAlert = true
        }) {
            Text("Sign Out")
                .foregroundColor(AppColors.rescheduleColor)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(AppColors.cardBackgroundColor)
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(patientID: 1)
    }
}
