//
//  HeartRateDisplayView.swift
//  HRM Display
//
//  Created by Collin Sinclair on 2/17/25.
//

import SwiftUI

struct HeartRateDisplayView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("\(value)")
                .font(.system(size: 64, weight: .bold))
                .monospacedDigit()
        }
        .frame(width: 250, height: 120)
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

#Preview {
    HeartRateDisplayView(title: "Current BPM", value: 142)
}
