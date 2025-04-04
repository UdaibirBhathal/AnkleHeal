//
//  SectionHeader.swift
//  Patient_Side
//
//  Created by Brahmjot Singh Tatla on 13/03/25.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            Spacer()
            Button(action: {}) {
                Text(">")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        .padding(.top, 10)
    }
}

//#Preview {
//    SectionHeader()
//}
