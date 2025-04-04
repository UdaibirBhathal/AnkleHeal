//
//  SwiftUIView.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//

import SwiftUI
import Charts


struct ProgressTrackerView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProgressTrackerView()
            
            
        }
    }
}

struct ProgressTrackerView: View {
    @State private var currentWeekIndex: Int = 2  // Start with the most recent week
    @State private var exerciseLogs: [[ExerciseLog]] = []
    @ObservedObject private var dataModel = AnkleHealDataModel.shared
    
    let days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    let calendar = Calendar.current
    
    // Apple Health inspired colors
    let healthBlue = Color.blue
    let healthGreen = Color.green
    let gridColor = Color(white: 0.9)
    let secondaryTextColor = Color.gray
    let backgroundColor = AppColors.backgroundColor
    
    // Get the current patient ID from AuthManager
    private var patientID: Int {
        return AuthStateManager.shared.currentUserID > 0 ?
            AuthStateManager.shared.currentUserID : 1
    }

    init() {
        let startingFrom = Calendar.current.date(byAdding: .weekOfYear, value: -2, to: Date()) ?? Date()
        self._exerciseLogs = State(initialValue: Self.generateDummyData(startingFrom: startingFrom))
        
        // Ensure today's progress is calculated but don't trigger publishing changes
        DispatchQueue.main.async {
            let patientID = AuthStateManager.shared.currentUserID > 0 ?
                           AuthStateManager.shared.currentUserID : 1
            
            AnkleHealDataModel.shared.calculateTodayProgress(for: patientID)
        }
    }

    static func generateDummyData(startingFrom: Date) -> [[ExerciseLog]] {
        var weeks: [[ExerciseLog]] = []
        let calendar = Calendar.current
        for weekOffset in 0..<3 {
            let weekStart = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: startingFrom) ?? startingFrom
            var weekData: [ExerciseLog] = []
            for dayOffset in 0..<7 {
                let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) ?? weekStart
                
                // Customize data based on week/day
                var adherenceValue = Int.random(in: 5...15)
                var painLevel = Int.random(in: 2...5)
                
                // Make current week have better values
                if weekOffset == 2 {
                    adherenceValue = Int.random(in: 12...20) // Higher adherence for current week
                    painLevel = Int.random(in: 1...4) // Lower pain for current week
                    
                    // Make latest day (today) have perfect adherence
                    if dayOffset == 6 {
                        adherenceValue = 20 // Max sets for 100% adherence
                        painLevel = 1 // Minimum pain
                    }
                }
                
                weekData.append(ExerciseLog(
                    logID: weekOffset * 7 + dayOffset + 1,
                    exerciseID: 1,
                    userID: 1,
                    date: date,
                    reps: Int.random(in: 8...15),
                    sets: adherenceValue,
                    painLevel: painLevel)
                )
            }
            weeks.append(weekData)
        }
        return weeks
    }

    var adherenceData: [Int] {
        exerciseLogs[currentWeekIndex].map { $0.sets }
    }

    var painData: [Int] {
        exerciseLogs[currentWeekIndex].map { $0.painLevel }
    }

    // Calculate adherence as percentage of the maximum possible (20 sets)
    var averageAdherence: Int {
        // For the current week view, use the actual progress data
        if currentWeekIndex == 2 {
            return Int(dataModel.getTodayProgressPercentage(for: patientID))
        }
        
        let maxPossibleSets = 20
        let totalSets = adherenceData.reduce(0, +)
        let percentage = (Double(totalSets) / (Double(adherenceData.count) * Double(maxPossibleSets))) * 100
        return Int(percentage)
    }

    var averagePain: Double {
        // For the current week view, use the actual pain data
        if currentWeekIndex == 2 {
            let pain = dataModel.getTodayAveragePain(for: patientID)
            // Return 5.0 if no pain data exists yet, otherwise return actual pain level
            return pain > 0 ? pain : 5.0
        }
        
        return Double(painData.reduce(0, +)) / Double(max(painData.count, 1))
    }
    
    func weekDateRange(for index: Int) -> String {
        let calendar = Calendar.current
        guard let firstDate = exerciseLogs[index].first?.date else { return "Unknown Date" }
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: firstDate)?.start ?? firstDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? firstDate
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: startOfWeek)) - \(formatter.string(from: endOfWeek))"
    }
    
    var weekTitle: String {
        if currentWeekIndex == 2 {
            return "This Week"
        } else if currentWeekIndex == 1 {
            return "Last Week"
        } else {
            return "2 Weeks Ago"
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Week selector - Apple Health style
                weekSelectorCard()
                
                // Summary metrics cards - Apple Health style
                HStack(spacing: 12) {
                    ProgressHealthMetricCard(
                        title: "Adherence",
                        value: "\(averageAdherence)%",
                        iconName: "figure.walk",
                        color: healthBlue
                    )
                    
                    ProgressHealthMetricCard(
                        title: "Pain Level",
                        value: String(format: "%.1f", averagePain),
                        iconName: "waveform.path.ecg",
                        color: healthGreen
                    )
                }
                .frame(maxWidth: .infinity, alignment: .center)  // Ensure HStack itself is centered
                .padding(.horizontal)

                
                // Adherence chart - Apple Health style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Exercise Adherence")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Chart {
                        ForEach(Array(zip(days, adherenceData)), id: \.0) { day, value in
                            LineMark(
                                x: .value("Day", day),
                                y: .value("Adherence", value)
                            )
                            .foregroundStyle(healthBlue.gradient)
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Day", day),
                                y: .value("Adherence", value)
                            )
                            .foregroundStyle(healthBlue.opacity(0.1).gradient)
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Day", day),
                                y: .value("Adherence", value)
                            )
                            .foregroundStyle(healthBlue)
                            .symbolSize(30)
                        }
                    }
                    .chartYScale(domain: 0...20)
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
                    
                    // Legend
                    HStack {
                        Circle()
                            .fill(healthBlue)
                            .frame(width: 10, height: 10)
                        Text("Sets Completed")
                            .font(.caption)
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
                
                // Pain chart - Apple Health style
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pain Level")
                        .font(.headline)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    
                    Chart {
                        ForEach(Array(zip(days, painData)), id: \.0) { day, value in
                            LineMark(
                                x: .value("Day", day),
                                y: .value("Pain", value)
                            )
                            .foregroundStyle(healthGreen.gradient)
                            .interpolationMethod(.catmullRom)
                            
                            AreaMark(
                                x: .value("Day", day),
                                y: .value("Pain", value)
                            )
                            .foregroundStyle(healthGreen.opacity(0.1).gradient)
                            .interpolationMethod(.catmullRom)
                            
                            PointMark(
                                x: .value("Day", day),
                                y: .value("Pain", value)
                            )
                            .foregroundStyle(healthGreen)
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
                    
                    // Legend
                    HStack {
                        Circle()
                            .fill(healthGreen)
                            .frame(width: 10, height: 10)
                        Text("Pain Level (0-10)")
                            .font(.caption)
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 1)
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
            .padding(.vertical)
            .background(backgroundColor)
        }
        .navigationTitle("Progress Tracker")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    @ViewBuilder
    private func weekSelectorCard() -> some View {
        VStack {
            HStack {
                Button(action: {
                    if currentWeekIndex > 0 {
                        currentWeekIndex -= 1
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(currentWeekIndex > 0 ? .blue : .gray)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 10)
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(weekTitle)
                        .font(.headline)
                    Text(weekDateRange(for: currentWeekIndex))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    if currentWeekIndex < exerciseLogs.count - 1 {
                        currentWeekIndex += 1
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(currentWeekIndex < exerciseLogs.count - 1 ? .blue : .gray)
                        .font(.system(size: 16, weight: .semibold))
                }
                .padding(.horizontal, 10)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// Apple Health-style metric card component
struct ProgressHealthMetricCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {  // Removed alignment to let it center naturally
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
