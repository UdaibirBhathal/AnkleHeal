//
//  NewAppointmentRequestView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct NewAppointmentRequestView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject private var authManager = AuthStateManager.shared

    // Selection state
    @State private var isSelectionMode = false
    @State private var selectedRequests = Set<UUID>()
    @State private var allRequests: [AppointmentRequest] = []
    let calendar = Calendar.current

    // Store requests in UserDefaults
    let requestsUserDefaultsKey = "appointment_requests"

    // Colors
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let acceptColor = Color.green
    let rejectColor = Color.red

    private var appointmentListSection: some View {
        ScrollView {
            if allRequests.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 0) {
                    if isSelectionMode {
                        // Select All button when in selection mode
                        Button(action: toggleSelectAll) {
                            HStack {
                                Text(isAllSelected ? "Deselect All" : "Select All")
                                    .foregroundColor(primaryColor)
                                    .font(.system(size: 16, weight: .medium))
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(Color.white)
                        }
                        Divider()
                    }
                    
                    ForEach(allRequests) { request in
                        RequestRow(
                            request: request,
                            isSelectionMode: isSelectionMode,
                            isSelected: selectedRequests.contains(request.id),
                            onSelect: {
                                toggleSelection(for: request)
                            }
                        )

                        if request.id != allRequests.last?.id {
                            Divider().padding(.leading)
                        }
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .padding()
            }

            Spacer()
        }
    }

    private struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 20) {
                Spacer().frame(height: 50)

                Image(systemName: "calendar.badge.clock")
                    .font(.system(size: 60))
                    .foregroundColor(Color.gray.opacity(0.6))
                    .padding()

                Text("No Appointment Requests")
                    .font(.headline)
                    .foregroundColor(.black)

                Text("There are currently no appointment requests waiting for your review.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
    }
    
    // Computed property to check if all items are selected
    private var isAllSelected: Bool {
        return selectedRequests.count == allRequests.count && !allRequests.isEmpty
    }
    
    // Current physiotherapist ID from auth manager
    private var currentPhysiotherapistID: Int {
        return authManager.currentUserID
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                appointmentListSection
                    .padding(.bottom, isSelectionMode ? 80 : 0)
            }

            if isSelectionMode {
                HStack {
                    Button(action: acceptSelected) {
                        Text("Accept")
                            .font(.headline)
                            .foregroundColor(selectedRequests.isEmpty ? secondaryTextColor.opacity(0.5) : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(selectedRequests.isEmpty ? Color.gray.opacity(0.3) : acceptColor)
                            .cornerRadius(8)
                    }
                    .disabled(selectedRequests.isEmpty)
                    .padding(.horizontal, 5)

                    Button(action: rejectSelected) {
                        Text("Reject")
                            .font(.headline)
                            .foregroundColor(selectedRequests.isEmpty ? secondaryTextColor.opacity(0.5) : .white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(selectedRequests.isEmpty ? Color.gray.opacity(0.3) : rejectColor)
                            .cornerRadius(8)
                    }
                    .disabled(selectedRequests.isEmpty)
                    .padding(.horizontal, 5)
                }
                .padding()
                .background(Color.white)
                .shadow(radius: 2)
            }
        }
        .onAppear {
            loadAppointmentRequests()
        }
        .navigationBarTitle("Appointment Requests", displayMode: .inline)
        .navigationBarItems(trailing: Button(action: {
            isSelectionMode.toggle()
            selectedRequests.removeAll()
        }) {
            Text(isSelectionMode ? "Cancel" : "Select")
                .foregroundColor(allRequests.isEmpty ? secondaryTextColor : primaryColor)
        }
        .disabled(allRequests.isEmpty))
    }

    // Save appointment requests to UserDefaults
    private func saveAppointmentRequests() {
        do {
            let data = try JSONEncoder().encode(allRequests)
            UserDefaults.standard.set(data, forKey: requestsUserDefaultsKey)
            dataModel.setAppointmentRequests(allRequests)
        } catch {
            print("Error saving appointment requests: \(error)")
        }
    }
    
    // Load appointment requests - UPDATED TO FILTER BY CURRENT PHYSIOTHERAPIST
    private func loadAppointmentRequests() {
        // Get patients assigned to the current physiotherapist
        guard let physiotherapist = dataModel.getPhysiotherapist(by: currentPhysiotherapistID) else {
            allRequests = []
            return
        }
        
        let assignedPatientIDs = physiotherapist.patients
        
        // Only load pending requests for patients assigned to this physiotherapist
        allRequests = dataModel.appointmentRequests.filter { request in
            request.status == .pending && assignedPatientIDs.contains(request.patientID)
        }
    }

    // Toggle selection for all requests
    private func toggleSelectAll() {
        if isAllSelected {
            selectedRequests.removeAll()
        } else {
            selectedRequests = Set(allRequests.map { $0.id })
        }
    }

    private func toggleSelection(for request: AppointmentRequest) {
        if selectedRequests.contains(request.id) {
            selectedRequests.remove(request.id)
        } else {
            selectedRequests.insert(request.id)
        }
    }

    private func acceptSelected() {
        let selectedRequestsArray = allRequests.filter { selectedRequests.contains($0.id) }

        for request in selectedRequestsArray {
            let requestDate = parseRequestDate(dateString: request.date, timeString: request.time)
            let newPatientID = request.patientID

            let newAppointment = Appointment(
                patientID: newPatientID,
                appointmentID: Int.random(in: 10000...99999),
                date: requestDate,
                time: request.time,
                physiotherapistID: currentPhysiotherapistID, // Use current physiotherapist ID
                patientName: request.patientName,
                diagnosis: "Initial Assessment",
                status: true  // Set status to true (confirmed)
            )

            if var existingPatient = dataModel.getPatient(by: newPatientID) {
                // Check if there's already a pending appointment for this request
                let pendingIndex = existingPatient.appointmentHistory.firstIndex(where: { appointment in
                    calendar.isDate(appointment.date, inSameDayAs: requestDate) &&
                    appointment.time == request.time
                })
                
                if let index = pendingIndex {
                    // Update the existing appointment status to confirmed
                    existingPatient.appointmentHistory[index].status = true
                } else {
                    // Add the new confirmed appointment
                    existingPatient.appointmentHistory.append(newAppointment)
                }
                dataModel.updatePatient(existingPatient)
            } else {
                var newPatient = Patient(
                    id: newPatientID,
                    name: request.patientName,
                    dob: Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
                    gender: .other,
                    mobile: "",
                    email: "",
                    height: 170,
                    weight: 70,
                    injury: request.injury,
                    currentPhysiotherapistID: currentPhysiotherapistID, // Use current physiotherapist ID
                    location: Location(latitude: 0, longitude: 0)
                )
                newPatient.appointmentHistory = [newAppointment]
                dataModel.updatePatient(newPatient)
            }
            print("✅ Confirmed appointment for patientID \(newPatientID) at \(request.time) on \(request.date)")
        }
       
        // Update the appointment requests list
        allRequests.removeAll { selectedRequests.contains($0.id) }
        saveAppointmentRequests()
        isSelectionMode = false
        selectedRequests.removeAll()
    }

    private func parseRequestDate(dateString: String, timeString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy hh:mm a"
        let combined = dateString + " " + timeString
        return dateFormatter.date(from: combined) ??
               Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    }

    private func rejectSelected() {
        let selectedRequestsArray = allRequests.filter { selectedRequests.contains($0.id) }
        
        // For each rejected request, update any pending appointments to cancelled
        for request in selectedRequestsArray {
            let requestDate = parseRequestDate(dateString: request.date, timeString: request.time)
            let patientID = request.patientID
            
            // Find and update the patient's pending appointment to cancelled
            if var patient = dataModel.getPatient(by: patientID) {
                let pendingIndex = patient.appointmentHistory.firstIndex(where: { appointment in
                    calendar.isDate(appointment.date, inSameDayAs: requestDate) &&
                    appointment.time == request.time
                })
                
                if let index = pendingIndex {
                    // Update the status to cancelled (false)
                    patient.appointmentHistory[index].status = false
                    dataModel.updatePatient(patient)
                    
                    print("❌ Rejected appointment for patientID \(patientID) at \(request.time) on \(request.date)")
                }
            }
        }
        
        // Remove the requests from the list
        allRequests.removeAll { selectedRequests.contains($0.id) }
        saveAppointmentRequests()
        isSelectionMode = false
        selectedRequests.removeAll()
    }
}

// MARK: - RequestRow Definition
struct RequestRow: View {
    let request: AppointmentRequest
    let isSelectionMode: Bool
    let isSelected: Bool
    let onSelect: () -> Void

    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5)
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90)

    var body: some View {
        HStack {
            if isSelectionMode {
                Button(action: onSelect) {
                    Circle()
                        .strokeBorder(secondaryTextColor, lineWidth: 1)
                        .background(isSelected ? Circle().fill(primaryColor.opacity(0.2)) : Circle().fill(Color.white))
                        .overlay(
                            isSelected ?
                                Image(systemName: "checkmark")
                                    .foregroundColor(primaryColor)
                                    .font(.system(size: 10, weight: .bold)) : nil
                        )
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing, 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(request.patientName)
                    .font(.body)
                    .foregroundColor(textColor)

                Text("\(request.date) at \(request.time)")
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
                
                // Added injury type info
                Text(getInjuryString(request.injury))
                    .font(.caption)
                    .foregroundColor(primaryColor)
                    .padding(.top, 2)
            }
            .padding(.vertical, 12)

            Spacer()
        }
        .padding(.horizontal)
        .background(Color.white)
    }
    
    // Helper function to get formatted injury string
    private func getInjuryString(_ injury: Injury) -> String {
        switch injury {
        case .grade1:
            return "Grade 1 Sprain"
        case .grade2:
            return "Grade 2 Sprain"
        case .grade3:
            return "Grade 3 Sprain"
        case .ligamentTear:
            return "Ligament Tear"
        case .inversion:
            return "Inversion Injury"
        case .other(let description):
            return description
        }
    }
}

// Extension to apply corner radius to specific corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
