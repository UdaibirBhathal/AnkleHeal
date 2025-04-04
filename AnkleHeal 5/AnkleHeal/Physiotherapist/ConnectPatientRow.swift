//
//  ConnectPatientRow.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct ConnectPatientRow: View {
    var patient: Patient
    
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
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
            
            Image(systemName: "chevron.right")
                .foregroundColor(secondaryTextColor)
        }
        .padding(.horizontal)
        .background(Color.white)
        
        Divider()
            .padding(.leading)
    }
}
