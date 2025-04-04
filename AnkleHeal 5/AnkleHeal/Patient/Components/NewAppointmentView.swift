//
//  NewAppointmentView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 13/03/25.
//

import SwiftUI

struct NewAppointmentView: View {
    var patientID: Int
    var physiotherapistID: Int
    var diagnosis: String = "Initial Assessment"
    
    var onAppointmentBooked: (Appointment) -> Void = { _ in }

    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var selectedDate: Date
    @State private var showTimePicker: Bool = false
    
    // Only success alert state
    @State private var showBookingSuccessAlert = false

    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90)
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94)
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    
    // Custom initializer to set default date to tomorrow at 9 AM
    init(patientID: Int, physiotherapistID: Int, diagnosis: String = "Initial Assessment", onAppointmentBooked: @escaping (Appointment) -> Void = { _ in }) {
        self.patientID = patientID
        self.physiotherapistID = physiotherapistID
        self.diagnosis = diagnosis
        self.onAppointmentBooked = onAppointmentBooked
        
        // Calculate tomorrow's date at 9 AM
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: Date()))
        components.day! += 1  // Tomorrow
        components.hour = 9   // 9 AM
        let defaultDate = calendar.date(from: components) ?? Date()
        
        // Initialize the state property
        _selectedDate = State(initialValue: defaultDate)
    }

    var body: some View {
        ZStack {
            // Background color for the entire view including behind bottom tab bar
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Date Picker Section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Date")
                        .font(.headline)
                        .foregroundColor(textColor)

                    DatePicker(
                        "Select Date",
                        selection: $selectedDate,
                        in: Calendar.current.startOfDay(for: Date())...,  // Only allow today and future dates
                        displayedComponents: .date
                    )
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .frame(maxHeight: 300)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
                .padding(.top)

                // Time Picker Section (Tap to Show Native Picker)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Time")
                        .font(.headline)
                        .foregroundColor(textColor)

                    Button(action: {
                        withAnimation {
                            showTimePicker.toggle()
                        }
                    }) {
                        HStack {
                            Text(formattedTime(from: selectedDate))
                                .font(.title3)
                                .foregroundColor(primaryColor)
                            Spacer()
                            Image(systemName: "clock")
                                .foregroundColor(secondaryTextColor)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
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
                            in: minTime...,  // Minimum time is now or start of day based on date
                            displayedComponents: .hourAndMinute
                        )
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(maxHeight: 150)
                        .onChange(of: selectedDate) { newDate in
                            // Ensure we don't lose the date when changing just the time
                            preserveDateWhenChangingTime(newTime: newDate)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)

                // Book Appointment Button - Direct booking without confirmation
                Button(action: {
                    handleBooking()
                    showBookingSuccessAlert = true
                }) {
                    Text("Book Appointment")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.headline)
                }
                .padding(.horizontal)
                
                // Cancel Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.red)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 1)
                        )
                        .cornerRadius(10)
                        .font(.headline)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .navigationBarHidden(true) // Hide navigation bar to provide a modal feel
        // Only show success alert
        .alert("Appointment Requested", isPresented: $showBookingSuccessAlert) {
            Button("OK") {
                presentationMode.wrappedValue.dismiss()
            }
        } message: {
            Text("Your appointment request has been sent to your physiotherapist for approval.")
        }
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

    private func handleBooking() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let formattedTime = timeFormatter.string(from: selectedDate)

        guard let patient = dataModel.getPatient(by: patientID) else {
            print("❌ Patient not found")
            return
        }

        // Send appointment request
        dataModel.requestAppointment(
            patientID: patientID,
            patientName: patient.name,
            date: formattedDate,
            time: formattedTime,
            notes: diagnosis
        )
        
        // Call the onAppointmentBooked closure
        let newAppointment = Appointment(
            patientID: patientID,
            appointmentID: Int.random(in: 1000...9999),
            date: selectedDate,
            time: formattedTime,
            physiotherapistID: physiotherapistID,
            patientName: patient.name,
            diagnosis: diagnosis,
            status: false  // Set status to false for pending appointments
        )
        onAppointmentBooked(newAppointment)
    }

    private func formattedTime(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }
}
