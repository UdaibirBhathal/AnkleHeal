//
//  ChatDetailView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 29/03/25.
//

import SwiftUI

struct ChatDetailView: View {
    var receiverID: Int
    @ObservedObject var dataModel = AnkleHealDataModel.shared
    @ObservedObject private var authManager = AuthStateManager.shared
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var scrollToBottom = false
    
    // Colors
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    
    var physiotherapist: Physiotherapist? {
        dataModel.getPhysiotherapist(by: receiverID)
    }
    
    var patient: Patient? {
        dataModel.getPatient(by: authManager.currentUserID)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages, id: \.id) { chat in
                            ChatBubble(
                                message: chat.message,
                                timestamp: chat.timestamp,
                                isSender: chat.senderID == authManager.currentUserID
                            )
                        }
                        
                        // This is used as an anchor to scroll to the bottom
                        Color.clear
                            .frame(height: 1)
                            .id("bottomMessage")
                    }
                    .padding()
                }
                .background(backgroundColor)
                .onAppear {
                    loadMessages()
                    
                    // Move marking messages as read outside the current render cycle
                    DispatchQueue.main.async {
                        markMessagesAsRead()
                    }
                    
                    // Initial scroll to bottom
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            scrollView.scrollTo("bottomMessage", anchor: .bottom)
                        }
                    }
                }
                .onChange(of: messages.count) { _ in
                    withAnimation {
                        scrollView.scrollTo("bottomMessage", anchor: .bottom)
                    }
                }
            }
            
            // Message input
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color.white)
                    .cornerRadius(20)
                    .padding(.leading)
                    .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 1)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(primaryColor)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.trailing)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .shadow(radius: 0.5)
        }
        .navigationTitle(physiotherapist?.name ?? "Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Helper function to load messages
    private func loadMessages() {
        messages = getChatMessages()
    }
    
    // Get all messages between patient and physiotherapist
    private func getChatMessages() -> [ChatMessage] {
        return dataModel.getChatMessages(between: authManager.currentUserID, and: receiverID)
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    // Mark messages from physiotherapist as read
    private func markMessagesAsRead() {
        dataModel.markMessagesAsRead(fromSenderID: receiverID, toReceiverID: authManager.currentUserID)
    }

    // Send a new message to physiotherapist
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Important: Use the current user's ID as sender and the physiotherapist ID as receiver
        let senderID = authManager.currentUserID
        let senderName = patient?.name ?? "Patient"
        
        let messageToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        messageText = ""  // Clear input field first to improve responsiveness
        
        // Send message outside the current render cycle
        DispatchQueue.main.async {
            dataModel.addChatMessage(
                senderID: senderID,
                receiverID: receiverID,
                message: messageToSend,
                senderName: senderName
            )
            loadMessages()
            scrollToBottom = true
        }
    }
}

// Chat bubble for message display
struct ChatBubble: View {
    var message: String
    var timestamp: Date
    var isSender: Bool
    
    // Colors
    let sentBubbleColor = AppColors.primaryColor
    let receivedBubbleColor = Color(.systemGray5)
    let sentTextColor = Color.white
    let receivedTextColor = AppColors.textColor
    let timeColor = Color.gray.opacity(0.8)
    
    var body: some View {
        VStack(alignment: isSender ? .trailing : .leading) {
            HStack {
                if isSender {
                    // Sender messages (from patient) on the right
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(message)
                            .padding(12)
                            .foregroundColor(sentTextColor)
                            .background(sentBubbleColor)
                            .clipShape(BubbleShape(isSender: true))
                        
                        Text(formatTime(timestamp))
                            .font(.caption2)
                            .foregroundColor(timeColor)
                            .padding(.trailing, 4)
                    }
                } else {
                    // Received messages (from physiotherapist) on the left
                    VStack(alignment: .leading, spacing: 2) {
                        Text(message)
                            .padding(12)
                            .foregroundColor(receivedTextColor)
                            .background(receivedBubbleColor)
                            .clipShape(BubbleShape(isSender: false))
                        
                        Text(formatTime(timestamp))
                            .font(.caption2)
                            .foregroundColor(timeColor)
                            .padding(.leading, 4)
                    }
                    Spacer()
                }
            }
        }
        .padding(.vertical, 4) // Add vertical spacing between bubbles
    }
    
    // Format time
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// Custom chat bubble shape
struct BubbleShape: Shape {
    var isSender: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isSender ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        return Path(path.cgPath)
    }
}
