//
//  AddPatientView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    
    // Form fields
    @State private var name = ""
    @State private var age = 30
    @State private var height = 170
    @State private var weight = 70
    @State private var medicalHistory = ""
    @State private var selectedInjury: Injury = .other(description: "Initial Assessment")
    
    // Sheet control states
    @State private var showingAgePicker = false
    @State private var showingHeightPicker = false
    @State private var showingWeightPicker = false
    
    // Current physiotherapist ID
    var physiotherapistID: Int
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let buttonColor = Color(red: 0.25, green: 0.55, blue: 0.83) // Darker blue for buttons
    let tagBackgroundColor = Color(red: 0.9, green: 0.95, blue: 1.0) // Very light blue for tags
    
    // Injury types for selection
    let injuryTypes: [(injury: Injury, label: String, description: String)] = [
        (.grade1, "Grade 1", "Mild ankle sprain"),
        (.grade2, "Grade 2", "Moderate ankle sprain"),
        (.grade3, "Grade 3", "Severe ankle sprain"),
        (.ligamentTear, "Ligament Tear", "Torn ankle ligament"),
        (.inversion, "Inversion", "Inversion ankle injury"),
        (.other(description: "Other"), "Other", "Other ankle injury")
    ]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Personal Details Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Personal Details")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        
                        // Name field
                        HStack {
                            Text("Name")
                                .font(.headline)
                                .foregroundColor(textColor)
                                .frame(width: 100, alignment: .leading)
                            
                            TextField("", text: $name)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Color.white)
                                .cornerRadius(5)
                        }
                        
                        // Age picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Age")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            Button(action: {
                                withAnimation {
                                    showingAgePicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text("\(age) years")
                                        .foregroundColor(textColor)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            }
                            
                            if showingAgePicker {
                                Picker("", selection: $age) {
                                    ForEach(1...100, id: \.self) { value in
                                        Text("\(value)").tag(value)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                .frame(maxHeight: 150)
                            }
                        }
                        // Height picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Height")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            Button(action: {
                                withAnimation {
                                    showingHeightPicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text("\(height) cm")
                                        .foregroundColor(textColor)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            }
                            
                            if showingHeightPicker {
                                Picker("", selection: $height) {
                                    ForEach(100...220, id: \.self) { value in
                                        Text("\(value)").tag(value)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                .frame(maxHeight: 150)
                            }
                        }
                        // Weight picker
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Weight")
                                .font(.headline)
                                .foregroundColor(textColor)
                            
                            Button(action: {
                                withAnimation {
                                    showingWeightPicker.toggle()
                                }
                            }) {
                                HStack {
                                    Text("\(weight) kg")
                                        .foregroundColor(textColor)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.4), lineWidth: 1))
                            }
                            
                            if showingWeightPicker {
                                Picker("", selection: $height) {
                                    ForEach(30...150, id: \.self) { value in
                                        Text("\(value)").tag(value)
                                    }
                                }
                                .pickerStyle(WheelPickerStyle())
                                .labelsHidden()
                                .frame(maxHeight: 150)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Injury Type Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Injury Type")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        
                        // Injury type tags
                        FlowLayout(spacing: 10) {
                            ForEach(injuryTypes, id: \.label) { injury in
                                InjuryTypeTag(
                                    label: injury.label,
                                    description: injury.description,
                                    isSelected: compareInjuries(injury.injury, selectedInjury),
                                    onTap: {
                                        self.selectedInjury = injury.injury
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 5)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Medical History Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Medical History")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(textColor)
                        
                        TextEditor(text: $medicalHistory)
                            .frame(height: 120)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    // Add Button
                    Button(action: {
                        addPatient()
                    }) {
                        Text("Add")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                name.isEmpty || medicalHistory.isEmpty ?
                                buttonColor.opacity(0.5) : buttonColor
                            )
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .disabled(name.isEmpty || medicalHistory.isEmpty)
                    
                    Spacer()
                        .frame(height: 80) // Add space for tab bar
                }
            }
            .navigationBarTitle("Add Patient", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
        }
    }
    
    // Helper function to compare injuries for selection state
    private func compareInjuries(_ injury1: Injury, _ injury2: Injury) -> Bool {
        switch (injury1, injury2) {
        case (.grade1, .grade1),
             (.grade2, .grade2),
             (.grade3, .grade3),
             (.ligamentTear, .ligamentTear),
             (.inversion, .inversion):
            return true
        case (.other, .other):
            return true
        default:
            return false
        }
    }
    
    private func addPatient() {
        // Create a new patient ID
        let newPatientID = Int.random(in: 1000...9999)
        
        // Calculate DOB from age
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let birthYear = currentYear - age
        let dob = calendar.date(from: DateComponents(year: birthYear, month: 1, day: 1)) ?? Date()
        
        // Create new patient object
        let newPatient = Patient(
            id: newPatientID,
            name: name.isEmpty ? "New Patient" : name,
            dob: dob,
            gender: .other, // Default, can be updated later
            mobile: "",
            email: "",
            height: height,
            weight: weight,
            injury: selectedInjury,
            currentPhysiotherapistID: physiotherapistID,
            location: Location(latitude: 0, longitude: 0),
            locationDescription: nil
        )
        
        // Create a placeholder appointment for the new patient
        let appointmentID = Int.random(in: 10000...99999)
        let placeholderAppointment = Appointment(
            patientID: newPatientID,
            appointmentID: appointmentID,
            date: Date().addingTimeInterval(86400), // Tomorrow
            time: "10:00 AM",
            physiotherapistID: physiotherapistID,
            patientName: name.isEmpty ? "New Patient" : name,
            diagnosis: getInjuryString(selectedInjury),
            isExpanded: false,
            status: true
        )
        
        // Add the appointment to the patient
        var patientWithAppointment = newPatient
        patientWithAppointment.appointmentHistory = [placeholderAppointment]
        
        // Add the patient to the data model
        dataModel.addPatient(patient: patientWithAppointment, appointment: placeholderAppointment)
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
    
    // Helper function to convert injury to display string
    private func getInjuryString(_ injury: Injury) -> String {
        switch injury {
        case .grade1:
            return "ATFL Grade 1"
        case .grade2:
            return "ATFL Grade 2"
        case .grade3:
            return "ATFL Grade 3"
        case .ligamentTear:
            return "Ligament Tear"
        case .inversion:
            return "Inversion"
        case .other(let description):
            return description
        }
    }
}

// Tag view for injury type selection
struct InjuryTypeTag: View {
    let label: String
    let description: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .bold : .regular)
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10))
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                Color(red: 0.35, green: 0.64, blue: 0.90).opacity(0.2) :
                Color(red: 0.9, green: 0.95, blue: 1.0)
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                        Color(red: 0.35, green: 0.64, blue: 0.90) :
                        Color.gray.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}

// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var height: CGFloat = 0
        var width: CGFloat = 0
        var rowWidth: CGFloat = 0
        var rowHeight: CGFloat = 0
        
        for size in sizes {
            if rowWidth + size.width <= (proposal.width ?? .infinity) {
                rowWidth += size.width + spacing
                rowHeight = max(rowHeight, size.height)
            } else {
                width = max(width, rowWidth)
                height += rowHeight + spacing
                rowWidth = size.width + spacing
                rowHeight = size.height
            }
        }
        
        height += rowHeight
        width = max(width, rowWidth)
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if x + size.width <= bounds.maxX {
                rowHeight = max(rowHeight, size.height)
            } else {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = size.height
            }
            
            let point = CGPoint(x: x, y: y)
            subview.place(at: point, proposal: .unspecified)
            
            x += size.width + spacing
        }
    }
}

struct AddPatientView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddPatientView(physiotherapistID: 1)
        }
    }
}

