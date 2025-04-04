//
//  PhysioFeedbackView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI
import AVKit

struct PhysioFeedbackView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var searchText = ""
    @State private var selectedPatient: Patient? = nil
    @State private var showingVideoReview = false
    
    // Get current physiotherapist's ID
    private var physiotherapistID: Int {
        return AuthStateManager.shared.currentUserID
    }
    
    // Filtered patients with submitted videos
    private var patientsWithVideos: [Patient] {
        dataModel.getAllPatients().filter { patient in
            // Only patients of the current physiotherapist
            patient.currentPhysiotherapistID == physiotherapistID &&
            // Patients with submitted videos
            !dataModel.getPatientVideos(patientID: patient.id).isEmpty
        }
    }
    
    // Filtered patients based on search text
    private var filteredPatients: [Patient] {
        if searchText.isEmpty {
            return patientsWithVideos
        } else {
            return patientsWithVideos.filter {
                $0.name.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(AppColors.secondaryTextColor)
                TextField("Search patients", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.secondaryTextColor)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .padding()
            
            if filteredPatients.isEmpty {
                // Empty state
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "video.slash")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.secondaryTextColor.opacity(0.6))
                        .padding()
                    
                    Text("No Video Submissions")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    
                    Text("Patients haven't submitted any exercise videos yet.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                // List of patients with videos
                List {
                    ForEach(filteredPatients, id: \.id) { patient in
                        Button(action: {
                            selectedPatient = patient
                            showingVideoReview = true
                        }) {
                            PatientVideoRow(patient: patient)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarTitle("Patient Videos", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            }
        )
        .background(AppColors.backgroundColor)
        .sheet(isPresented: $showingVideoReview) {
            if let patient = selectedPatient {
                NavigationView {
                    VideoReviewView(patient: patient)
                }
            }
        }
    }
}

// Row component for patients with videos
struct PatientVideoRow: View {
    let patient: Patient
    @StateObject var dataModel = AnkleHealDataModel.shared
    
    // Get patient's uploaded videos
    private var patientVideos: [PatientVideo] {
        dataModel.getPatientVideos(patientID: patient.id)
    }
    
    // Get most recent video's timestamp
    private var lastVideoTimestamp: Date {
        patientVideos.max(by: { $0.uploadDate < $1.uploadDate })?.uploadDate ?? Date()
    }
    
    var body: some View {
        HStack {
            // Patient initial/avatar
            ZStack {
                Circle()
                    .fill(AppColors.primaryColor.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Text(String(patient.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primaryColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                HStack {
                    Image(systemName: "video.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryColor)
                    
                    Text("\(patientVideos.count) Exercise Video\(patientVideos.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                    
                    Text("•")
                        .foregroundColor(AppColors.secondaryTextColor)
                    
                    Text(formatDate(lastVideoTimestamp))
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryTextColor)
                }
            }
            .padding(.leading, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.secondaryTextColor)
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

// Video Review View
struct VideoReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var dataModel = AnkleHealDataModel.shared
    let patient: Patient
    
    @State private var selectedVideo: PatientVideo?
    @State private var postureRating: Double = 5.0 // Scale 0-10
    @State private var feedbackText: String = ""
    @State private var showingSendConfirmation = false
    @State private var showingSuccessAlert = false
    
    // Computed property to get patient's videos
    private var patientVideos: [PatientVideo] {
        dataModel.getPatientVideos(patientID: patient.id)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Patient and video info
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.name)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textColor)
                        
                        Text("Exercise Videos")
                            .font(.headline)
                            .foregroundColor(AppColors.primaryColor)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Video selection section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(patientVideos, id: \.id) { video in
                            Button(action: {
                                selectedVideo = video
                            }) {
                                videoThumbnail(for: video)
                                    .overlay(
                                        selectedVideo?.id == video.id ?
                                        Color.blue.opacity(0.3) :
                                        Color.clear
                                    )
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(
                                                selectedVideo?.id == video.id ?
                                                AppColors.primaryColor :
                                                Color.clear,
                                                lineWidth: 2
                                            )
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Video player for selected video
                if let video = selectedVideo {
                    VideoPlayerView(videoURL: video.videoURL)
                        .frame(height: 250)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    
                    // Associated exercise if applicable
                    if let exerciseID = video.exerciseID,
                       let exercise = dataModel.getAllExercises().first(where: { $0.exerciseID == exerciseID }) {
                        HStack {
                            Text("Exercise:")
                                .font(.headline)
                            Text(exercise.name)
                                .font(.subheadline)
                        }
                        .padding(.horizontal)
                    }
                    
                    // Posture rating slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Posture Rating")
                                .font(.headline)
                                .foregroundColor(AppColors.textColor)
                            
                            Spacer()
                            
                            Text(String(format: "%.1f", postureRating))
                                .font(.headline)
                                .foregroundColor(getPostureColor(postureRating))
                        }
                        
                        Slider(value: $postureRating, in: 0...10, step: 0.5)
                            .accentColor(getPostureColor(postureRating))
                        
                        HStack {
                            Text("Poor")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                            
                            Spacer()
                            
                            Text("Excellent")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    // Feedback and comments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Feedback & Comments")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                        
                        TextEditor(text: $feedbackText)
                            .frame(minHeight: 150)
                            .padding(8)
                            .background(Color(UIColor.systemGray6))
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(AppColors.secondaryTextColor.opacity(0.3), lineWidth: 1)
                            )
                        
                        if feedbackText.isEmpty {
                            Text("Provide detailed feedback on form, technique, and suggestions for improvement...")
                                .font(.subheadline)
                                .foregroundColor(AppColors.secondaryTextColor.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.top, 4)
                        }
                        
                        // Send button
                        Button(action: {
                            if !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                showingSendConfirmation = true
                            }
                        }) {
                            Text("Send Feedback")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                           AppColors.primaryColor.opacity(0.5) : AppColors.primaryColor)
                                .cornerRadius(10)
                        }
                        .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || selectedVideo == nil)
                        .padding(.top, 8)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                } else {
                    // No video selected placeholder
                    VStack {
                        Image(systemName: "video")
                            .font(.system(size: 50))
                            .foregroundColor(AppColors.secondaryTextColor)
                        
                        Text("Select a video to review")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                    .background(AppColors.backgroundColor)
                    .cornerRadius(12)
                    .padding()
                }
            }
        }
        .background(AppColors.backgroundColor)
        .navigationBarTitle("Video Review", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
        )
        .alert(isPresented: $showingSendConfirmation) {
            Alert(
                title: Text("Send Feedback"),
                message: Text("Are you sure you want to send this feedback to \(patient.name)?"),
                primaryButton: .default(Text("Send")) {
                    sendFeedback()
                    showingSuccessAlert = true
                },
                secondaryButton: .cancel()
            )
        }
        .alert(isPresented: $showingSuccessAlert) {
            Alert(
                title: Text("Feedback Sent"),
                message: Text("Your feedback has been sent successfully to \(patient.name)."),
                dismissButton: .default(Text("OK")) {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    // Helper method to create video thumbnail
    private func videoThumbnail(for video: PatientVideo) -> some View {
        ZStack {
            Color.black.opacity(0.1)
            
            Image(systemName: "play.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(AppColors.primaryColor)
            
            VStack {
                Spacer()
                HStack {
                    Text(formatDate(video.uploadDate))
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(4)
                }
                .padding(4)
            }
        }
        .frame(width: 120, height: 80)
    }
    
    // Get color based on posture rating
    private func getPostureColor(_ rating: Double) -> Color {
        if rating >= 7.5 {
            return .green
        } else if rating >= 5 {
            return .orange
        } else {
            return .red
        }
    }
    
    // Format date for display
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    // Send feedback to the patient
    private func sendFeedback() {
        guard let video = selectedVideo,
              let exercise = video.exerciseID != nil ?
                    dataModel.getAllExercises().first(where: { $0.exerciseID == video.exerciseID }) : nil
        else { return }
        
        // Create a new feedback entry in the data model
        let feedbackID = Int.random(in: 10000...99999)
        let newFeedback = ExerciseFeedback(
            feedbackID: feedbackID,
            patientID: patient.id,
            exerciseID: exercise.exerciseID,
            patientName: patient.name,
            exerciseName: exercise.name,
            date: Date(),
            comment: "Video Posture Rating: \(String(format: "%.1f", postureRating))/10\n\n\(feedbackText)",
            painLevel: 0, // This would come from patient in a real scenario
            completed: true
        )
        
        // Add the feedback to the data model
        dataModel.addExerciseFeedback(newFeedback)
        
        // Optional: Send a chat message to the patient about the video feedback
        dataModel.addChatMessage(
            senderID: AuthStateManager.shared.currentUserID,
            receiverID: patient.id,
            message: "I've reviewed your exercise video for \(exercise.name) and provided detailed feedback. Please check your exercise feedback section.",
            senderName: dataModel.getPhysiotherapist(by: AuthStateManager.shared.currentUserID)?.name ?? "Physiotherapist"
        )
        
        print("✅ Feedback sent to \(patient.name) for video of exercise \(exercise.name)")
    }
}

    // Simple VideoPlayerView to display videos
    struct VideoPlayerView: View {
        let videoURL: URL
        @State private var player: AVPlayer?
        @State private var isPlaying = false
        
        var body: some View {
            VStack {
                if let player = player {
                    VideoPlayer(player: player)
                        .onAppear {
                            player.play()
                            isPlaying = true
                        }
                        .onDisappear {
                            player.pause()
                            isPlaying = false
                        }
                    
                    HStack {
                        Button(action: {
                            if isPlaying {
                                player.pause()
                                isPlaying = false
                            } else {
                                player.play()
                                isPlaying = true
                            }
                        }) {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundColor(AppColors.primaryColor)
                        }
                        
                        Slider(
                            value: Binding(
                                get: { Double(player.currentTime().seconds) },
                                set: { newValue in
                                    player.seek(to: CMTime(seconds: newValue, preferredTimescale: 1))
                                }
                            ),
                            in: 0...Double(player.currentItem?.duration.seconds ?? 0)
                        )
                        .accentColor(AppColors.primaryColor)
                    }
                    .padding()
                }
            }
            .onAppear {
                player = AVPlayer(url: videoURL)
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
        }
    }

    // Preview for SwiftUI previews
    struct PhysioFeedbackView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                PhysioFeedbackView()
            }
        }
    }
