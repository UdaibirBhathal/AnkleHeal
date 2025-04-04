//
//  PatientAssignmentSheet.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct PatientAssignmentSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    
    // Input properties
    let selectedExerciseIDs: [Int]
    let physiotherapistID: Int
    let onDismiss: () -> Void
    
    // State for patient selection
    @State private var patients: [Patient] = []
    @State private var selectedPatients = Set<Int>()
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Patient names header
                Text("Patient Names")
                    .font(.headline)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.gray.opacity(0.3)),
                        alignment: .bottom
                    )
                
                // Patient list
                List {
                    ForEach(patients, id: \.id) { patient in
                        AssignmentPatientRow(
                            patient: patient,
                            isSelected: selectedPatients.contains(patient.id),
                            onToggle: {
                                togglePatientSelection(patient.id)
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                
                // Assign button
                Button(action: {
                    assignExercisesToPatients()
                    onDismiss()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Assign")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                }
                .disabled(selectedPatients.isEmpty)
                .opacity(selectedPatients.isEmpty ? 0.6 : 1.0)
            }
            .background(backgroundColor)
            .navigationBarTitle("Select Patients", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    onDismiss()
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                loadPatients()
            }
        }
    }
    
    // Load patients assigned to this physiotherapist
    private func loadPatients() {
        let allPatients = dataModel.getAllPatients()
        patients = allPatients.filter { $0.currentPhysiotherapistID == physiotherapistID }
    }
    
    // Toggle patient selection
    private func togglePatientSelection(_ patientID: Int) {
        if selectedPatients.contains(patientID) {
            selectedPatients.remove(patientID)
        } else {
            selectedPatients.insert(patientID)
        }
    }
    
    // Assign selected exercises to selected patients
    private func assignExercisesToPatients() {
        for patientID in selectedPatients {
            dataModel.assignExercisesToPatient(patientID: patientID, exerciseIDs: selectedExerciseIDs)
        }
    }
}

// Row component for patient selection
struct AssignmentPatientRow: View {
    let patient: Patient
    let isSelected: Bool
    let onToggle: () -> Void
    
    // Colors
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(patient.name)
                    .font(.body)
                    .foregroundColor(textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
