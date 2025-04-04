//
//  TodayAppointmentView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct TodayAppointmentView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingRescheduleAlert = false
    var physiotherapistID: Int
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let rescheduleColor = Color.red // Red color for reschedule
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // List of Appointments
                if todaysAppointments.isEmpty {
                    VStack(spacing: 20) {
                        Spacer().frame(height: 50)
                        
                        Image(systemName: "calendar")
                            .font(.system(size: 60))
                            .foregroundColor(secondaryTextColor.opacity(0.6))
                            .padding()
                        
                        Text("No Appointments Today")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        Text("You don't have any appointments scheduled for today.")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    List {
                        ForEach(todaysAppointments, id: \.appointmentID) { appointment in
                            NavigationLink(destination: PatientDetailView(appointment: appointment)) {
                                AppointmentRowDetailed(appointment: appointment)
                            }
                        }
                    }
                    .listStyle(PlainListStyle()) // Use plain list style for clean look
                }
            }
            .navigationBarTitle("Today's Appointments", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                },
                trailing: Button("Reschedule") {
                    showingRescheduleAlert = true
                }
                .foregroundColor(rescheduleColor)
                .opacity(todaysAppointments.isEmpty ? 0.5 : 1.0)
                .disabled(todaysAppointments.isEmpty)
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            .alert(isPresented: $showingRescheduleAlert) {
                Alert(
                    title: Text("Reschedule All Appointments"),
                    message: Text("Are you sure you want to reschedule all appointments?"),
                    primaryButton: .destructive(Text("Yes")) {
                        deleteAllTodaysAppointments()
                    },
                    secondaryButton: .cancel(Text("No"))
                )
            }
            
            // Tab Bar at the bottom
            // CustomTabBar(selectedTab: .home)
        }
    }
    
    // Get today's appointments for this physiotherapist
    private var todaysAppointments: [Appointment] {
        // Use the getTodayAppointments method to get only today's appointments
        return dataModel.getTodayAppointments(physioID: physiotherapistID)
    }
    
    // Function to delete today's appointments
    private func deleteAllTodaysAppointments() {
        for appointment in todaysAppointments {
            dataModel.cancelAppointment(appointmentID: appointment.appointmentID)
        }
        // Navigate back after deletion
        presentationMode.wrappedValue.dismiss()
    }
}

struct AppointmentRowDetailed: View {
    var appointment: Appointment
    
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(appointment.patientName)
                    .font(.headline)
                    .foregroundColor(textColor)
                Text("\(appointment.time) \(appointment.diagnosis)")
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(secondaryTextColor)
        }
        .padding(.vertical, 8)
    }
}

struct TodayAppointmentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TodayAppointmentView(physiotherapistID: 1)
        }
    }
}
