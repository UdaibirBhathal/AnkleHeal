//
//  LogExerciseView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 18/03/25.
//

import SwiftUI
struct LogExerciseView: View {
    @EnvironmentObject var dataModel: AnkleHealDataModel
    @State private var painLevel: Int = 5
    @State private var reps: Int = 15
    @State private var sets: Int = 3
    @Binding var isPresented: Bool
    var patientID: Int
    var exerciseID: Int
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Pain Level")
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                VStack {
                    GeometryReader { geometry in
                        VStack {
                            Text("\(painLevel)")
                                .font(.headline)
                                .foregroundColor(AppColors.textColor)
                                .offset(x: (geometry.size.width - 40) * CGFloat(painLevel) / 10 - geometry.size.width / 2 + 20, y: 0)
                            
                            Slider(value: Binding(
                                get: { Double(painLevel) },
                                set: { painLevel = Int($0) }
                            ), in: 0...10, step: 1)
                            .accentColor(AppColors.primaryColor)
                            .padding(.horizontal, 20)
                        }
                    }
                    .frame(height: 60)
                    
                    HStack {
                        Text("0")
                            .foregroundColor(AppColors.secondaryTextColor)
                        Spacer()
                        Text("10")
                            .foregroundColor(AppColors.secondaryTextColor)
                    }
                }
                
                HStack {
                    Text("Reps")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Spacer()
                    Stepper(value: $reps, in: 1...50) {
                        Text("\(reps)")
                            .padding()
                            .background(AppColors.primaryColor.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(AppColors.textColor)
                    }
                }
                
                HStack {
                    Text("Sets")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Spacer()
                    Stepper(value: $sets, in: 1...10) {
                        Text("\(sets)")
                            .padding()
                            .background(AppColors.primaryColor.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(AppColors.textColor)
                    }
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .background(AppColors.backgroundColor)
            .navigationTitle("Log Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(AppColors.rescheduleColor)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        dataModel.logExercise(
                            patientID: patientID,
                            exerciseID: exerciseID,
                            reps: reps,
                            sets: sets,
                            painLevel: painLevel
                        )
                        
                        DispatchQueue.main.async {
                            dataModel.calculateTodayProgress(for: patientID)
                            dataModel.objectWillChange.send()
                        }
                        
                        isPresented = false
                    }
                    .foregroundColor(AppColors.primaryColor)
                }
            }
        }
        .accentColor(AppColors.primaryColor)
    }
}

struct LogExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        LogExerciseView(isPresented: .constant(true), patientID: 1, exerciseID: 1)
            .environmentObject(AnkleHealDataModel.shared)
    }
}
