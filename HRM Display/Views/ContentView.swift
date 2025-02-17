//
//  ContentView.swift
//  HRM Display
//
//  Created by Collin Sinclair on 2/17/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = HeartRateViewModel()
    
    var body: some View {
        VStack(spacing: 40) {
            Text("Heart Rate Monitor")
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Image(systemName: "beats.headphones")
                    .foregroundColor(.secondary)
                Text(viewModel.deviceName)
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            VStack(spacing: 20) {
                HeartRateDisplayView(
                    title: "Current BPM",
                    value: viewModel.currentHeartRate
                )
                
                HeartRateDisplayView(
                    title: "30s Average",
                    value: viewModel.averageHeartRate
                )
            }
            
            Button(action: {
                if viewModel.isScanning {
                    viewModel.stopScanning()
                } else {
                    viewModel.startScanning()
                }
            }) {
                Text(viewModel.isScanning ? "Stop Scanning" : "Start Scanning")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(viewModel.isScanning ? Color.red : Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
