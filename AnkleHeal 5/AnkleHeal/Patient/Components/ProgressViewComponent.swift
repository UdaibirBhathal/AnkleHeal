//
//  ProgressViewComponent.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 14/03/25.
//
//
import SwiftUI

struct ProgressViewComponent: View {
    var patient: Patient
    @ObservedObject var dataModel = AnkleHealDataModel.shared

    var completedExercises: Int {
        let metrics = dataModel.todayProgressMetrics[patient.id]
        return metrics?.completed ?? 0
    }
    
    var totalExercises: Int {
        let metrics = dataModel.todayProgressMetrics[patient.id]
        return metrics?.total ?? patient.exercises.count
    }

    var progress: CGFloat {
        // If metrics haven't been calculated yet, calculate them now
        if dataModel.todayProgressMetrics[patient.id] == nil {
            dataModel.calculateTodayProgress(for: patient.id)
        }
        
        guard totalExercises > 0 else { return 0 }
        return CGFloat(completedExercises) / CGFloat(totalExercises)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Progress")
                .font(.headline)
                .foregroundColor(AppColors.textColor)

            HStack {
                ZStack {
                    Circle()
                        .trim(from: 0, to: 1)
                        .stroke(AppColors.secondaryTextColor.opacity(0.3), lineWidth: 12)
                        .frame(width: 80, height: 80)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(AppColors.primaryColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .frame(width: 80, height: 80)

                    Text("\(Int(progress * 100))%")
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(AppColors.textColor)
                }

                VStack(alignment: .leading) {
                    Text("Exercises Completed")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textColor)
                    Text("\(completedExercises) of \(totalExercises)")
                        .font(.headline)
                        .bold()
                        .foregroundColor(AppColors.primaryColor)
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(AppColors.cardBackgroundColor)
        .cornerRadius(12)
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview
struct ProgressViewComponent_Previews: PreviewProvider {
    static var previews: some View {
        let samplePatient = Patient(
            id: 1,
            name: "John Doe",
            dob: Date(),
            gender: .male,
            mobile: "5551234567",
            email: "johndoe@example.com",
            height: 175,
            weight: 70,
            injury: .grade2,
            currentPhysiotherapistID: 1,
            location: Location(latitude: 37.7749, longitude: -122.4194)
        )
        
        ProgressViewComponent(patient: samplePatient)
            .previewLayout(.sizeThatFits)
            .padding()
            .background(AppColors.backgroundColor)
    }
}
