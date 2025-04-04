//
//  AppColours.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 29/03/25.
//

import SwiftUI

struct AppColors {
    // Primary colors
    static let primaryColor = Color(red: 0.35, green: 0.64, blue: 0.90) // Light blue
    static let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    static let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    static let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    // Action colors
    static let rescheduleColor = Color.red
    static let successColor = Color.green
    static let warningColor = Color.orange
    
    // Background variants
    static let cardBackgroundColor = Color.white
    static let tagBackgroundColor = Color(red: 0.9, green: 0.95, blue: 1.0) // Very light blue for tags
    
    // Button colors
    static let buttonColor = Color(red: 0.25, green: 0.55, blue: 0.83) // Darker blue for buttons
}

// Extension for convenient Color usage
extension Color {
    static let appPrimary = AppColors.primaryColor
    static let appBackground = AppColors.backgroundColor
    static let appText = AppColors.textColor
    static let appSecondaryText = AppColors.secondaryTextColor
    static let appCard = AppColors.cardBackgroundColor
    static let appButton = AppColors.buttonColor
}
