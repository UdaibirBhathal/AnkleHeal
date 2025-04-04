//
//  RescheduleNotificationsView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 29/03/25.
//

import SwiftUI

struct RescheduleNotificationsView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var selectedDate = Date()
    @State private var showTimePicker = false
    let request: RescheduleRequest
    var onRespond: () -> Void
    
    // Initialize with current date or future date
    init(request: RescheduleRequest, onRespond: @escaping () -> Void) {
        self.request = request
        self.onRespond = onRespond
        
        // Set default date to tomorrow
        let calendar = Calendar.current
        let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        _selectedDate = State(initialValue: tomorrowDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(.red)
                    .font(.title2)
                
                Text("Appointment Rescheduling")
                    .font(.headline)
                    .foregroundColor(.red)
                
                Spacer()
            }
            
            Text("Your appointment on \(formatDate(request.originalDate)) at \(request.originalTime) needs to be rescheduled.")
                .font(.subheadline)
            
            Divider()
            
            Text("Select a new date and time:")
                .font(.subheadline)
            
            // Only allow future dates
            DatePicker(
                "New Date",
                selection: $selectedDate,
                in: Calendar.current.startOfDay(for: Date())...,
                displayedComponents: .date
            )
            .datePickerStyle(CompactDatePickerStyle())
            
            Button(action: {
                showTimePicker.toggle()
            }) {
                HStack {
                    Text("New Time: \(formatTime(selectedDate))")
                    Spacer()
                    Image(systemName: "clock")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            
            if showTimePicker {
                // Decide minimum time based on if date is today
                let minTime: Date = {
                    let calendar = Calendar.current
                    if calendar.isDateInToday(selectedDate) {
                        // If today, use current time as minimum
                        return Date()
                    } else {
                        // If future date, allow any time
                        var components = calendar.dateComponents([.year, .month, .day], from: selectedDate)
                        components.hour = 0
                        components.minute = 0
                        return calendar.date(from: components) ?? Date()
                    }
                }()
                
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: minTime...,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxHeight: 150)
                .onChange(of: selectedDate) { newDate in
                    preserveDateWhenChangingTime(newTime: newDate)
                }
            }
            
            HStack {
                Button(action: {
                    respondToReschedule(accept: true)
                }) {
                    Text("Confirm New Time")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    respondToReschedule(accept: false)
                }) {
                    Text("Decline")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.red.opacity(0.5), lineWidth: 2)
        )
    }
    
    // Helper method to preserve date component when changing just the time
    private func preserveDateWhenChangingTime(newTime: Date) {
        let calendar = Calendar.current
        
        // Extract date components from the current selected date
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        // Extract time components from the new time
        let timeComponents = calendar.dateComponents([.hour, .minute], from: newTime)
        
        // Combine them
        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute
        
        // Create the new date with preserved date and updated time
        if let combinedDate = calendar.date(from: combinedComponents) {
            // Only update if not in the past
            if combinedDate > Date() || !calendar.isDateInToday(selectedDate) {
                selectedDate = combinedDate
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func respondToReschedule(accept: Bool) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let formattedTime = timeFormatter.string(from: selectedDate)
        
        // Update the reschedule request in the data model
        dataModel.respondToReschedule(
            requestID: request.id,
            newDate: selectedDate,
            newTime: formattedTime,
            accept: accept
        )
        
        // If accepting, update the appointment with new date/time
        if accept {
            updateAppointment(selectedDate, formattedTime)
        }
        
        onRespond()
    }
    
    // Helper method to update appointment with new date/time
    private func updateAppointment(_ newDate: Date, _ newTime: String) {
        // Find the original appointment using the request info
        if let appointment = findOriginalAppointment() {
            // Reschedule the appointment with new date/time
            let success = dataModel.rescheduleAppointment(
                appointmentID: appointment.appointmentID,
                newDate: newDate,
                newTime: newTime
            )
            
            if success {
                print("✅ Successfully rescheduled appointment \(appointment.appointmentID) to \(formatDate(newDate)) at \(newTime)")
            } else {
                print("❌ Failed to reschedule appointment")
            }
        } else {
            print("❌ Could not find the original appointment to reschedule")
        }
    }
    
    // Helper to find the original appointment that needs rescheduling
    private func findOriginalAppointment() -> Appointment? {
        return dataModel.getAllPatients().flatMap { patient in
            patient.appointmentHistory
        }.first(where: { appointment in
            // Match by date/time and ensure this is the appointment referenced in the request
            let calendar = Calendar.current
            return calendar.isDate(appointment.date, inSameDayAs: request.originalDate) &&
                  appointment.time == request.originalTime &&
                  appointment.patientID == request.patientID
        })
    }
}
