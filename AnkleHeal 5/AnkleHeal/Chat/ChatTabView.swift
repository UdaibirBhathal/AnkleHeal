//
//  ChatTabView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 25/03/25.
//

import SwiftUI

struct ChatTabView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject private var authManager = AuthStateManager.shared
    @State private var searchText = ""
    @State private var isRefreshing = false
    
    // Colors
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar with better spacing
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(secondaryTextColor)
                TextField("Search patients", text: $searchText)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(secondaryTextColor)
                    }
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(10)
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
            
            if getAssignedPatientChats().isEmpty {
                // Empty state
                VStack(spacing: 16) {
                    Spacer()
                    
                    Image(systemName: "bubble.left.and.bubble.right")
                        .font(.system(size: 70))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding()
                    
                    Text("No messages yet")
                        .font(.headline)
                        .foregroundColor(textColor)
                    
                    Text("Your conversations with patients will appear here")
                        .font(.subheadline)
                        .foregroundColor(secondaryTextColor)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(getAssignedPatientChats(), id: \.id) { chat in
                    NavigationLink(destination: PhysioChatDetailView(patientID: chat.patientID)) {
                        // Chat list row
                        HStack {
                            // Patient initial/avatar
                            ZStack {
                                Circle()
                                    .fill(primaryColor.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                Text(String(chat.patientName.prefix(1)))
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(primaryColor)
                            }
                            
                            // Name and message preview
                            VStack(alignment: .leading, spacing: 4) {
                                Text(chat.patientName)
                                    .font(.headline)
                                    .foregroundColor(textColor)
                                
                                Text(chat.lastMessage)
                                    .font(.subheadline)
                                    .foregroundColor(secondaryTextColor)
                                    .lineLimit(1)
                            }
                            .padding(.leading, 8)
                            
                            Spacer()
                            
                            // Time and unread count
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(formatTimestamp(chat.timestamp))
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                                
                                if chat.unreadCount > 0 {
                                    Text("\(chat.unreadCount)")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(primaryColor)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(PlainListStyle())
                .refreshable {
                    // Refresh the chat list
                    isRefreshing = true
                    // Simulate refresh delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        isRefreshing = false
                    }
                }
            }
        }
        .navigationBarTitle("Chats", displayMode: .large)
        .navigationBarItems(trailing:
            NavigationLink(destination: PhysiotherapistProfileView(physiotherapistID: authManager.currentUserID)) {
                Image(systemName: "person.circle")
                    .font(.system(size: 20))
                    .foregroundColor(primaryColor)
            }
        )
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            // Call the sample chat initializer to ensure we have demo messages
            // Use async to move it outside the current render cycle
            DispatchQueue.main.async {
                dataModel.initializeSampleChatMessages()
            }
        }
    }
    
    // Structure for chat data
    struct RecentChat: Identifiable {
        let id = UUID()
        let patientID: Int
        let patientName: String
        let lastMessage: String
        let timestamp: Date
        let unreadCount: Int
    }
    
    // Get only assigned patient chats
    func getAssignedPatientChats() -> [RecentChat] {
        let physioID = authManager.currentUserID
        
        // Get assigned patients
        guard let physiotherapist = dataModel.getPhysiotherapist(by: physioID) else {
            return []
        }
        
        let assignedPatientIDs = physiotherapist.patients
        
        // Process each assigned patient
        var chatList: [RecentChat] = []
        
        for patientID in assignedPatientIDs {
            if let patient = dataModel.getPatient(by: patientID) {
                // Get messages between this physio and patient
                let messages = dataModel.getChatMessages(between: physioID, and: patientID)
                    .sorted { $0.timestamp > $1.timestamp }
                
                // Create chat entry even if no messages yet
                let lastMessage = messages.first?.message ?? "No messages yet"
                let timestamp = messages.first?.timestamp ?? Date()
                
                let unreadCount = messages.filter {
                    $0.senderID == patientID && !$0.isRead
                }.count
                
                let chat = RecentChat(
                    patientID: patientID,
                    patientName: patient.name,
                    lastMessage: lastMessage,
                    timestamp: timestamp,
                    unreadCount: unreadCount
                )
                
                // Filter based on search text if needed
                if searchText.isEmpty ||
                   chat.patientName.lowercased().contains(searchText.lowercased()) ||
                   chat.lastMessage.lowercased().contains(searchText.lowercased()) {
                    chatList.append(chat)
                }
            }
        }
        
        // Sort by most recent message
        return chatList.sorted { $0.timestamp > $1.timestamp }
    }
    
    // Format timestamp for display
    func formatTimestamp(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yy"
            return formatter.string(from: date)
        }
    }
}
