//
//  SubmitExerciseFeedbackView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 04/04/25.
//

import SwiftUI

struct SubmitExerciseFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataModel = AnkleHealDataModel.shared
    
    let patientID: Int
    let exerciseID: Int
    let exerciseName: String
    
    @State private var painLevel: Int = 3
    @State private var feedback: String = ""
    @State private var completed: Bool = true
    @State private var showingSuccessAlert = false
    
    init(patientID: Int, exerciseID: Int, exerciseName: String) {
        self.patientID = patientID
        self.exerciseID = exerciseID
        self.exerciseName = exerciseName
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise Details")) {
                    Text(exerciseName)
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                }
                
                Section(header: Text("Did you complete the exercise?")) {
                    Toggle("Exercise Completed", isOn: $completed)
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.primaryColor))
                }
                
                Section(header: Text("Pain Level (0-10)")) {
                    VStack {
                        Text("\(painLevel)")
                            .font(.headline)
                            .foregroundColor(
                                painLevel <= 3 ? .green :
                                painLevel <= 6 ? .orange : .red
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 8)
                        
                        Slider(value: Binding(
                            get: { Double(painLevel) },
                            set: { painLevel = Int($0) }
                        ), in: 0...10, step: 1)
                        .accentColor(AppColors.primaryColor)
                        
                        HStack {
                            Text("No Pain")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Spacer()
                            
                            Text("Severe Pain")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                    }
                }
                
                Section(header: Text("Your Feedback")) {
                    TextEditor(text: $feedback)
                        .frame(minHeight: 150)
                    
                    if feedback.isEmpty {
                        Text("Please describe how the exercise felt, any difficulties you experienced, or suggestions for your physiotherapist.")
                            .font(.caption)
                            .foregroundColor(AppColors.secondaryTextColor)
                            .padding(.bottom, 8)
                    }
                }
                
                Section {
                    Button(action: submitFeedback) {
                        Text("Submit Feedback")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                feedback.isEmpty ? AppColors.primaryColor.opacity(0.5) : AppColors.primaryColor
                            )
                            .cornerRadius(10)
                    }
                    .disabled(feedback.isEmpty)
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Exercise Feedback")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .alert(isPresented: $showingSuccessAlert) {
                Alert(
                    title: Text("Feedback Submitted"),
                    message: Text("Thank you for your feedback. Your physiotherapist will review it soon."),
                    dismissButton: .default(Text("OK")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
    }
    
    private func submitFeedback() {
        // Submit the feedback to the data model
        dataModel.addExerciseFeedback(
            patientID: patientID,
            exerciseID: exerciseID,
            comment: feedback,
            painLevel: painLevel,
            completed: completed
        )
        
        // Show success alert
        showingSuccessAlert = true
    }
}

struct SubmitExerciseFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        SubmitExerciseFeedbackView(
            patientID: 1,
            exerciseID: 101,
            exerciseName: "Single Leg Balance"
        )
    }
}
