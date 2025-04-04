//
//  LibraryView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI
import AVFoundation

struct LibraryView: View {
    @ObservedObject var dataModel = AnkleHealDataModel.shared
    @State private var refreshView = false // State variable to force view refresh
    @State private var showingVideoRecorder = false
    @State private var showingVideoPreview = false
    @State private var recordedVideoURL: URL?

    let patientID: Int // Required parameter

    var body: some View {
        NavigationView {
            ZStack {
                // Background Color
                AppColors.backgroundColor
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    ScrollView {
                        if let patient = dataModel.getPatient(by: patientID) {
                            // Updated progress view component to match HomeView
                            NavigationLink(destination: ProgressTrackerView()) {
                                ProgressViewComponent(patient: patient)
                                    .padding(.vertical)
                            }

                            // Your Exercises Section
                            HStack {
                                Text("Your Exercises")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textColor)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 4)

                            VStack(spacing: 12) {
                                ForEach(patient.exercises, id: \.exerciseID) { exercise in
                                    NavigationLink(destination: ExerciseDetailView(patient: patient, exercise: exercise)) {
                                        HStack {
                                            ZStack {
                                                Circle()
                                                    .fill(AppColors.primaryColor.opacity(0.2))
                                                    .frame(width: 50, height: 50)
                                                
                                                Image(systemName: "figure.walk")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: 25, height: 25)
                                                    .foregroundColor(AppColors.primaryColor)
                                            }
                                            
                                            VStack(alignment: .leading) {
                                                Text(exercise.name)
                                                    .font(.headline)
                                                    .foregroundColor(AppColors.textColor)
                                                Text("\(exercise.duration) Minutes")
                                                    .font(.subheadline)
                                                    .foregroundColor(AppColors.secondaryTextColor)
                                            }
                                            .padding(.leading, 8)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(AppColors.secondaryTextColor)
                                        }
                                        .padding(.horizontal)
                                        .padding(.vertical, 12)
                                        .background(AppColors.cardBackgroundColor)
                                        .cornerRadius(10)
                                        .shadow(radius: 2)
                                    }
                                    .padding(.horizontal)
                                }
                                
                                // Feedback button
                                NavigationLink(destination: ExerciseFeedbackView(patientID: patient.id)) {
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(AppColors.primaryColor.opacity(0.2))
                                                .frame(width: 50, height: 50)
                                            
                                            Image(systemName: "text.bubble")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(width: 25, height: 25)
                                                .foregroundColor(AppColors.primaryColor)
                                        }
                                        
                                        Text("Exercise Feedback")
                                            .font(.headline)
                                            .foregroundColor(AppColors.textColor)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(AppColors.secondaryTextColor)
                                    }
                                    .padding()
                                    .background(AppColors.cardBackgroundColor)
                                    .cornerRadius(10)
                                    .shadow(radius: 2)
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                            }
                            .padding(.bottom, 20)
                        } else {
                            Text("Patient not found")
                                .foregroundColor(AppColors.rescheduleColor)
                                .padding()
                        }
                    }
                }
            }
            .navigationBarTitle("Library")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        // Camera Button to Record Exercise Video
                        Button(action: {
                            showingVideoRecorder = true
                        }) {
                            Image(systemName: "camera.fill")
                                .imageScale(.large)
                                .foregroundColor(AppColors.primaryColor)
                        }
                        
                        // Profile Button
                        NavigationLink(destination: ProfileView(patientID: patientID)) {
                            Image(systemName: "person.circle")
                                .imageScale(.large)
                                .foregroundColor(AppColors.primaryColor)
                        }
                    }
                }
            }
        }
        .accentColor(AppColors.primaryColor)
        .sheet(isPresented: $showingVideoRecorder) {
            VideoCameraView(isPresented: $showingVideoRecorder,
                            videoURL: $recordedVideoURL,
                            patientID: patientID)
        }
        .onChange(of: recordedVideoURL) { url in
            if let videoURL = url {
                // Process the video - save or send to physiotherapist
                processRecordedVideo(videoURL)
            }
        }
    }
    
    private func processRecordedVideo(_ videoURL: URL) {
        // In a real app, you would:
        // 1. Save the video to a specific directory
        // 2. Send the video to the assigned physiotherapist via backend
        // 3. Create a record in the data model for tracking
        
        // For this demo, we'll just log the video URL
        print("Video recorded at: \(videoURL)")
        
        // Optional: If you want to store video details in the data model
        dataModel.addPatientVideo(patientID: patientID, videoURL: videoURL)
    }
}

// Basic Video Camera View (you'll need to implement native video recording)
struct VideoCameraView: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    @Binding var videoURL: URL?
    let patientID: Int
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: VideoCameraView
        
        init(parent: VideoCameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let url = info[.mediaURL] as? URL {
                parent.videoURL = url
            }
            parent.isPresented = false
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.isPresented = false
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        
        // Check if the camera is available
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DispatchQueue.main.async {
                self.isPresented = false
            }
            return picker
        }
        
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        picker.mediaTypes = ["public.movie"]  // Ensure it's for video
        picker.videoQuality = .typeMedium
        picker.cameraCaptureMode = .video
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
