//
//  AppointmentSettingsView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct AppointmentSettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Settings state
    @State private var startTime = "8:00 AM"
    @State private var endTime = "6:00 PM"
    @State private var bookingEnabled = true
    @State private var maxAppointments = 20
    
    // Picker visibility
    @State private var showingStartTimePicker = false
    @State private var showingEndTimePicker = false
    
    // Alert state
    @State private var showingTimeAlert = false
    @State private var timeAlertMessage = ""
    
    // Time options
    let timeOptions = [
        "6:00 AM", "6:30 AM", "7:00 AM", "7:30 AM", "8:00 AM", "8:30 AM", "9:00 AM", "9:30 AM", "10:00 AM",
        "10:30 AM", "11:00 AM", "11:30 AM", "12:00 PM", "12:30 PM", "1:00 PM", "1:30 PM", "2:00 PM",
        "2:30 PM", "3:00 PM", "3:30 PM", "4:00 PM", "4:30 PM", "5:00 PM", "5:30 PM", "6:00 PM",
        "6:30 PM", "7:00 PM", "7:30 PM", "8:00 PM", "8:30 PM", "9:00 PM"
    ]
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 0) {
                    // Settings Card
                    VStack(spacing: 0) {
                        // Hours
                        HStack {
                            Text("Hours")
                                .font(.title3)
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            HStack(spacing: 5) {
                                Button(action: {
                                    showingStartTimePicker = true
                                }) {
                                    Text(startTime)
                                        .foregroundColor(primaryColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                                
                                Text("-")
                                    .foregroundColor(textColor)
                                    .font(.headline)
                                
                                Button(action: {
                                    showingEndTimePicker = true
                                }) {
                                    Text(endTime)
                                        .foregroundColor(primaryColor)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 8)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Booking toggle
                        HStack {
                            Text("Booking")
                                .font(.title3)
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            Toggle("", isOn: $bookingEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                        }
                        .padding()
                        
                        Divider()
                            .padding(.horizontal)
                        
                        // Maximum Appointments
                        HStack {
                            Text("Maximum Appointments")
                                .font(.title3)
                                .foregroundColor(textColor)
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Text("\(maxAppointments)")
                                    .font(.title3)
                                    .foregroundColor(primaryColor)
                                    .frame(minWidth: 50)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                
                                Button(action: {
                                    if maxAppointments > 1 {
                                        maxAppointments -= 1
                                    }
                                }) {
                                    Text("−")
                                        .font(.title2)
                                        .foregroundColor(primaryColor)
                                        .frame(width: 32, height: 32)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                
                                Button(action: {
                                    maxAppointments += 1
                                }) {
                                    Text("+")
                                        .font(.title2)
                                        .foregroundColor(primaryColor)
                                        .frame(width: 32, height: 32)
                                        .background(Color.white)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding()
                    }
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding()
                    
                    Spacer()
                        .frame(height: 70) // Space for tab bar
                }
            }
            .navigationBarTitle("Appointment Settings", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Profile")
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            .alert(isPresented: $showingTimeAlert) {
                Alert(
                    title: Text("Invalid Time Selection"),
                    message: Text(timeAlertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingStartTimePicker) {
                startTimePicker
            }
            .sheet(isPresented: $showingEndTimePicker) {
                endTimePicker
            }
            
            // Tab Bar
//            CustomTabBar(selectedTab: .home)
        }
    }
    
    // MARK: - Time Pickers
    
    var startTimePicker: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    showingStartTimePicker = false
                }
                .padding()
                
                Spacer()
                
                Button("Done") {
                    if !validateTime(start: startTime, end: endTime) {
                        timeAlertMessage = "Start time must be earlier than end time."
                        showingTimeAlert = true
                        // Reset to default valid time
                        startTime = "8:00 AM"
                    }
                    showingStartTimePicker = false
                }
                .padding()
                .bold()
            }
            
            Picker("Start Time", selection: $startTime) {
                ForEach(timeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
    
    var endTimePicker: some View {
        VStack {
            HStack {
                Button("Cancel") {
                    showingEndTimePicker = false
                }
                .padding()
                
                Spacer()
                
                Button("Done") {
                    if !validateTime(start: startTime, end: endTime) {
                        timeAlertMessage = "End time must be later than start time."
                        showingTimeAlert = true
                        // Reset to default valid time
                        endTime = "6:00 PM"
                    }
                    showingEndTimePicker = false
                }
                .padding()
                .bold()
            }
            
            Picker("End Time", selection: $endTime) {
                ForEach(timeOptions, id: \.self) { time in
                    Text(time).tag(time)
                }
            }
            .pickerStyle(WheelPickerStyle())
        }
    }
    
    // MARK: - Helper Methods
    
    func validateTime(start: String, end: String) -> Bool {
        let startMinutes = timeToMinutes(start)
        let endMinutes = timeToMinutes(end)
        return startMinutes < endMinutes
    }
    
    func timeToMinutes(_ timeString: String) -> Int {
        let components = timeString.components(separatedBy: CharacterSet(charactersIn: ": "))
        var hour = 0
        var minute = 0
        
        if components.count >= 3 {
            hour = Int(components[0]) ?? 0
            minute = Int(components[1]) ?? 0
            let ampm = components[2]
            
            // Adjust for PM
            if ampm.contains("PM") && hour < 12 {
                hour += 12
            }
            
            // Adjust for 12 AM
            if ampm.contains("AM") && hour == 12 {
                hour = 0
            }
        }
        
        return hour * 60 + minute
    }
}

struct AppointmentSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AppointmentSettingsView()
        }
    }
}
