//
//  ExerciseDetailView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct PhysioExerciseDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var showingPatientSelectionSheet = false
    
    let exercise: Exercise
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Exercise information
                VStack(alignment: .leading, spacing: 15) {
                    Text(exercise.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(textColor)
                    
                    Text(exercise.exerciseDetails)
                        .font(.body)
                        .foregroundColor(secondaryTextColor)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Text(exercise.exerciseInstructions)
                            .font(.body)
                            .foregroundColor(secondaryTextColor)
                    }
                    
                    Divider()
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("\(exercise.duration)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                            
                            Text("Minutes")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        VStack {
                            Text("\(exercise.numberOfSets)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                            
                            Text("Sets")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                        }
                        
                        VStack {
                            Text("\(exercise.repsPerSet)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(primaryColor)
                            
                            Text("Reps")
                                .font(.caption)
                                .foregroundColor(secondaryTextColor)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                // Assign button - FIXED to actually show the patient selection sheet
                Button(action: {
                    showingPatientSelectionSheet = true
                }) {
                    Text("Assign to Patient")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top)
                .sheet(isPresented: $showingPatientSelectionSheet) {
                    MultiPatientSelectionView(exerciseIDs: [exercise.exerciseID])
                }
            }
            .padding()
            .navigationBarTitle("Exercise Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Library")
                    }
                    .foregroundColor(primaryColor)
                }
            )
            .navigationBarBackButtonHidden(true)
        }
        .background(backgroundColor)
    }
}

// New view that allows selecting multiple patients
struct MultiPatientSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject var authManager = AuthStateManager.shared
    
    let exerciseIDs: [Int]
    @State private var selectedPatients = Set<Int>()
    
    // Current physiotherapist ID
    private var physiotherapistID: Int {
        return authManager.currentUserID
    }
    
    // Get patients assigned to this physiotherapist
    private var assignedPatients: [Patient] {
        dataModel.getAllPatients().filter { $0.currentPhysiotherapistID == physiotherapistID }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    // FIXED: Allow multi-selection
                    ForEach(assignedPatients, id: \.id) { patient in
                        MultiSelectPatientRow(
                            patient: patient,
                            isSelected: selectedPatients.contains(patient.id),
                            onToggle: {
                                togglePatientSelection(patient.id)
                            }
                        )
                    }
                }
                .listStyle(PlainListStyle())
                
                // Assign button at bottom
                Button(action: {
                    assignExercisesToSelectedPatients()
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Assign Exercise\(selectedPatients.count > 1 ? "s" : "")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedPatients.isEmpty ? Color.gray : AppColors.primaryColor)
                        .cornerRadius(10)
                        .padding()
                }
                .disabled(selectedPatients.isEmpty)
            }
            .navigationTitle("Select Patients")
            .navigationBarItems(leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // Toggle patient selection
    private func togglePatientSelection(_ patientID: Int) {
        if selectedPatients.contains(patientID) {
            selectedPatients.remove(patientID)
        } else {
            selectedPatients.insert(patientID)
        }
    }
    
    // Assign exercises to all selected patients
    private func assignExercisesToSelectedPatients() {
        for patientID in selectedPatients {
            dataModel.assignExercisesToPatient(
                patientID: patientID,
                exerciseIDs: exerciseIDs
            )
        }
    }
}

// Row component for multi-selection
struct MultiSelectPatientRow: View {
    let patient: Patient
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(patient.name)
                    .foregroundColor(AppColors.textColor)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primaryColor)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(AppColors.secondaryTextColor)
                }
            }
            .contentShape(Rectangle())
            .padding(.vertical, 10)
        }
    }
}
