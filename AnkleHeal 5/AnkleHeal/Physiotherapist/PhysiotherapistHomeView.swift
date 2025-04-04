//
//  PhysiotherapistHomeView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//


import SwiftUI

struct PhysiotherapistHomeView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject var pinnedManager = PinnedPatientsManager.shared
    @StateObject var authManager = AuthStateManager.shared
    
    // Get physiotherapist ID dynamically from auth manager
    private var physiotherapistID: Int {
        return authManager.currentUserID
    }
    
    // Define the colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    // Formatted date for the header
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMM"
        return formatter.string(from: Date())
    }
    
    // Dynamic welcome message based on current user
    private var welcomeMessage: String {
        "Welcome, \n\(dataModel.getPhysiotherapist(by: physiotherapistID)?.name ?? "Doctor")"
    }
    
    // Get count of pending appointment requests
    private var pendingRequestsCount: Int {
        // Get patients assigned to the current physiotherapist
        guard let physiotherapist = dataModel.getPhysiotherapist(by: physiotherapistID) else {
            return 0
        }
        
        let assignedPatientIDs = physiotherapist.patients
        
        // Count only pending requests for patients assigned to this physiotherapist
        return dataModel.appointmentRequests.filter { request in
            request.status == .pending && assignedPatientIDs.contains(request.patientID)
        }.count
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Custom header
                VStack(alignment: .leading, spacing: 4) {
                    Text(formattedDate)
                        .font(.subheadline)
                        .foregroundColor(secondaryTextColor)
                    
                    HStack {
                        Text(welcomeMessage)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        
                        Spacer()
                        
                        NavigationLink(destination: PhysiotherapistProfileView(physiotherapistID: physiotherapistID)) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 30))
                                .foregroundColor(primaryColor)
                                .background(Circle().fill(Color.white))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Upcoming Appointments Section (Changed from Today's to Upcoming)
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Upcoming Appointments")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        
                        NavigationLink(destination: TodayAppointmentView(physiotherapistID: physiotherapistID)) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                    
                    // Get upcoming appointments sorted by date
                    let upcomingAppointments = getUpcomingAppointments()
                    
                    if upcomingAppointments.isEmpty {
                        Text("No upcoming appointments scheduled")
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                            .padding(.vertical, 12)
                            .padding(.horizontal)
                    } else {
                        ForEach(Array(upcomingAppointments.prefix(3)), id: \.appointmentID) { appointment in
                            NavigationLink(destination: PatientDetailView(appointment: appointment)) {
                                AppointmentRow(appointment: appointment)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            if appointment.appointmentID != upcomingAppointments.prefix(3).last?.appointmentID {
                                Divider()
                                    .padding(.leading)
                            }
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                
                // New Appointment Requests with badge count
                NavigationLink(destination: NewAppointmentRequestView()) {
                    HStack {
                        Text("New Appointment Requests")
                            .font(.headline)
                            .foregroundColor(textColor)
                        
                        if pendingRequestsCount > 0 {
                            Text("\(pendingRequestsCount)")
                                .font(.footnote)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(primaryColor)
                                .clipShape(Capsule())
                        }
                        
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(primaryColor)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal)
                
                // Patient Connect view
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Patient Connect")
                            .font(.headline)
                            .foregroundColor(textColor)
                        Spacer()
                        
                        NavigationLink(destination: PatientConnectView(physiotherapistID: physiotherapistID)) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(primaryColor)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        // Get pinned patients that belong to this physiotherapist
                        let pinnedPatients = dataModel.getAllPatients().filter {
                            $0.currentPhysiotherapistID == physiotherapistID &&
                            pinnedManager.isPinned($0.id)
                        }
                        
                        if pinnedPatients.isEmpty {
                            // Show message if no pinned patients
                            Text("No pinned patients. Pin a patient from the Connect screen.")
                                .font(.subheadline)
                                .foregroundColor(secondaryTextColor)
                                .padding()
                                .frame(width: UIScreen.main.bounds.width - 40)
                        } else {
                            HStack(spacing: 12) {
                                ForEach(pinnedPatients, id: \.id) { patient in
                                    NavigationLink(destination: PatientProgressView(patient: patient)) {
                                        PatientConnectCard(patient: patient)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.gray.opacity(0.1), radius: 4, x: 0, y: 2)
                .padding(.horizontal)
                
                Spacer()
                    .frame(height: 80) // Space for tab bar
            }
        }
        .background(backgroundColor)
        .edgesIgnoringSafeArea(.bottom)
        // Hide the navigation bar
        .navigationBarHidden(true)
    }
    
    // Helper function to get upcoming appointments sorted by date
    private func getUpcomingAppointments() -> [Appointment] {
        let calendar = Calendar.current
        let now = Date()
        
        // Get all appointments for this physiotherapist
        let allAppointments = dataModel.getAllDoctorAppointments(physioID: physiotherapistID)
        
        // Filter and remove duplicates
        let uniqueAppointments = allAppointments.filter { appointment in
            // Check if future date
            guard appointment.date >= now else { return false }
            
            // Check if confirmed
            guard appointment.status else { return false }
            
            // Check against appointment requests
            let pendingRequests = dataModel.appointmentRequests.filter { request in
                request.status == .pending &&
                request.patientID == appointment.patientID
            }
            
            // Exclude if there's a pending request for this appointment
            let hasMatchingPendingRequest = pendingRequests.contains { request in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd MMM, yyyy"
                let appointmentDateString = dateFormatter.string(from: appointment.date)
                
                return appointmentDateString == request.date &&
                       appointment.time == request.time
            }
            
            return !hasMatchingPendingRequest
        }
        
        // Remove duplicates based on patient ID, date, and time
        let deduplicatedAppointments = uniqueAppointments.reduce(into: [Appointment]()) { result, appointment in
            if !result.contains(where: {
                $0.patientID == appointment.patientID &&
                $0.date == appointment.date &&
                $0.time == appointment.time
            }) {
                result.append(appointment)
            }
        }
        
        return deduplicatedAppointments.sorted { $0.date < $1.date }
    }
    
    // MARK: - Appointment Row View
    struct AppointmentRow: View {
        var appointment: Appointment
        
        let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
        let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.patientName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(textColor)
                    
                    HStack(spacing: 12) {
                        Text(formattedDate(appointment.date))
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                        
                        Text(appointment.time)
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                        
                        Text(appointment.diagnosis)
                            .font(.subheadline)
                            .foregroundColor(secondaryTextColor)
                    }
                }
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.gray.opacity(0.5))
                    .font(.system(size: 14))
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        
        // Format date as "18 Mar"
        private func formattedDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            return formatter.string(from: date)
        }
    }

    // MARK: - Patient Connect Card View
    struct PatientConnectCard: View {
        var patient: Patient
        
        let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
        let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
        let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
        
        // Get latest appointment date string
        private var appointmentDateString: String {
            if let latestAppointment = patient.appointmentHistory.max(by: { $0.date < $1.date }) {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE d MMM, yyyy"
                let dateString = formatter.string(from: latestAppointment.date)
                return dateString
            } else {
                return "No appointment"
            }
        }
        
        // Get latest appointment time
        private var appointmentTime: String {
            if let latestAppointment = patient.appointmentHistory.max(by: { $0.date < $1.date }) {
                return latestAppointment.time
            }
            return ""
        }
        
        // Get injury string for display
        private func getInjuryString(_ injury: Injury?) -> String {
            guard let injury = injury else { return "No injury" }
            
            switch injury {
            case .grade1:
                return "Grade 1 ATFL"
            case .grade2:
                return "Grade 2 ATFL"
            case .grade3:
                return "Grade 3 ATFL"
            case .ligamentTear:
                return "Ligament Tear"
            case .inversion:
                return "Inversion"
            case .other(let description):
                return description
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(patient.name)
                    .font(.headline)
                    .foregroundColor(textColor)
                    .lineLimit(1)
                
                Text(getInjuryString(patient.injury))
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                    .lineLimit(1)
                
                if !appointmentDateString.contains("No") {
                    Text(appointmentDateString)
                        .font(.caption)
                        .foregroundColor(primaryColor)
                    
                    Text(appointmentTime)
                        .font(.caption)
                        .foregroundColor(primaryColor)
                }
            }
            .padding()
            .frame(width: 180, height: 120)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}
