//
//  HomeView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 13/03/25.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject private var dataModel = AnkleHealDataModel.shared
    @ObservedObject private var authManager = AuthStateManager.shared
    @State private var patient: Patient
    @State private var showNewAppointmentView = false
    @State private var rescheduleRequests: [RescheduleRequest] = [] // State for reschedule requests

    init() {
        // Get the patient ID from AuthManager, or use a default for preview
        let patientID = AuthStateManager.shared.currentUserID > 0 ?
                        AuthStateManager.shared.currentUserID : 1
                        
        // Initialize with the patient from the data model
        let defaultPatient = Patient(
            id: patientID,
            name: "Default Patient",
            dob: Date(),
            gender: .male,
            mobile: "5551234567",
            email: "default@example.com",
            height: 175,
            weight: 70,
            injury: .grade2,
            currentPhysiotherapistID: 1,
            location: Location(latitude: 37.7749, longitude: -122.4194)
        )
        
        _patient = State(initialValue: AnkleHealDataModel.shared.getPatient(by: patientID) ?? defaultPatient)
    }

    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    AppColors.backgroundColor
                        .edgesIgnoringSafeArea(.all)

                    VStack(spacing: 0) {
                        NavBarView(patientName: patient.name, patientID: patient.id)

                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                // Display reschedule notifications if any
                                ForEach(rescheduleRequests) { request in
                                    RescheduleNotificationCard(request: request) {
                                        loadRescheduleRequests()
                                    }
                                }
                                
                                NavigationLink(destination: ProgressTrackerView()) {
                                    ProgressViewComponent(patient: patient)
                                        .background(AppColors.cardBackgroundColor)
                                        .cornerRadius(12)
                                        .shadow(radius: 1)
                                        .padding(.horizontal)
                                }

                                AppointmentSection(
                                    patient: patient,
                                    hasRescheduleRequests: !rescheduleRequests.isEmpty,
                                    bookNowAction: {
                                        showNewAppointmentView = true
                                    }
                                )

                                ArticlesSection()
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .onAppear {
                    loadRescheduleRequests()
                    
                    // Refresh patient data to ensure progress is up-to-date
                    DispatchQueue.main.async {
                        if let updatedPatient = dataModel.getPatient(by: patient.id) {
                            patient = updatedPatient
                        }
                        
                        // Initialize progress tracking for this patient
                        dataModel.calculateTodayProgress(for: patient.id)
                        
                        // Force UI update
                        dataModel.objectWillChange.send()
                    }
                }
                .navigationBarBackButtonHidden(true)
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            LibraryView(patientID: patient.id)
                .tabItem {
                    Image(systemName: "figure.strengthtraining.functional")
                    Text("Library")
                }
            
            ChatView()
                .tabItem {
                    Image(systemName: "bubble.left.fill")
                    Text("Chat")
                }
        }
        .sheet(isPresented: $showNewAppointmentView) {
            NewAppointmentView(
                patientID: patient.id,
                physiotherapistID: patient.currentPhysiotherapistID ?? 1 // fallback if nil
            ) { newAppointment in
                // Handle the new appointment callback
                AnkleHealDataModel.shared.bookAppointment(
                    patientID: patient.id,
                    physioID: patient.currentPhysiotherapistID ?? 1,
                    date: newAppointment.date,
                    time: newAppointment.time,
                    summary: newAppointment.diagnosis
                )

                // Refresh patient info after booking
                if let updatedPatient = AnkleHealDataModel.shared.getPatient(by: patient.id) {
                    patient = updatedPatient
                }

                showNewAppointmentView = false
            }
        }
        .accentColor(AppColors.primaryColor) // Set accent color for TabView
    }
    
    // Load any pending reschedule requests
    private func loadRescheduleRequests() {
        rescheduleRequests = dataModel.getRescheduleRequests(for: patient.id)
    }
}

struct RescheduleNotificationCard: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    let request: RescheduleRequest
    var onRespond: () -> Void
    
    // Define success color for confirm button
    let successColor = Color.green
    
    // State for custom date/time selection
    @State private var showDateTimePicker = false
    @State private var selectedDate: Date
    @State private var showTimePicker = false
    
    // Initialize with suggested date or tomorrow
    init(request: RescheduleRequest, onRespond: @escaping () -> Void) {
        self.request = request
        self.onRespond = onRespond
        
        // Use suggested date if available, otherwise use tomorrow
        let suggestedDate = request.suggestedNewDate
        let calendar = Calendar.current
        let defaultDate = suggestedDate ?? calendar.date(byAdding: .day, value: 1, to: Date())!
        
        // Initialize the state properties
        _selectedDate = State(initialValue: defaultDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.exclamationmark")
                    .foregroundColor(AppColors.rescheduleColor)
                    .font(.title2)
                
                Text("Appointment Rescheduling")
                    .font(.headline)
                    .foregroundColor(AppColors.rescheduleColor)
                
                Spacer()
            }
            
            Text("Your appointment on \(formatDate(request.originalDate)) at \(request.originalTime) needs to be rescheduled.")
                .font(.subheadline)
                .foregroundColor(AppColors.textColor)
            
            Divider()
            
            Text("Select a new date and time:")
                .font(.subheadline)
                .foregroundColor(AppColors.textColor)
            
            if showDateTimePicker {
                // Show custom date/time picker when the user wants to select a different time
                VStack(spacing: 12) {
                    // Date picker - only allow future dates
                    DatePicker(
                        "Date",
                        selection: $selectedDate,
                        in: Calendar.current.startOfDay(for: Date())...,
                        displayedComponents: .date
                    )
                    .datePickerStyle(CompactDatePickerStyle())
                    
                    Button(action: {
                        showTimePicker.toggle()
                    }) {
                        HStack {
                            Text("Time: \(formatTime(selectedDate))")
                                .foregroundColor(AppColors.textColor)
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(AppColors.secondaryTextColor)
                        }
                        .padding()
                        .background(AppColors.primaryColor.opacity(0.1))
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
                    
                    // Button to use the selected date/time
                    Button(action: {
                        showDateTimePicker = false
                    }) {
                        Text("Use Selected Time")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.primaryColor)
                            .cornerRadius(8)
                    }
                }
            } else {
                // Display the suggested date from the physiotherapist
                HStack {
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(AppColors.textColor)
                    Spacer()
                    Text(getSuggestedDate())
                        .foregroundColor(AppColors.textColor)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.vertical, 4)
                
                // Display the suggested time from the physiotherapist
                HStack {
                    Text("Time: \(getSuggestedTime())")
                        .foregroundColor(AppColors.textColor)
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundColor(AppColors.secondaryTextColor)
                }
                .padding()
                .background(AppColors.primaryColor.opacity(0.1))
                .cornerRadius(8)
                
                // Button to select a different time
                Button(action: {
                    showDateTimePicker = true
                }) {
                    Text("Select Different Time")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryColor)
                        .padding(.vertical, 6)
                }
            }
            
            // Confirm/Decline buttons
            HStack {
                // Updated Confirm button to match Decline style but with green color
                Button(action: {
                    respondToReschedule(accept: true)
                }) {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .foregroundColor(successColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardBackgroundColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(successColor, lineWidth: 1)
                        )
                }
                
                Button(action: {
                    respondToReschedule(accept: false)
//                    AppointmentSection.cancelAppointment(relevantAppointment!)
                }) {
                    Text("Decline")
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.rescheduleColor)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.cardBackgroundColor)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppColors.rescheduleColor, lineWidth: 1)
                        )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackgroundColor)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.rescheduleColor.opacity(0.5), lineWidth: 2)
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
    
    // Helper function to get formatted suggested date
    private func getSuggestedDate() -> String {
        if let suggestedDate = request.suggestedNewDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM yyyy"
            return formatter.string(from: suggestedDate)
        } else {
            // Fallback to a sample date for demonstration
            return "2 Apr 2025"
        }
    }
    
    // Helper function to get suggested time
    private func getSuggestedTime() -> String {
        return request.suggestedNewTime ?? "12:08 PM"
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
        // Use either the custom selected date or the suggested date from the physiotherapist
        let finalDate = showDateTimePicker ?
            selectedDate :
            (request.suggestedNewDate ?? Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
            
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let finalTime = showDateTimePicker ?
            timeFormatter.string(from: selectedDate) :
            request.suggestedNewTime ?? "12:00 PM"
        
        // Update the model with reschedule decision
        dataModel.respondToReschedule(
            requestID: request.id,
            newDate: finalDate,
            newTime: finalTime,
            accept: accept
        )
        
        // If accepting the reschedule, update the appointment
        if accept {
            updateAppointment(finalDate, finalTime)
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
        if let patient = dataModel.getPatient(by: request.patientID) {
            return patient.appointmentHistory.first(where: { appointment in
                // Use both appointmentID if available, or match by date/time
                calendar.isDate(appointment.date, inSameDayAs: request.originalDate) &&
                appointment.time == request.originalTime
            })
        }
        return nil
    }
    
    // Calendar instance for date comparisons
    private let calendar = Calendar.current
}

struct NavBarView: View {
    var patientName: String
    var patientID: Int

    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90)
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)

    var body: some View {
        HStack {
            Text("Welcome, \(patientName)")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(textColor)

            Spacer()

            NavigationLink(destination: ProfileView(patientID: patientID)) {
                Image(systemName: "person.circle")
                    .font(.system(size: 20)) // Same size as physiotherapist side
                    .foregroundColor(primaryColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.white)
        // Remove shadow to match physiotherapist style
    }
}

// MARK: - Appointment Section

struct AppointmentSection: View {
    @StateObject private var dataModel = AnkleHealDataModel.shared
    var patient: Patient
    var hasRescheduleRequests: Bool = false
    var bookNowAction: () -> Void
    
    @State private var showingCancelAlert = false
    @State private var showingBookingLimitAlert = false
    @State private var cancelSuccess = false
    @State private var refreshView = false // Force refresh state

    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90)
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94)
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    let rescheduleColor = Color.red

    // Get the most relevant appointment to display (pending, confirmed or rejected)
    var relevantAppointment: Appointment? {
        // Check for any active reschedule requests
        let activeRescheduleRequests = dataModel.rescheduleRequests.filter {
            $0.patientID == patient.id &&
            $0.status == .accepted
        }
        
        // If there are accepted reschedule requests, return the rescheduled appointment
        if let rescheduleRequest = activeRescheduleRequests.first,
           let suggestedDate = rescheduleRequest.suggestedNewDate,
           let suggestedTime = rescheduleRequest.suggestedNewTime {
            return Appointment(
                patientID: patient.id,
                appointmentID: Int.random(in: 10000...99999),
                date: suggestedDate,
                time: suggestedTime,
                physiotherapistID: patient.currentPhysiotherapistID ?? 0,
                patientName: patient.name,
                diagnosis: "Initial Assessment",
                status: true
            )
        }
        
        // First check for pending appointments
        // These should be displayed with highest priority
        if let pendingAppointment = checkPendingAppointmentRequest() {
            return pendingAppointment
        }
        
        // Get upcoming confirmed appointments
        let upcomingConfirmedAppointments = patient.appointmentHistory
            .filter { $0.status && $0.date >= Date() }
            .sorted { $0.date < $1.date }
        
        return upcomingConfirmedAppointments.first
    }
    
    // Check if there's a pending appointment request
    private func checkPendingAppointmentRequest() -> Appointment? {
        // Look through appointment requests for pending ones from this patient
        let pendingRequests = dataModel.appointmentRequests.filter {
            $0.status == .pending && $0.patientID == patient.id
        }
        
        if !pendingRequests.isEmpty {
            // First check if there's a matching appointment in patient history
            for request in pendingRequests {
                let matchingAppointment = patient.appointmentHistory
                    .filter { !$0.status } // Unconfirmed appointments
                    .first { appointment in
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd MMM, yyyy"
                        let appointmentDateString = dateFormatter.string(from: appointment.date)
                        
                        return appointmentDateString == request.date && appointment.time == request.time
                    }
                
                if let appointment = matchingAppointment {
                    return appointment
                }
            }
            
            // If we don't find a matching appointment in history, create a temporary one
            // This ensures even newly created appointments show up immediately
            if let request = pendingRequests.first {
                // Parse date from request
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM, yyyy"
                let requestDate = dateFormatter.date(from: request.date) ?? Date()
                
                return Appointment(
                    patientID: patient.id,
                    appointmentID: Int.random(in: 10000...99999),
                    date: requestDate,
                    time: request.time,
                    physiotherapistID: patient.currentPhysiotherapistID ?? 0,
                    patientName: patient.name,
                    diagnosis: request.notes,
                    status: false // Pending appointments have status = false
                )
            }
        }
        
        return nil
    }
    
    // Check if user can book a new appointment
    private func canBookNewAppointment() -> Bool {
        // Can always book if there's a reschedule request
        if hasRescheduleRequests {
            return true
        }
        
        // Can't book if there's a pending request
        if checkPendingAppointmentRequest() != nil {
            return false
        }
        
        // Check if there's already a confirmed upcoming appointment
        let hasConfirmedUpcoming = patient.appointmentHistory
            .contains(where: { $0.date >= Date() && $0.status })
        
        return !hasConfirmedUpcoming
    }

    var body: some View {
           VStack(alignment: .leading, spacing: 8) {
               Text("Appointment")
                   .font(.headline)
                   .foregroundColor(textColor)

               VStack(spacing: 8) {
                   if let appointment = relevantAppointment {
                       VStack(alignment: .leading, spacing: 8) {
                           HStack {
                               Text("Upcoming Appointment")
                                   .font(.subheadline)
                                   .fontWeight(.bold)
                                   .foregroundColor(textColor)
                               
                               Spacer()
                               
                               StatusBadge(appointment: appointment)
                           }
                           
                           Text("\(formattedDate(appointment.date)) at \(appointment.time)")
                               .font(.subheadline)
                               .foregroundColor(secondaryTextColor)
                               .padding(.bottom, 4)
                           
                           // Show rejected message if appointment is rejected/cancelled
                           if !appointment.status && !isPendingRequest(appointment) {
                               Text("Your appointment request was not confirmed. You can book a new appointment.")
                                   .font(.footnote)
                                   .foregroundColor(rescheduleColor)
                                   .padding(.bottom, 4)
                               
                               // Book again button
                               Button(action: {
                                   if canBookNewAppointment() {
                                       bookNowAction()
                                   } else {
                                       showingBookingLimitAlert = true
                                   }
                               }) {
                                   Text("Book Again")
                                       .font(.footnote)
                                       .fontWeight(.medium)
                                       .foregroundColor(.white)
                                       .padding(.horizontal, 24)
                                       .padding(.vertical, 8)
                                       .background(primaryColor)
                                       .cornerRadius(8)
                               }
                               .frame(maxWidth: .infinity, alignment: .center)
                           }
                           // Only show cancel button if appointment is confirmed or pending
                           else {
                               // Cancel button
                               HStack {
                                   Spacer()
                                   
                                   Button(action: {
                                       showingCancelAlert = true
//                                       cancelAppointment(appointment)
//                                       Alert(
//                                           title: Text("Cancel Appointment"),
//                                           message: Text("Are you sure you want to cancel your appointment on \(formattedDate(relevantAppointment?.date ?? Date())) at \(relevantAppointment?.time ?? "")?"),
//                                           primaryButton: .destructive(Text("Yes")) {
//                                               // Cancel the appointment
//                                               if let appointment = relevantAppointment {
//                                                   cancelAppointment(appointment)
//                                               }
//                                           },
//                                           secondaryButton: .cancel(Text("No"))
//                                       )
                                   }) {
                                       Text("Cancel")
                                           .font(.footnote)
                                           .fontWeight(.medium)
                                           .foregroundColor(rescheduleColor)
                                           .padding(.horizontal, 24)
                                           .padding(.vertical, 8)
                                           .background(
                                               RoundedRectangle(cornerRadius: 8)
                                                   .stroke(rescheduleColor, lineWidth: 1)
                                           )
                                   }
                               }
                               // Show waiting message if appointment is pending
                               if isPendingRequest(appointment) {
                                   Text("Your appointment request is waiting for confirmation.")
                                       .font(.footnote)
                                       .foregroundColor(Color.orange)
                                       .padding(.bottom, 4)
                               }
                           }
                       }
                       .padding()
                       .background(getBackgroundColor(for: appointment))
                       .cornerRadius(10)
                   } else {
                       // Only show a single "Book Now" button
                       VStack(alignment: .center, spacing: 8) {
                           Text("No Upcoming Appointment")
                               .font(.subheadline)
                               .foregroundColor(textColor)
                               .padding(.top, 8)
                           
                           Button(action: {
                               if canBookNewAppointment() {
                                   bookNowAction()
                               } else {
                                   showingBookingLimitAlert = true
                               }
                           }) {
                               Text("Book Now")
                                   .font(.subheadline)
                                   .foregroundColor(.white)
                                   .padding(.horizontal, 24)
                                   .padding(.vertical, 10)
                                   .background(primaryColor)
                                   .cornerRadius(8)
                           }
                           .padding(.bottom, 8)
                       }
                       .frame(maxWidth: .infinity)
                       .background(Color.white)
                       .cornerRadius(10)
                   }
               }
           }
           .padding()
           .background(Color.white)
           .cornerRadius(12)
           .shadow(radius: 1)
           .padding(.horizontal)
//           .alert(
//               "Confirm Cancellation",
//               isPresented: $showingCancelAlert,
////               presenting: details
//           ) { details in
//               Button(role: .destructive) {
//                   // Handle the deletion.
//               } label: {
//                   Text("Delete \(details.name)")
//               }
//               Button("Retry") {
//                   // Handle the retry action.
//               }
//           } message: { details in
//               Text(details.error)
//           }
           .alert(
               "Confirm Cancellation",
               isPresented: $showingCancelAlert
           ) {
               Button("Confirm", role: .destructive) {
                   // Handle the acknowledgement.
                   cancelAppointment(relevantAppointment!)
//                   dataModel.objectWillChange.send()
               }
               
               Button("Cancel", role: .cancel) {
                   // Dismiss the alert without taking any action
                   showingCancelAlert = false
               }
           } message: {
               Text("Press Confirm to Cancel Appointment")
           }
//           .alert(isPresented: $showingCancelAlert) {
//               Alert(
//                   title: Text("Cancel Appointment"),
//                   message: Text("Are you sure you want to cancel your appointment on \(formattedDate(relevantAppointment?.date ?? Date())) at \(relevantAppointment?.time ?? "")?"),
//                   primaryButton: .destructive(Text("Yes")) {
//                       // Cancel the appointment
//                       if let appointment = relevantAppointment {
//                           cancelAppointment(appointment)
//                       }
//                   },
//                   secondaryButton: .cancel(Text("No"))
//               )
//           }
           // Show success alert after cancellation
//           .alert(isPresented: $cancelSuccess) {
//               Alert(
//                   title: Text("Appointment Cancelled"),
//                   message: Text("Your appointment has been successfully cancelled. You can now book a new appointment."),
//                   dismissButton: .default(Text("OK")) {
//                       // Optional: Trigger UI update or any additional actions
//                       dataModel.objectWillChange.send()
//                       refreshView.toggle() // Force UI refresh
//                   }
//               )
//           }
       }
       
       // Helper function to cancel appointment
       private func cancelAppointment(_ appointment: Appointment) {
           // Cancel appointment using the enhanced data model method
           let cancellationSuccess = dataModel.cancelAppointment(
               appointmentID: appointment.appointmentID,
               cancellationReason: "Patient decided to cancel",
               notifyPhysiotherapist: true
           )
           
           if cancellationSuccess {
               print("✅ Appointment \(appointment.appointmentID) canceled successfully")
               
               // Show success alert
               cancelSuccess = true
           } else {
               print("❌ Failed to cancel appointment \(appointment.appointmentID)")
           }
       }
    
    // Check if an appointment is a pending request
    private func isPendingRequest(_ appointment: Appointment) -> Bool {
        // Check appointment requests collection
        for request in dataModel.appointmentRequests where request.status == .pending {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM, yyyy"
            let appointmentDateString = dateFormatter.string(from: appointment.date)
            
            if request.patientID == appointment.patientID &&
               request.date == appointmentDateString &&
               request.time == appointment.time {
                return true
            }
        }
        
        // If not in appointment requests, it might be a newly created request
        // that hasn't been added to the requests collection yet,
        // but the appointment status is false (unconfirmed)
        return !appointment.status
    }
    
    // Helper function to get background color based on status
    private func getBackgroundColor(for appointment: Appointment) -> Color {
        // Show appropriate background color based on appointment status
        if appointment.status {
            return Color.white // Confirmed
        } else if isPendingRequest(appointment) {
            return Color.orange.opacity(0.1) // Pending
        } else {
            return Color.red.opacity(0.1) // Cancelled/Rejected
        }
    }
    
    // Helper function to format date
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: date)
    }
}
    
// MARK: - Articles Section
struct ArticlesSection: View {
    @ObservedObject var dataModel = AnkleHealDataModel.shared
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Articles")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textColor)
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(dataModel.articles, id: \.articleID) { article in
                    ArticleCard(article: article)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Updated ArticleCard with consistent color scheme
struct ArticleCard: View {
    let article: Article
    
    var body: some View {
        Button(action: {
            if let url = URL(string: article.url) {
                UIApplication.shared.open(url)
            }
        }) {
            VStack(alignment: .leading) {
                Image(article.imageName)
                    .resizable()
                    .frame(height: 200)
                    .cornerRadius(12)
                
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
                
                HStack {
                    Text(article.author)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                    Spacer()
                    Text(article.publicationDate)
                        .font(.subheadline)
                        .foregroundColor(AppColors.secondaryTextColor)
                }
            }
            .padding()
            .background(AppColors.cardBackgroundColor)
            .cornerRadius(12)
            .shadow(radius: 4)
        }
        .buttonStyle(PlainButtonStyle()) // Removes the button highlight effect
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

struct StatusBadge: View {
    let appointment: Appointment
    @ObservedObject var dataModel = AnkleHealDataModel.shared
    
    var body: some View {
        Text(getAppointmentStatus().rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(getAppointmentStatus().color)
            .cornerRadius(12)
    }
    
    private func getAppointmentStatus() -> Appointment.AppointmentStatus {
        // Check if there are pending requests for this appointment
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let appointmentDateString = dateFormatter.string(from: appointment.date)
        
        // First check the appointment requests collection for matching requests
        for request in dataModel.appointmentRequests {
            if request.status == .pending &&
               request.patientID == appointment.patientID &&
               request.date == appointmentDateString &&
               request.time == appointment.time {
                return .pending
            }
        }
        
        // Then check if the appointment itself is marked as pending
        if !appointment.status {
            // If status is false but not in appointment requests, check if it's in a reschedule request
            for request in dataModel.rescheduleRequests {
                if request.status == .pending &&
                   request.patientID == appointment.patientID &&
                   Calendar.current.isDate(request.originalDate, inSameDayAs: appointment.date) &&
                   request.originalTime == appointment.time {
                    return .pending
                }
            }
            
            // If not found in reschedule requests either, it must be cancelled
            return .cancelled
        }
        
        // If we got here, the appointment is confirmed
        return .confirmed
    }
}
