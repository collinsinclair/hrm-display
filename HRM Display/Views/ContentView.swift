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
    
    var connectButton: some View {
        Button(action: {
            viewModel.startScanning()
        }) {
            Text("Select Device")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
        }
    }
    
    var disconnectButton: some View {
        Button(action: {
            viewModel.disconnect()
        }) {
            Text("Disconnect")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.red)
                .cornerRadius(8)
        }
    }
    
    var deviceStatus: some View {
        HStack {
            Image(systemName: "beats.headphones")
                .foregroundColor(.secondary)
            Text(viewModel.deviceName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 6)
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    var portraitLayout: some View {
        ScrollView {
            VStack(spacing: 20) {
                deviceStatus
                
                VStack(spacing: 20) {
                    HeartRateDisplayView(
                        title: "Current BPM",
                        value: viewModel.currentHeartRate
                    )
                    
                    HeartRateDisplayView(
                        title: "60s Average",
                        value: viewModel.averageHeartRate
                    )
                    
                    if !viewModel.chartData.isEmpty {
                        HeartRateChartView(data: viewModel.chartData)
                            .frame(height: 200)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                    }
                }
                
                if viewModel.deviceName == "Not Connected" {
                    connectButton
                } else {
                    disconnectButton
                }
            }
            .padding()
        }
    }
    
    var landscapeLayout: some View {
        VStack(spacing: 16) {
            // Top controls
            HStack {
                deviceStatus
                Spacer()
                if viewModel.deviceName == "Not Connected" {
                    connectButton
                } else {
                    disconnectButton
                }
            }
            .padding(.horizontal)
            
            // BPM displays
            HStack {
                HeartRateDisplayView(
                    title: "Current BPM",
                    value: viewModel.currentHeartRate
                )
                
                HeartRateDisplayView(
                    title: "60s Average",
                    value: viewModel.averageHeartRate
                )
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Chart
            if !viewModel.chartData.isEmpty {
                HeartRateChartView(data: viewModel.chartData)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            
            Spacer()
        }
        .padding(.top)
    }
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                if geometry.size.width > geometry.size.height {
                    landscapeLayout
                } else {
                    portraitLayout
                }
            }
        }
        .sheet(isPresented: $viewModel.showDeviceSheet) {
            DeviceSelectionSheet(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
