//
//  SubscriptionPlanView.swift
//  AnkleHeal
//
//  Created by Udaibir Singh Bhathal on 10/03/25.
//

import SwiftUI

struct SubscriptionPlanView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Colors
    let backgroundColor = Color(red: 0.94, green: 0.94, blue: 0.94) // Light gray
    let textColor = Color(red: 0.2, green: 0.2, blue: 0.2) // Dark gray
    let secondaryTextColor = Color(red: 0.5, green: 0.5, blue: 0.5) // Medium gray
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Current Plan section
                    Text("Current Plan : Pro Plan")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    // Key Benefits section
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Key Benefits:")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        // Bullet points
                        BenefitRow(
                            title: "Unlimited Patients:",
                            description: "Manage an extensive list of patients without restrictions."
                        )
                        
                        BenefitRow(
                            title: "Priority Support:",
                            description: "Access to dedicated customer support for quick assistance."
                        )
                        
                        BenefitRow(
                            title: "Exercise Library Access:",
                            description: "Full access to the Exercise Library with customizable routines."
                        )
                        
                        BenefitRow(
                            title: "Advanced Posture Analysis:",
                            description: "Includes video analysis tools and detailed feedback options."
                        )
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .navigationBarTitle("Subscription Plan", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Profile")
                    }
                }
            )
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor)
            
            // Tab Bar
//            CustomTabBar(selectedTab: .home)
        }
    }
}

// Helper view for bullet points
struct BenefitRow: View {
    var title: String
    var description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(.headline)
                .padding(.top, 3)
            
            Text(title)
                .font(.headline) +
            Text(" \(description)")
                .font(.body)
        }
        .padding(.bottom, 15)
    }
}

struct SubscriptionPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubscriptionPlanView()
        }
    }
}
