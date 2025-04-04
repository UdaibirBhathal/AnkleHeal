//
//  PhysioChatDetailView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 29/03/25.
//

import SwiftUI

struct PhysioChatDetailView: View {
    let patientID: Int
    @StateObject private var dataModel = AnkleHealDataModel.shared
    @StateObject private var authManager = AuthStateManager.shared
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var scrollToBottom = false
    
    // Colors
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    
    var patient: Patient? {
        dataModel.getPatient(by: patientID)
    }
    
    var physiotherapist: Physiotherapist? {
        dataModel.getPhysiotherapist(by: authManager.currentUserID)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header with patient info
            VStack(spacing: 0) {
                HStack {
                    Text(patient?.name ?? "Patient")
                        .font(.headline)
                    
                    Spacer()
                    
                    NavigationLink(destination: PatientProgressView(patient: patient ?? getDefaultPatient())) {
                        Text("View Progress")
                            .font(.subheadline)
                            .foregroundColor(primaryColor)
                    }
                    .disabled(patient == nil)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                Divider()
            }
            .background(Color.white)
            
            // Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            PhysioChatBubble(
                                message: message,
                                isFromPhysio: message.senderID == authManager.currentUserID
                            )
                        }
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                scrollToBottom = true
                            }
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
                .onChange(of: scrollToBottom) { _ in
                    if scrollToBottom {
                        withAnimation {
                            scrollView.scrollTo("bottomMessage", anchor: .bottom)
                            scrollToBottom = false
                        }
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
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadMessages() {
        // Get messages between physio and patient
        let physioID = authManager.currentUserID
        messages = dataModel.getChatMessages(between: physioID, and: patientID)
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private func markMessagesAsRead() {
        let physioID = authManager.currentUserID
        dataModel.markMessagesAsRead(fromSenderID: patientID, toReceiverID: physioID)
    }
    
    private func sendMessage() {
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let physioID = authManager.currentUserID
        let senderName = physiotherapist?.name ?? "Physiotherapist"
        let messageToSend = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Clear input field immediately for better UX
        messageText = ""
        
        // Send message outside the current render cycle
        DispatchQueue.main.async {
            dataModel.addChatMessage(
                senderID: physioID,
                receiverID: patientID,
                message: messageToSend,
                senderName: senderName
            )
            
            // Reload messages after sending
            loadMessages()
            scrollToBottom = true
        }
    }
    
    // Fallback default patient for preview
    private func getDefaultPatient() -> Patient {
        return Patient(
            id: patientID,
            name: "Unknown Patient",
            dob: Date(),
            gender: .other,
            mobile: "",
            email: "",
            height: 0,
            weight: 0,
            injury: .other(description: ""),
            currentPhysiotherapistID: authManager.currentUserID,
            location: Location(latitude: 0, longitude: 0)
        )
    }
}

struct PhysioChatBubble: View {
    let message: ChatMessage
    let isFromPhysio: Bool
    
    // Enhanced colors
    let sentBubbleColor = AppColors.primaryColor
    let receivedBubbleColor = Color(.systemGray5)
    let sentTextColor = Color.white
    let receivedTextColor = AppColors.textColor
    
    var body: some View {
        HStack {
            if isFromPhysio {
                // Messages from physiotherapist (sender) should be on the right
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(message.message)
                        .padding(12)
                        .background(sentBubbleColor)
                        .foregroundColor(sentTextColor)
                        .clipShape(ChatBubbleShape(isFromPhysio: isFromPhysio))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                }
                .frame(maxWidth: 280, alignment: .trailing)
            } else {
                // Messages from patient (receiver) should be on the left
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.message)
                        .padding(12)
                        .background(receivedBubbleColor)
                        .foregroundColor(receivedTextColor)
                        .clipShape(ChatBubbleShape(isFromPhysio: isFromPhysio))
                    
                    Text(formatTime(message.timestamp))
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                .frame(maxWidth: 280, alignment: .leading)
                
                Spacer()
            }
        }
        .padding(.vertical, 4) // Add some vertical spacing between bubbles
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// Custom shape for chat bubbles
struct ChatBubbleShape: Shape {
    let isFromPhysio: Bool
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: [
                .topLeft,
                .topRight,
                isFromPhysio ? .bottomLeft : .bottomRight
            ],
            cornerRadii: CGSize(width: 16, height: 16)
        )
        
        return Path(path.cgPath)
    }
}
