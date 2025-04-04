//
//  ExerciseDetailView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI
import UIKit
import AVFoundation

struct ExerciseDetailView: View {
    var patient: Patient
    var exercise: Exercise

    @State private var showCamera = false
    @State private var recordedVideoURL: URL?
    @State private var showLogExerciseView = false // State to manage LogExerciseView presentation
    @State private var showFeedbackView = false // New state for feedback view

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let url = URL(string: exercise.tutorialURL) {
                    WebView(url: url)
                        .frame(height: 250)
                        .cornerRadius(10)
                        .padding()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Previous Record")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    HStack {
                        Text("\(exercise.numberOfSets) Sets")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(AppColors.primaryColor)
                        Spacer()
                        Text("\(exercise.repsPerSet) Reps")
                            .font(.subheadline)
                            .bold()
                            .foregroundColor(AppColors.primaryColor)
                    }
                }
                .padding()
                .background(AppColors.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Details")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Text(exercise.exerciseDetails)
                        .font(.body)
                        .foregroundColor(AppColors.secondaryTextColor)
                }
                .padding()
                .background(AppColors.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Instructions")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Text(exercise.exerciseInstructions)
                        .font(.body)
                        .foregroundColor(AppColors.secondaryTextColor)
                }
                .padding()
                .background(AppColors.cardBackgroundColor)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

                if let videoURL = recordedVideoURL {
                    Text("Video Recorded: \(videoURL.lastPathComponent)")
                        .foregroundColor(AppColors.successColor)
                        .padding()

                    Button(action: {
                        sendVideoToPhysio(videoURL: videoURL)
                    }) {
                        Text("Send Video to Physiotherapist")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primaryColor)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }

                // Button row with Log Exercise and Provide Feedback
                HStack(spacing: 12) {
                    // Log Exercise button
                    Button(action: {
                        showLogExerciseView = true
                    }) {
                        VStack {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                            Text("Log Exercise")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(AppColors.primaryColor)
                        .cornerRadius(10)
                    }
                    
                    // Provide Feedback button
                    Button(action: {
                        showFeedbackView = true
                    }) {
                        VStack {
                            Image(systemName: "text.bubble.fill")
                                .font(.system(size: 24))
                            Text("Provide Feedback")
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(AppColors.buttonColor)
                        .cornerRadius(10)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 20)
            }
            .padding(.top)
        }
        .background(AppColors.backgroundColor)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showCamera = true
                }) {
                    Image(systemName: "camera")
                        .foregroundColor(AppColors.primaryColor)
                }
            }
        }
        .sheet(isPresented: $showLogExerciseView) {
            LogExerciseView(isPresented: $showLogExerciseView, patientID: patient.id, exerciseID: exercise.exerciseID)
                .environmentObject(AnkleHealDataModel.shared)
                .onDisappear {
                    // Ensure UI updates when returning from logging an exercise
                    // Using DispatchQueue to avoid view update cycles
                    DispatchQueue.main.async {
                        if let updatedPatient = AnkleHealDataModel.shared.getPatient(by: patient.id) {
                            // This triggers view update
                            AnkleHealDataModel.shared.objectWillChange.send()
                        }
                    }
                }
        }
        .sheet(isPresented: $showFeedbackView) {
            SubmitExerciseFeedbackView(
                patientID: patient.id,
                exerciseID: exercise.exerciseID,
                exerciseName: exercise.name
            )
        }
    }

    // Video sharing functionality
    private func sendVideoToPhysio(videoURL: URL) {
        // In a real app, this would upload the video to a server or cloud storage
        // and notify the physiotherapist that a new video is available
        
        print("Sending video to physiotherapist: \(videoURL)")
        
        // Show confirmation to user
        let alert = UIAlertController(
            title: "Video Sent",
            message: "Your exercise video has been sent to your physiotherapist for review.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        
        // Present the alert
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true)
        }
    }
}

// MARK: - Preview
struct PatientExerciseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleExercise = Exercise(
            exerciseID: 1,
            name: "One Leg Balance",
            duration: 5,
            intensity: 3,
            numberOfSets: 3,
            repsPerSet: 10,
            tutorialURL: "https://youtu.be/HTVVv4ESgms?si=l0dL16BmZ90dNK3p",
            exerciseDetails: "Improves ankle stability.",
            exerciseInstructions: "Stand on one leg and balance for 5 minutes."
        )

        let samplePatient = Patient(
            id: 1,
            name: "John Doe",
            dob: Date(),
            gender: .male,
            mobile: "5551234567",
            email: "johndoe@example.com",
            height: 175,
            weight: 70,
            injury: .grade2,
            currentPhysiotherapistID: 1,
            location: Location(latitude: 37.7749, longitude: -122.4194)
        )

        NavigationView {
            ExerciseDetailView(patient: samplePatient, exercise: sampleExercise)
        }
    }
}
