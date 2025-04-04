//
//  PhysioExerciseLibraryView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct PhysioExerciseLibraryView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @Environment(\.presentationMode) var presentationMode
    
    @State private var exercises: [Exercise] = []
    @State private var isSelectionMode = false
    @State private var selectedExercises = Set<Int>()
    @State private var showingPatientAssignmentSheet = false
    @State private var selectedPatientID: Int? = nil
    @State private var showingFeedbackView = false // New state for feedback view

    // Colors
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            VStack(spacing: 0) {
                // Removed duplicate title here, relying on navigationBarTitle instead
                
                List {
                    ForEach(dataModel.getAllExercises(), id: \.exerciseID) { exercise in
                        if isSelectionMode {
                            // Selection mode view with checkmarks
                            HStack {
                                Image(systemName: selectedExercises.contains(exercise.exerciseID) ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(primaryColor)
                                    .onTapGesture {
                                        toggleSelection(for: exercise)
                                    }
                                VStack(alignment: .leading) {
                                    Text(exercise.name)
                                        .font(.headline)
                                        .foregroundColor(textColor)
                                    Text("\(exercise.duration) minutes")
                                        .font(.subheadline)
                                        .foregroundColor(secondaryTextColor)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 4)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                toggleSelection(for: exercise)
                            }
                        } else {
                            // Normal mode with navigation to detail view
                            NavigationLink(destination: PhysioExerciseDetailView(exercise: exercise)) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(exercise.name)
                                            .font(.headline)
                                            .foregroundColor(textColor)
                                        Text("\(exercise.duration) minutes")
                                            .font(.subheadline)
                                            .foregroundColor(secondaryTextColor)
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())

                if isSelectionMode && !selectedExercises.isEmpty {
                    Button(action: {
                        showingPatientAssignmentSheet = true
                    }) {
                        Text("Assign to Patient")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding([.horizontal, .bottom])
                    }
                }
            }
        }
        .sheet(isPresented: $showingPatientAssignmentSheet) {
            NavigationView {
                List {
                    ForEach(dataModel.patients.values.sorted(by: { $0.id < $1.id }), id: \.id) { patient in
                        Button(action: {
                            selectedPatientID = patient.id
                            dataModel.assignExercisesToPatient(
                                patientID: patient.id,
                                exerciseIDs: Array(selectedExercises)
                            )
                            showingPatientAssignmentSheet = false
                            isSelectionMode = false
                            selectedExercises.removeAll()
                        }) {
                            HStack {
                                Text(patient.name)
                                Spacer()
                                Text("ID: \(patient.id)").foregroundColor(.gray).font(.caption)
                            }
                        }
                    }
                }
                .navigationTitle("Select a Patient")
            }
        }
        .sheet(isPresented: $showingFeedbackView) {
            NavigationView {
                PhysioFeedbackView()
            }
        }
        .navigationBarTitle("Exercise Library", displayMode: .large)
        .navigationBarItems(
            leading: isSelectionMode ? Button("Cancel") {
                isSelectionMode = false
                selectedExercises.removeAll()
            } : nil,
            trailing: HStack(spacing: 16) {
                Button(action: {
                    isSelectionMode.toggle()
                    selectedExercises.removeAll()
                }) {
                    Text(isSelectionMode ? "Done" : "Select")
                        .foregroundColor(primaryColor)
                }
                
                // Bell icon for feedback
                Button(action: {
                    showingFeedbackView = true
                }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(primaryColor)
                }
                
                NavigationLink(destination: PhysiotherapistProfileView(physiotherapistID: AuthStateManager.shared.currentUserID)) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(primaryColor)
                }
            }
        )
    }

    private func toggleSelection(for exercise: Exercise) {
        if selectedExercises.contains(exercise.exerciseID) {
            selectedExercises.remove(exercise.exerciseID)
        } else {
            selectedExercises.insert(exercise.exerciseID)
        }
    }
}
