//
//  AssignExerciseView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct ExerciseSelectionRow: View {
    let exercise: Exercise
    let isSelected: Bool
    let onToggle: () -> Void
    
    // Colors
    let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                // Selection circle
                Circle()
                    .fill(isSelected ? primaryColor : Color.white)
                    .frame(width: 22, height: 22)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? primaryColor : Color.gray.opacity(0.5), lineWidth: 1.5)
                    )
                
                Text(exercise.name)
                    .font(.body)
                    .foregroundColor(textColor)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
