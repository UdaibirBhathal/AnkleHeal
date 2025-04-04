//
//  ExerciseFeedbackDetailView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 25/03/25.
//

import SwiftUI
import AVKit

struct ExerciseFeedbackDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let feedback: ExerciseFeedback?
    @State private var showingVideoPlayer = false
    
    // Sample video URL for demonstration purposes
    private var sampleVideoURL: URL? {
        Bundle.main.url(forResource: "Single Leg Stance (balance)", withExtension: "mp4")
    }

    var body: some View {
        ScrollView {
            if let feedback = feedback {
                VStack(alignment: .leading, spacing: 16) {
                    // Header with exercise name and date
                    VStack(alignment: .leading, spacing: 4) {
                        Text(feedback.exerciseName)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textColor)

                        Text(formatDate(feedback.date))
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondaryTextColor)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Video preview (tap to play)
                    if let videoURL = sampleVideoURL {
                        Button(action: {
                            showingVideoPlayer = true
                        }) {
                            ZStack {
                                // Video thumbnail (in a real app, you'd generate a thumbnail)
                                Rectangle()
                                    .fill(Color.black.opacity(0.8))
                                    .aspectRatio(16/9, contentMode: .fit)
                                    .cornerRadius(12)
                                    .overlay(
                                        Image(systemName: "play.circle.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 60, height: 60)
                                            .foregroundColor(.white)
                                    )
                                
                                Text("Tap to play exercise video")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                    .padding(8)
                                    .background(Color.black.opacity(0.6))
                                    .cornerRadius(4)
                                    .padding(12)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .sheet(isPresented: $showingVideoPlayer) {
                            VideoPlayerView(videoURL: videoURL)
                        }
                    }
                    
                    // Status indicators
                    HStack(spacing: 12) {
                        // Completion status
                        VStack(alignment: .center, spacing: 8) {
                            Image(systemName: feedback.completed ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 28))
                                .foregroundColor(feedback.completed ? AppColors.successColor : AppColors.rescheduleColor)
                            
                            Text(feedback.completed ? "Completed" : "Not completed")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Pain level
                        VStack(alignment: .center, spacing: 8) {
                            Text("\(feedback.painLevel)")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(
                                    feedback.painLevel <= 3 ? .green :
                                    feedback.painLevel <= 6 ? .orange : .red
                                )
                            
                            Text("Pain Level")
                                .font(.caption)
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Feedback comments
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Feedback")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                        
                        Text(feedback.comment)
                            .foregroundColor(AppColors.secondaryTextColor)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    // Physiotherapist response (placeholder - in a real app, this would come from the data model)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Physiotherapist Response")
                            .font(.headline)
                            .foregroundColor(AppColors.textColor)
                        
                        if let physioResponse = getPhysioResponse(for: feedback) {
                            Text(physioResponse)
                                .foregroundColor(AppColors.secondaryTextColor)
                                .fixedSize(horizontal: false, vertical: true)
                        } else {
                            Text("Your physiotherapist hasn't responded to this feedback yet.")
                                .foregroundColor(AppColors.secondaryTextColor)
                                .italic()
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 2)
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            } else {
                // Fallback view when feedback is nil
                VStack(spacing: 20) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.secondaryTextColor)
                        .padding()
                    
                    Text("Feedback Not Available")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    
                    Text("The selected feedback could not be found or has been removed.")
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(40)
            }
        }
        .background(AppColors.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
    
    // Sample function to simulate a physiotherapist response
    // In a real app, this would come from the database
    private func getPhysioResponse(for feedback: ExerciseFeedback) -> String? {
        // For demo purposes, return a response based on pain level and completion
        if feedback.painLevel > 7 {
            return "Thank you for your feedback. I'm concerned about your high pain level. Let's discuss modifying this exercise at your next appointment. In the meantime, reduce the intensity and duration."
        } else if !feedback.completed {
            return "I noticed you had trouble completing this exercise. Let's work on adjusting the difficulty level. Try reducing the repetitions to a comfortable level and gradually increase as you build strength."
        } else if feedback.painLevel < 3 && feedback.completed {
            return "Great job completing this exercise with minimal pain! This shows good progress. We'll continue with this exercise and possibly increase the intensity at your next session."
        }
        
        // Return nil to simulate no response yet
        return nil
    }
}

// Simple VideoPlayerView to display videos
//struct VideoPlayerView: View {
//    let videoURL: URL
//    @Environment(\.presentationMode) var presentationMode
//    
//    var body: some View {
//        NavigationView {
//            VideoPlayer(player: AVPlayer(url: videoURL))
//                .navigationBarTitle("Exercise Video", displayMode: .inline)
//                .navigationBarItems(trailing: Button("Done") {
//                    presentationMode.wrappedValue.dismiss()
//                })
//                .edgesIgnoringSafeArea(.all)
//        }
//    }
//}

struct ExerciseFeedbackDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseFeedbackDetailView(feedback: AnkleHealDataModel.shared.getAllExerciseFeedback().first)
        }
    }
}
