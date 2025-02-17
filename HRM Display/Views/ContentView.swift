//
//  ContentView.swift
//  HRM Display
//

import SwiftUI

struct DeviceSelectionSheet: View {
    @ObservedObject var viewModel: HeartRateViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List(viewModel.discoveredDevices) { device in
                Button(action: {
                    viewModel.connectTo(device)
                    dismiss()
                }) {
                    HStack {
                        Text(device.name)
                        Spacer()
                        Image(systemName: "beats.headphones")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Available Devices")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        viewModel.stopScanning()
                        dismiss()
                    }
                }
            }
        }
    }
}

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
            
            if viewModel.deviceName == "Not Connected" {
                Button(action: {
                    viewModel.startScanning()
                }) {
                    Text("Select Device")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            } else {
                Button(action: {
                    viewModel.disconnect()
                }) {
                    Text("Disconnect")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .sheet(isPresented: $viewModel.showDeviceSheet) {
            DeviceSelectionSheet(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
