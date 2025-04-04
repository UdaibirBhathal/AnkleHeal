//
//  ChatView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 15/03/25.
//

import SwiftUI

struct ChatView: View {
    @State private var searchText = ""
    @ObservedObject var dataModel = AnkleHealDataModel.shared
    @ObservedObject private var authManager = AuthStateManager.shared
    @State private var isRefreshing: Bool = false
    
    // Colors
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(secondaryTextColor)
                        TextField("Search", text: $searchText)
                            .foregroundColor(textColor)
                    }
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                    
                    if let assignedPhysiotherapist = getAssignedPhysiotherapist() {
                        // If there's an assigned physiotherapist, show chat option
                        List {
                            NavigationLink(destination: ChatDetailView(receiverID: assignedPhysiotherapist.id)) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(assignedPhysiotherapist.name)
                                            .font(.headline)
                                            .foregroundColor(textColor)
                                        Spacer()
                                    }
                                    HStack {
                                        Text(getLastMessage(physiotherapistID: assignedPhysiotherapist.id))
                                            .font(.subheadline)
                                            .foregroundColor(secondaryTextColor)
                                            .lineLimit(1)
                                        Spacer()
                                        
                                        let unreadCount = getUnreadCount(physiotherapistID: assignedPhysiotherapist.id)
                                        if unreadCount > 0 {
                                            Text("\(unreadCount)")
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                                .padding(5)
                                                .background(primaryColor)
                                                .clipShape(Circle())
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .refreshable {
                            // Pull to refresh functionality
                            isRefreshing = true
                            // Simulate refresh delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                isRefreshing = false
                            }
                        }
                    } else {
                        // Show empty state if no physiotherapist is assigned
                        VStack(spacing: 20) {
                            Spacer()
                            
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 70))
                                .foregroundColor(.gray.opacity(0.6))
                                .padding()
                            
                            Text("No Physiotherapist Assigned")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            Text("You don't have a physiotherapist assigned yet. Please contact support for assistance.")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
            }
            .navigationTitle("Chat")
            .navigationBarItems(
                trailing: NavigationLink(destination: ProfileView(patientID: authManager.currentUserID)) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 20))
                        .foregroundColor(primaryColor)
                }
            )
            .onAppear {
                // Call the sample chat initializer to ensure we have demo messages
                // Move it out of the current render cycle
                DispatchQueue.main.async {
                    dataModel.initializeSampleChatMessages()
                }
            }
        }
    }
    
    // Helper function to get the assigned physiotherapist
    private func getAssignedPhysiotherapist() -> Physiotherapist? {
        guard let patient = dataModel.getPatient(by: AuthStateManager.shared.currentUserID),
              let physioID = patient.currentPhysiotherapistID else {
            return nil
        }
        
        return dataModel.getPhysiotherapist(by: physioID)
    }
    
    // Helper function to get the last message in a conversation
    private func getLastMessage(physiotherapistID: Int) -> String {
        let messages = dataModel.getChatMessages(between: AuthStateManager.shared.currentUserID, and: physiotherapistID)
            .sorted { $0.timestamp > $1.timestamp }
        
        return messages.first?.message ?? "No messages yet"
    }
    
    // Helper function to get the number of unread messages
    private func getUnreadCount(physiotherapistID: Int) -> Int {
        let patientID = AuthStateManager.shared.currentUserID
        return dataModel.getChatMessages(between: patientID, and: physiotherapistID)
            .filter { $0.senderID == physiotherapistID && !$0.isRead }
            .count
    }
}
