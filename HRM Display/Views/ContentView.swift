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
                .frame(width: 200, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
        }
    }
    
    var disconnectButton: some View {
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
    
    var deviceStatus: some View {
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
    }
    
    var portraitLayout: some View {
        VStack(spacing: 40) {
            Text("Heart Rate Monitor")
                .font(.title)
                .fontWeight(.bold)
            
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
            }
            
            if viewModel.deviceName == "Not Connected" {
                connectButton
            } else {
                disconnectButton
            }
        }
    }
    
    var landscapeLayout: some View {
        VStack(spacing: 0) {
            // Top row - fixed height, anchored to top
            HStack {
                Text("Heart Rate Monitor")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                if viewModel.deviceName == "Not Connected" {
                    connectButton
                } else {
                    disconnectButton
                }
                
                Spacer()
                
                deviceStatus
            }
            .padding(.bottom, 20)
            
            // Bottom row with heart rate displays - expands to fill remaining space
            HStack(spacing: 20) {
                HeartRateDisplayView(
                    title: "Current BPM",
                    value: viewModel.currentHeartRate,
                    expandContent: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                HeartRateDisplayView(
                    title: "60s Average",
                    value: viewModel.averageHeartRate,
                    expandContent: true
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
        }
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
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .sheet(isPresented: $viewModel.showDeviceSheet) {
            DeviceSelectionSheet(viewModel: viewModel)
        }
    }
}

#Preview {
    ContentView()
}
