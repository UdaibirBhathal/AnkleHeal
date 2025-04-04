//
//  PatientConnectView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

// Centralized manager for pinned patients
class PinnedPatientsManager: ObservableObject {
    static let shared = PinnedPatientsManager()
    
    @Published var pinnedPatientIDs: [Int] = []
    private let pinnedPatientIDsKey = "pinnedPatientIDs"
    
    init() {
        loadPinnedPatients()
    }
    
    func loadPinnedPatients() {
        if let data = UserDefaults.standard.data(forKey: pinnedPatientIDsKey) {
            do {
                pinnedPatientIDs = try JSONDecoder().decode([Int].self, from: data)
                objectWillChange.send()
            } catch {
                print("Error loading pinned patients: \(error)")
                pinnedPatientIDs = []
            }
        } else {
            pinnedPatientIDs = []
        }
    }
    
    func savePinnedPatients() {
        do {
            let data = try JSONEncoder().encode(pinnedPatientIDs)
            UserDefaults.standard.set(data, forKey: pinnedPatientIDsKey)
            objectWillChange.send()
        } catch {
            print("Error saving pinned patients: \(error)")
        }
    }
    
    func isPinned(_ patientID: Int) -> Bool {
        return pinnedPatientIDs.contains(patientID)
    }
    
    func togglePinStatus(_ patientID: Int) {
        if pinnedPatientIDs.contains(patientID) {
            // Unpin the patient
            pinnedPatientIDs.removeAll { $0 == patientID }
        } else {
            // Pin the patient
            pinnedPatientIDs.append(patientID)
        }
        savePinnedPatients()
    }
}

struct PatientConnectView: View {
    @StateObject var dataModel = AnkleHealDataModel.shared
    @StateObject var pinnedManager = PinnedPatientsManager.shared
    @Environment(\.presentationMode) var presentationMode
    var physiotherapistID: Int
    
    @State private var searchText = ""
    @State private var sortDescending = false
    @State private var showingAddPatient = false
    
    // Colors - matching the app's design system
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(secondaryTextColor)
                    TextField("Search", text: $searchText)
                    Image(systemName: "mic")
                        .foregroundColor(secondaryTextColor)
                }
                .padding(8)
                .background(Color.white)
                .cornerRadius(10)
                .padding()
                
                // Content
                ScrollView {
                    VStack(spacing: 16) {
                        // Pinned Patients section
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Pinned Patients")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal)
                                .padding(.bottom, 8)
                            
                            if pinnedPatients.isEmpty {
                                Text("No pinned patients")
                                    .foregroundColor(secondaryTextColor)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            } else {
                                VStack(spacing: 0) {
                                    ForEach(pinnedPatients, id: \.id) { patient in
                                        NavigationLink(destination: PatientProgressView(patient: patient)) {
                                            PatientRowWithPin(patient: patient)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .background(Color.white)
                                .cornerRadius(10)
                                .padding(.horizontal)
                            }
                        }
                        
                        // All Patients section
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("All Patients")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Spacer()
                                
                                Button(action: {
                                    sortDescending.toggle()
                                }) {
                                    Image(systemName: sortDescending ? "arrow.down" : "arrow.up")
                                        .foregroundColor(primaryColor)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                            
                            VStack(spacing: 0) {
                                ForEach(allPatientsFiltered, id: \.id) { patient in
                                    NavigationLink(destination: PatientProgressView(patient: patient)) {
                                        PatientRowWithPin(patient: patient)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .background(Color.white)
                            .cornerRadius(10)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 80) // Space for tab bar
                }
            }
            .navigationBarTitle("Patient Connect", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Home")
                    }
                },
                trailing: Button(action: {
                    showingAddPatient = true
                }) {
                    Image(systemName: "plus")
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            .sheet(isPresented: $showingAddPatient) {
                NavigationView {
                    AddPatientView(physiotherapistID: physiotherapistID)
                }
            }
            
            // Tab Bar at the bottom
            // CustomTabBar(selectedTab: .home)
        }
    }
    
    // Helper function to convert injury to display string
    private func getInjuryString(_ injury: Injury?) -> String {
        guard let injury = injury else { return "No injury" }
        
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
    
    // Computed properties for filtered lists
    private var allPatients: [Patient] {
        let patients = dataModel.getAllPatients()
            .filter { $0.currentPhysiotherapistID == physiotherapistID }
        
        return sortDescending ?
            patients.sorted(by: { $0.name > $1.name }) :
            patients.sorted(by: { $0.name < $1.name })
    }
    
    private var allPatientsFiltered: [Patient] {
        if searchText.isEmpty {
            return allPatients.filter { !pinnedManager.isPinned($0.id) }
        } else {
            return allPatients
                .filter { !pinnedManager.isPinned($0.id) || searchText.count > 0 }
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    private var pinnedPatients: [Patient] {
        if searchText.isEmpty {
            return allPatients.filter { pinnedManager.isPinned($0.id) }
        } else {
            return allPatients
                .filter { pinnedManager.isPinned($0.id) }
                .filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
}

// Updated component for patient rows with pin/unpin functionality
struct PatientRowWithPin: View {
    var patient: Patient
    @ObservedObject var pinnedManager = PinnedPatientsManager.shared
    
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    
    // Helper function to convert injury to display string
    private func getInjuryString(_ injury: Injury?) -> String {
        guard let injury = injury else { return "No injury" }
        
        switch injury {
        case .grade1:
            return "PTFL Grade 1"
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
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(textColor)
                
                Text(getInjuryString(patient.injury))
                    .font(.subheadline)
                    .foregroundColor(secondaryTextColor)
            }
            .padding(.vertical, 12)
            
            Spacer()
            
            // Pin/Unpin button - now using the pinnedManager
            Button(action: {
                pinnedManager.togglePinStatus(patient.id)
            }) {
                Image(systemName: pinnedManager.isPinned(patient.id) ? "pin.slash.fill" : "pin.fill")
                    .foregroundColor(pinnedManager.isPinned(patient.id) ? .red : primaryColor)
                    .padding(.horizontal, 8)
            }
            
            Image(systemName: "chevron.right")
                .foregroundColor(secondaryTextColor)
        }
        .padding(.horizontal)
        .background(Color.white)
        
        Divider()
            .padding(.leading)
    }
}

struct PatientConnectView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PatientConnectView(physiotherapistID: 1)
        }
    }
}
