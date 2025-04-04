//
//  ExerciseFeedbackView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 25/03/25.
//

import SwiftUI

struct ExerciseFeedbackView: View {
    @ObservedObject private var dataModel = AnkleHealDataModel.shared
    let patientID: Int

    @State private var selectedFeedback: ExerciseFeedback?
    @State private var navigateToDetail = false
    @State private var searchText = ""

    var body: some View {
        ZStack {
            AppColors.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(AppColors.secondaryTextColor)
                    TextField("Search feedback", text: $searchText)
                    
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
                
                if filteredFeedback.isEmpty {
                    emptyFeedbackView
                } else {
                    feedbackListView
                }
            }
        }
        .navigationTitle("Exercise Feedback")
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: ExerciseFeedbackDetailView(feedback: selectedFeedback),
                isActive: $navigateToDetail
            ) { EmptyView() }
            .hidden()
        )
    }
    
    private var filteredFeedback: [ExerciseFeedback] {
        let allFeedback = dataModel.getExerciseFeedback(for: patientID)
        
        if searchText.isEmpty {
            return allFeedback.sorted(by: { $0.date > $1.date }) // Sort by date, newest first
        } else {
            return allFeedback.filter { feedback in
                feedback.exerciseName.lowercased().contains(searchText.lowercased()) ||
                feedback.comment.lowercased().contains(searchText.lowercased())
            }.sorted(by: { $0.date > $1.date })
        }
    }
    
    private var emptyFeedbackView: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "text.bubble")
                .font(.system(size: 70))
                .foregroundColor(AppColors.secondaryTextColor.opacity(0.6))
                .padding()
            
            Text("No Feedback Yet")
                .font(.headline)
                .foregroundColor(AppColors.textColor)
            
            Text("Your exercise feedback history will appear here.")
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryTextColor)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    private var feedbackListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(filteredFeedback) { feedback in
                    FeedbackCard(feedback: feedback)
                        .onTapGesture {
                            selectedFeedback = feedback
                            navigateToDetail = true
                        }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
    }
}

struct FeedbackCard: View {
    let feedback: ExerciseFeedback
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Exercise name and date
                VStack(alignment: .leading, spacing: 4) {
                    Text(feedback.exerciseName)
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    
                    Text(formatDate(feedback.date))
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                }
                
                Spacer()
                
                // Pain level indicator
                PainLevelBadge(level: feedback.painLevel)
            }
            
            Divider()
            
            // Preview of comment
            Text(feedback.comment.prefix(100) + (feedback.comment.count > 100 ? "..." : ""))
                .font(.subheadline)
                .foregroundColor(AppColors.secondaryTextColor)
                .lineLimit(2)
            
            // Completion badge
            CompletionBadge(isCompleted: feedback.completed)
                .padding(.top, 4)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}

struct PainLevelBadge: View {
    let level: Int
    
    var body: some View {
        Text("Pain: \(level)/10")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                level <= 3 ? Color.green.opacity(0.2) :
                level <= 6 ? Color.orange.opacity(0.2) :
                Color.red.opacity(0.2)
            )
            .foregroundColor(
                level <= 3 ? Color.green :
                level <= 6 ? Color.orange :
                Color.red
            )
            .cornerRadius(8)
    }
}

struct CompletionBadge: View {
    let isCompleted: Bool
    
    var body: some View {
        Text(isCompleted ? "Completed" : "Not Completed")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isCompleted ?
                AppColors.successColor.opacity(0.2) :
                AppColors.rescheduleColor.opacity(0.2)
            )
            .foregroundColor(
                isCompleted ?
                AppColors.successColor :
                AppColors.rescheduleColor
            )
            .cornerRadius(8)
    }
}

struct ExerciseFeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExerciseFeedbackView(patientID: 1)
        }
    }
}
