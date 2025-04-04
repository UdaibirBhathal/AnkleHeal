//
//  PatientProgressView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI
import Charts



struct PatientProgressView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    @State private var patient: Patient
    @State private var showingExerciseSheet = false
    
    // Colors - Apple Health-inspired
    let primaryColor = AppColors.primaryColor
    let backgroundColor = AppColors.backgroundColor
    let textColor = AppColors.textColor
    let secondaryTextColor = AppColors.secondaryTextColor
    let adherenceColor = Color.blue // Apple Health blue
    let painColor = Color.green // Apple Health green
    let gridColor = Color(white: 0.9)
    
    // Mock data for the chart (will be replaced with real data)
    @State private var dailyStats = [
        DailyStatData(day: "Mon", adherence: 9.0, pain: 2.0),
        DailyStatData(day: "Tue", adherence: 8.0, pain: 5.0),
        DailyStatData(day: "Wed", adherence: 7.0, pain: 4.0),
        DailyStatData(day: "Thu", adherence: 8.0, pain: 2.0),
        DailyStatData(day: "Fri", adherence: 9.0, pain: 1.0),
        DailyStatData(day: "Sat", adherence: 9.0, pain: 1.0),
        DailyStatData(day: "Sun", adherence: 10.0, pain: 0.0)
    ]
    
    init(patient: Patient) {
        _patient = State(initialValue: patient)
    }
    
    // Computed properties for display
    private var averageAdherence: Double {
        let total = dailyStats.reduce(0.0) { $0 + $1.adherence }
        return total / Double(dailyStats.count)
    }
    
    private var averageAdherencePercentage: Int {
        return Int((averageAdherence / 10.0) * 100)
    }
    
    private var averagePain: Double {
        let total = dailyStats.reduce(0.0) { $0 + $1.pain }
        return (total / Double(dailyStats.count)).rounded(to: 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Navigation bar (custom)
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.blue)
                        .imageScale(.large)
                }
                
                Spacer()
                
                Text(patient.name)
                    .font(.headline)
                
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Injury type section
                    VStack(alignment: .leading) {
                        Text("Injury Type")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        Text(getInjuryString(patient.injury))
                            .padding(.horizontal)
                            .padding(.bottom, 8)
                    }
                    
                    Divider()
                    
                    // Patient Progress section - Apple Health style
                    VStack(alignment: .leading) {
                        Text("Patient Progress")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, 8)
                        
                        // Summary metrics - Apple Health style cards
                        HStack(spacing: 12) {
                            HealthMetricCard(
                                title: "Adherence",
                                value: "\(averageAdherencePercentage)%",
                                iconName: "figure.walk",
                                color: adherenceColor
                            )
                            
                            HealthMetricCard(
                                title: "Pain Level",
                                value: String(format: "%.1f", averagePain),
                                iconName: "waveform.path.ecg",
                                color: painColor
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .center)  // Ensure HStack itself is centered
                        .padding(.horizontal)
                        .padding(.top, 8)

                        
                        // Adherence Chart - Apple Health style
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise Adherence")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            
                            // Apple Health-style line chart for adherence
                            Chart {
                                ForEach(Array(dailyStats.enumerated()), id: \.1.id) { index, stat in
                                    if index > 0 {
                                        LineMark(
                                            x: .value("Day", stat.day),
                                            y: .value("Adherence", stat.adherence)
                                        )
                                        .foregroundStyle(adherenceColor.gradient)
                                        .interpolationMethod(.catmullRom) // Smooth curve
                                    }
                                    
                                    AreaMark(
                                        x: .value("Day", stat.day),
                                        y: .value("Adherence", stat.adherence)
                                    )
                                    .foregroundStyle(adherenceColor.opacity(0.1).gradient)
                                    .interpolationMethod(.catmullRom) // Smooth curve
                                    
                                    PointMark(
                                        x: .value("Day", stat.day),
                                        y: .value("Adherence", stat.adherence)
                                    )
                                    .foregroundStyle(adherenceColor)
                                    .symbolSize(30)
                                }
                            }
                            .chartYScale(domain: 0...10)
                            .chartYAxis {
                                AxisMarks(position: .leading) {
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(gridColor)
                                    AxisValueLabel()
                                        .foregroundStyle(secondaryTextColor)
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                            
                            // X-axis labels
                            HStack {
                                ForEach(dailyStats, id: \.id) { stat in
                                    Text(stat.day)
                                        .font(.caption)
                                        .foregroundColor(secondaryTextColor)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            // Legend
                            HStack {
                                Circle()
                                    .fill(adherenceColor)
                                    .frame(width: 10, height: 10)
                                Text("Adherence (0-10)")
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                        
                        // Pain Chart - Apple Health style
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Pain Level")
                                .font(.headline)
                                .padding(.horizontal)
                                .padding(.top, 8)
                            
                            // Apple Health-style line chart for pain
                            Chart {
                                ForEach(Array(dailyStats.enumerated()), id: \.1.id) { index, stat in
                                    if index > 0 {
                                        LineMark(
                                            x: .value("Day", stat.day),
                                            y: .value("Pain", stat.pain)
                                        )
                                        .foregroundStyle(painColor.gradient)
                                        .interpolationMethod(.catmullRom) // Smooth curve
                                    }
                                    
                                    AreaMark(
                                        x: .value("Day", stat.day),
                                        y: .value("Pain", stat.pain)
                                    )
                                    .foregroundStyle(painColor.opacity(0.1).gradient)
                                    .interpolationMethod(.catmullRom) // Smooth curve
                                    
                                    PointMark(
                                        x: .value("Day", stat.day),
                                        y: .value("Pain", stat.pain)
                                    )
                                    .foregroundStyle(painColor)
                                    .symbolSize(30)
                                }
                            }
                            .chartYScale(domain: 0...10)
                            .chartYAxis {
                                AxisMarks(position: .leading) {
                                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5))
                                        .foregroundStyle(gridColor)
                                    AxisValueLabel()
                                        .foregroundStyle(secondaryTextColor)
                                }
                            }
                            .frame(height: 200)
                            .padding(.horizontal)
                            
                            // X-axis labels
                            HStack {
                                ForEach(dailyStats, id: \.id) { stat in
                                    Text(stat.day)
                                        .font(.caption)
                                        .foregroundColor(secondaryTextColor)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 25)
                            
                            // Legend
                            HStack {
                                Circle()
                                    .fill(painColor)
                                    .frame(width: 10, height: 10)
                                Text("Pain Level (0-10)")
                                    .font(.caption)
                                    .foregroundColor(secondaryTextColor)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                    
                    Divider()
                    
                    // Exercises section
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Exercises Assigned")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Add exercise button
                            Button(action: {
                                showingExerciseSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(primaryColor)
                                    .font(.system(size: 16))
                                    .padding(8)
                                    .background(Circle().fill(Color.white))
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        if patient.exercises.isEmpty {
                            Text("No exercises assigned yet")
                                .foregroundColor(secondaryTextColor)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .center)
                        } else {
                            ForEach(Array(patient.exercises.enumerated()), id: \.1.exerciseID) { index, exercise in
                                HStack(alignment: .top) {
                                    Text("\(index + 1).")
                                        .fontWeight(.semibold)
                                    
                                    Text(exercise.name)
                                        .fontWeight(.semibold)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .padding(.bottom, 50)
                }
            }
        }
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            loadPatientData()
        }
        .sheet(isPresented: $showingExerciseSheet) {
            EnhancedExerciseSelectionSheet(
                patient: patient,
                onComplete: { updatedExercises in
                    updatePatientExercises(exercises: updatedExercises)
                }
            )
        }
    }
    
    // Helper method to load data from the patient's exercise logs
    private func loadPatientData() {
        // Check if patient has exercise logs
        if !patient.exerciseLogs.isEmpty {
            // Group logs by day of week
            let calendar = Calendar.current
            let weekdaySymbols = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
            
            var statsDict: [String: (adherenceTotal: Double, painTotal: Double, count: Int)] = [:]
            
            // Initialize dictionary with all days of the week
            for day in weekdaySymbols {
                statsDict[day] = (0, 0, 0)
            }
            
            // Process each log
            for log in patient.exerciseLogs {
                let weekday = calendar.component(.weekday, from: log.date) - 1 // 0-based index
                let daySymbol = weekdaySymbols[weekday == 0 ? 6 : weekday - 1] // Adjust for weekday (1=Sunday in Calendar)
                
                let adherenceValue = Double(log.sets * log.reps) / 100.0 * 10.0 // Scale to 0-10
                let painValue = Double(log.painLevel)
                
                let current = statsDict[daySymbol] ?? (0, 0, 0)
                statsDict[daySymbol] = (
                    current.adherenceTotal + adherenceValue,
                    current.painTotal + painValue,
                    current.count + 1
                )
            }
            
            // Calculate averages and create daily stats
            var newStats: [DailyStatData] = []
            
            for day in weekdaySymbols {
                let stat = statsDict[day] ?? (0, 0, 0)
                let adherence = stat.count > 0 ? stat.adherenceTotal / Double(stat.count) : 0
                let pain = stat.count > 0 ? stat.painTotal / Double(stat.count) : 0
                
                newStats.append(DailyStatData(
                    day: day,
                    adherence: min(10, max(0, adherence)), // Ensure in range 0-10
                    pain: min(10, max(0, pain)) // Ensure in range 0-10
                ))
            }
            
            // If we have data, update the state
            if !newStats.isEmpty {
                self.dailyStats = newStats
            }
        }
        
        // Refresh patient data
        if let updatedPatient = dataModel.getPatient(by: patient.id) {
            self.patient = updatedPatient
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
    
    // Update patient's exercises
    private func updatePatientExercises(exercises: [Exercise]) {
        var updatedPatient = patient
        updatedPatient.exercises = exercises
        dataModel.updatePatient(updatedPatient)
        self.patient = updatedPatient
    }
}

// Apple Health-style metric card
struct HealthMetricCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color

    var body: some View {
        VStack(spacing: 12) {  // Removed alignment to let it center naturally
            Text(value)
                .font(.system(size: 38, weight: .bold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)  // Forces the text to take full width and center itself
                .multilineTextAlignment(.center)  // Explicitly centers the text
            
            .frame(maxWidth: .infinity, alignment: .center)  // Ensures the HStack is centered

            HStack {
                Image(systemName: iconName)
                    .foregroundColor(color)
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.textColor)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)  // Ensure the whole card stretches
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}
// Enhanced Exercise Selection Sheet with pre-selected exercises and toggle functionality
struct EnhancedExerciseSelectionSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var dataModel = AnkleHealDataModel.shared
    
    let patient: Patient
    let onComplete: ([Exercise]) -> Void
    
    @State private var selectedExerciseIDs = Set<Int>()
    @State private var allExercises: [Exercise] = []
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90)
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94)
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(allExercises, id: \.exerciseID) { exercise in
                        HStack {
                            Button(action: {
                                toggleExerciseSelection(exercise.exerciseID)
                            }) {
                                HStack {
                                    // Selection circle
                                    Circle()
                                        .fill(selectedExerciseIDs.contains(exercise.exerciseID) ? primaryColor : Color.white)
                                        .frame(width: 22, height: 22)
                                        .overlay(
                                            Circle()
                                                .stroke(selectedExerciseIDs.contains(exercise.exerciseID) ? primaryColor : Color.gray.opacity(0.5), lineWidth: 1.5)
                                        )
                                    
                                    Text(exercise.name)
                                        .foregroundColor(textColor)
                                        .padding(.leading, 8)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                // Save button
                Button(action: {
                    // Build updated exercise list
                    let selectedExercises = allExercises.filter { selectedExerciseIDs.contains($0.exerciseID) }
                    onComplete(selectedExercises)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Save Exercise Plan")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarTitle("Manage Exercises", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
            .onAppear {
                // Load all exercises and pre-select the ones already assigned
                loadAllExercises()
                preSelectExistingExercises()
            }
        }
    }
    
    // Load all available exercises
    private func loadAllExercises() {
        allExercises = dataModel.getAllExercises()
    }
    
    // Pre-select exercises already assigned to the patient
    private func preSelectExistingExercises() {
        for exercise in patient.exercises {
            selectedExerciseIDs.insert(exercise.exerciseID)
        }
    }
    
    // Toggle selection of an exercise
    private func toggleExerciseSelection(_ exerciseID: Int) {
        if selectedExerciseIDs.contains(exerciseID) {
            selectedExerciseIDs.remove(exerciseID)
        } else {
            selectedExerciseIDs.insert(exerciseID)
        }
    }
}

// Data model for chart
struct DailyStatData: Identifiable {
    var id = UUID()
    var day: String
    var adherence: Double
    var pain: Double
}

// Extension for rounding to decimal places
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
