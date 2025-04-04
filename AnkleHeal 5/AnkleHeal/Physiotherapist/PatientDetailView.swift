//
//  PatientDetailView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

// MARK: - Updated Patient Detail View with proper date restrictions
struct PatientDetailView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingRescheduleAlert = false
    @State private var hasInitiatedReschedule = false
    @State private var showReschedulePicker = false
    @State private var selectedRescheduleDate = Date()
    
    // States for separate date and time pickers
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    
    let appointment: Appointment
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let rescheduleColor = Color.red // Red color for reschedule button
    
    // Computed properties for display data
    private var patient: Patient? {
        dataModel.getPatient(by: appointment.patientID)
    }
    
    private var formattedAppointmentDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE dd MMM, yyyy"
        return dateFormatter.string(from: appointment.date)
    }
    
    private var appointmentTime: String {
        return appointment.time
    }
    
    private var injuryType: String {
        return "Ankle Injury"
    }
    
    private var injuryGrade: String {
        return appointment.diagnosis
    }
    
    private var lastAppointmentString: String {
        let otherAppointments = patient?.appointmentHistory.filter {
            $0.appointmentID != appointment.appointmentID
        } ?? []
        
        if let lastAppointment = otherAppointments.max(by: { $0.date < $1.date }) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            return dateFormatter.string(from: lastAppointment.date)
        } else {
            return "None"
        }
    }
    
    private func initiateReschedule() {
        // Calculate tomorrow's date
        let calendar = Calendar.current
        var tomorrow = calendar.startOfDay(for: Date())
        tomorrow = calendar.date(byAdding: .day, value: 1, to: tomorrow)!
        
        // Initialize with tomorrow's date and appointment time
        selectedRescheduleDate = tomorrow
        
        // Extract time from the appointment time string and set it
        if let timeDate = parseTime(appointmentTime) {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: selectedRescheduleDate)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate)
            
            components.hour = timeComponents.hour
            components.minute = timeComponents.minute
            
            if let combined = calendar.date(from: components) {
                selectedRescheduleDate = combined
            }
        }
        
        // Set the flag to disable the button
        hasInitiatedReschedule = true
        
        // Show the reschedule picker sheet
        showReschedulePicker = true
    }
    
    // Helper to parse a time string into a Date
    private func parseTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        
        // Add a reference date because time-only parsing needs a full date
        let today = Calendar.current.startOfDay(for: Date())
        formatter.defaultDate = today
        
        return formatter.date(from: timeString)
    }
    
    // Send reschedule request to patient
    private func sendRescheduleRequest() {
        // Format the time
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        let formattedTime = formatter.string(from: selectedRescheduleDate)
        
        // Create a pending reschedule request in the data model
        dataModel.createRescheduleRequest(
            appointmentID: appointment.appointmentID,
            patientID: appointment.patientID,
            originalDate: appointment.date,
            originalTime: appointment.time,
            suggestedNewDate: selectedRescheduleDate,   // Pass the selected new date
            suggestedNewTime: formattedTime             // Pass the selected new time
        )
        
        // Set the flag to disable the button
        hasInitiatedReschedule = true
        
        // Hide the reschedule picker
        showReschedulePicker = false
        
        // Update the appointment to show it's being rescheduled
        markAppointmentAsRescheduling()
        
        // Show confirmation to the physiotherapist
        // In a real app, this would trigger a push notification to the patient
        print("Reschedule request sent to patient \(appointment.patientID) for new date: \(formatJustDate(selectedRescheduleDate)) and time: \(formattedTime)")
    }
    
    // Mark appointment as being rescheduled
    private func markAppointmentAsRescheduling() {
        // Set status to false to indicate it's no longer confirmed
        // The app will show a rescheduling notice instead
        dataModel.rescheduleAppointment(
            appointmentID: appointment.appointmentID,
            newDate: appointment.date,  // Keep same date for now
            newTime: appointment.time,  // Keep same time for now
            newDiagnosis: appointment.diagnosis
        )
        
        // Force data model to notify observers of change
        dataModel.objectWillChange.send()
    }
    
    // Format just the date portion (no time)
    private func formatJustDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, yyyy"
        return formatter.string(from: date)
    }
    
    // Check if this is a reschedulable appointment
    private var isReschedulable: Bool {
        // If reschedule has already been initiated during this session
        if hasInitiatedReschedule {
            return false
        }
        
        // Rest of your existing logic
        let calendar = Calendar.current
        let now = Date()
        
        // Combine date and time to create a full appointment datetime
        let timeComponents = appointment.time.components(separatedBy: ":")
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: appointment.date)
        
        if timeComponents.count >= 2, let hour = Int(timeComponents[0]) {
            let minuteParts = timeComponents[1].components(separatedBy: " ")
            if let minute = Int(minuteParts[0]) {
                dateComponents.hour = hour
                dateComponents.minute = minute
                
                // Adjust for PM
                if appointment.time.contains("PM") && hour < 12 {
                    dateComponents.hour! += 12
                }
                // Adjust for 12 AM
                if appointment.time.contains("AM") && hour == 12 {
                    dateComponents.hour! = 0
                }
            }
        }
        
        // Create full appointment datetime
        if let appointmentDateTime = calendar.date(from: dateComponents) {
            // Appointment is reschedulable if it's in the future
            return appointmentDateTime > now && appointment.status
        }
        
        // Default to true if we couldn't determine the exact time
        return appointment.status
    }
    
    private var medicalHistory: String {
        var history = ""
        
        if let injury = patient?.injury {
            switch injury {
            case .grade1:
                history = "Grade 1 ankle sprain (mild)."
            case .grade2:
                history = "Grade 2 ankle sprain (moderate)."
            case .grade3:
                history = "Grade 3 ankle sprain (severe)."
            case .ligamentTear:
                history = "Ligament tear in the ankle."
            case .inversion:
                history = "Inversion ankle injury."
            case .other(let description):
                history = description
            }
        }
        
        history += "\n\nFell down the stairs. Came in with a swollen ankle. MRI shows grade 3 ATFL tear."
        
        return history
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Date and time section
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formattedAppointmentDate)
                            .font(.headline)
                            .foregroundColor(primaryColor)
                        
                        Text(appointmentTime)
                            .font(.headline)
                            .foregroundColor(primaryColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    
                    Divider()
                    
                    // Injury type section
                    HStack {
                        Text("Injury Type")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        Text(injuryGrade)
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    .padding()
                    .background(Color.white)
                    
                    Divider()
                    
                    // Last appointment section
                    HStack {
                        Text("Last Appointment")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        Text(lastAppointmentString)
                            .font(.headline)
                            .foregroundColor(textColor)
                    }
                    .padding()
                    .background(Color.white)
                    
                    Divider()
                    
                    // Medical history section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Medical History")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Text(medicalHistory)
                            .font(.body)
                            .foregroundColor(secondaryTextColor)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color.white)
                    
                    // Reschedule button
                    Button(action: {
                        showingRescheduleAlert = true
                    }) {
                        Text("Reschedule")
                            .font(.headline)
                            .foregroundColor(isReschedulable ? rescheduleColor : secondaryTextColor)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(isReschedulable ? rescheduleColor : secondaryTextColor, lineWidth: 1)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            )
                            .padding()
                    }
                    .disabled(!isReschedulable)
                    .alert(isPresented: $showingRescheduleAlert) {
                        Alert(
                            title: Text("Reschedule Appointment"),
                            message: Text("Would you like to reschedule this appointment?"),
                            primaryButton: .destructive(Text("Yes")) {
                                initiateReschedule()
                            },
                            secondaryButton: .cancel(Text("No"))
                        )
                    }
                    
                    // Add extra padding at the bottom to ensure content isn't hidden by TabBar
                    Spacer()
                        .frame(height: 70)
                }
            }
            .navigationBarTitle(patient?.name ?? "Patient Details", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            
            // Improved Reschedule Sheet - with separate date and time selections
            if showReschedulePicker {
                VStack(spacing: 0) {
                    // Title bar with Cancel and Confirm buttons
                    HStack {
                        Button("Cancel") {
                            showReschedulePicker = false
                            showDatePicker = false
                            showTimePicker = false
                            hasInitiatedReschedule = false // Reset so button becomes enabled again
                        }
                        .foregroundColor(primaryColor)
                        
                        Spacer()
                        
                        Text("Reschedule Appointment")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button("Confirm") {
                            sendRescheduleRequest()
                        }
                        .foregroundColor(primaryColor)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10, corners: [.topLeft, .topRight])
                    
                    Divider()
                    
                    // Improved date selector - RESTRICTION FOR PAST DATES
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Date")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Date display with expansion toggle
                        Button(action: {
                            withAnimation {
                                showDatePicker.toggle()
                                // Hide time picker when date picker is shown
                                if showDatePicker {
                                    showTimePicker = false
                                }
                            }
                        }) {
                            HStack {
                                Text(formatJustDate(selectedRescheduleDate))
                                    .font(.body)
                                    .foregroundColor(primaryColor)
                                Spacer()
                                Image(systemName: showDatePicker ? "chevron.up" : "chevron.down")
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Expandable date picker WITH PAST DATE RESTRICTION
                        if showDatePicker {
                            DatePicker(
                                "",
                                selection: $selectedRescheduleDate,
                                in: Calendar.current.startOfDay(for: Date())..., // Only allow today and future dates
                                displayedComponents: .date
                            )
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
                    }
                    .padding(.vertical, 4)
                    .background(Color.white)
                    
                    Divider()
                    
                    // Improved time selector
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Time")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Time display with expansion toggle
                        Button(action: {
                            withAnimation {
                                showTimePicker.toggle()
                                // Hide date picker when time picker is shown
                                if showTimePicker {
                                    showDatePicker = false
                                }
                            }
                        }) {
                            HStack {
                                Text(formattedTime(from: selectedRescheduleDate))
                                    .font(.body)
                                    .foregroundColor(primaryColor)
                                Spacer()
                                Image(systemName: showTimePicker ? "chevron.up" : "chevron.down")
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                        
                        // Expandable time picker WITH PAST TIME RESTRICTION
                        if showTimePicker {
                            // Decide minimum time based on if date is today
                            let minTime: Date = {
                                let calendar = Calendar.current
                                if calendar.isDateInToday(selectedRescheduleDate) {
                                    // If today, use current time as minimum
                                    return Date()
                                } else {
                                    // If future date, allow any time
                                    var components = calendar.dateComponents([.year, .month, .day], from: selectedRescheduleDate)
                                    components.hour = 0
                                    components.minute = 0
                                    return calendar.date(from: components) ?? Date()
                                }
                            }()
                            
                            DatePicker(
                                "",
                                selection: $selectedRescheduleDate,
                                in: minTime..., // RESTRICTION for past times
                                displayedComponents: .hourAndMinute
                            )
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(height: 200)
                            .padding(.horizontal)
                            .transition(.opacity)
                            .onChange(of: selectedRescheduleDate) { newDate in
                                preserveDateWhenChangingTime(newTime: newDate)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                    .background(Color.white)
                    
                    // Show the selected date and time summary
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your selection:")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                        
                        HStack {
                            Text("\(formatJustDate(selectedRescheduleDate)) at \(formattedTime(from: selectedRescheduleDate))")
                                .font(.headline)
                                .foregroundColor(primaryColor)
                            
                            Spacer()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(primaryColor.opacity(0.1))
                    )
                    .padding()
                    
                    Spacer()
                }
                .frame(height: 500)
                .background(Color.white)
                .cornerRadius(10, corners: [.topLeft, .topRight])
                .transition(.move(edge: .bottom))
                .animation(.spring())
                .shadow(radius: 5)
                .edgesIgnoringSafeArea(.bottom)
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    // Helper method to preserve date component when changing just the time
    private func preserveDateWhenChangingTime(newTime: Date) {
        let calendar = Calendar.current
        
        // Extract date components from the current selected date
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedRescheduleDate)
        
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
            if combinedDate > Date() || !calendar.isDateInToday(selectedRescheduleDate) {
                selectedRescheduleDate = combinedDate
            }
        }
    }
    
    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}
