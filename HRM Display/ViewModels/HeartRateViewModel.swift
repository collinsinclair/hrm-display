//
//  HeartRateViewModel.swift
//  HRM Display
//

import Foundation
import Combine

class HeartRateViewModel: ObservableObject {
    private let bluetoothService: BluetoothService
    private var cancellables = Set<AnyCancellable>()
    private var heartRateHistory: [Int] = []
    
    @Published var currentHeartRate: Int = 0
    @Published var averageHeartRate: Int = 0
    @Published var isScanning: Bool = false
    @Published var deviceName: String = "Not Connected"
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var showDeviceSheet = false
    
    init(bluetoothService: BluetoothService = BluetoothService()) {
        self.bluetoothService = bluetoothService
        
        // Subscribe to heart rate updates
        bluetoothService.$heartRate
            .sink { [weak self] heartRate in
                self?.updateHeartRate(heartRate)
            }
            .store(in: &cancellables)
        
        // Subscribe to scanning status
        bluetoothService.$isScanning
            .assign(to: &$isScanning)
            
        // Subscribe to device name updates
        bluetoothService.$connectedDeviceName
            .assign(to: &$deviceName)
            
        // Subscribe to discovered devices
        bluetoothService.$discoveredDevices
            .assign(to: &$discoveredDevices)
    }
    
    func startScanning() {
        bluetoothService.startScanning()
        showDeviceSheet = true
    }
    
    func stopScanning() {
        bluetoothService.stopScanning()
        showDeviceSheet = false
    }
    
    func connectTo(_ device: DiscoveredDevice) {
        bluetoothService.connectTo(device)
        showDeviceSheet = false
    }
    
    func disconnect() {
        bluetoothService.disconnect()
    }
    
    private func updateHeartRate(_ heartRate: Int) {
        currentHeartRate = heartRate
        heartRateHistory.append(heartRate)
        
        // Keep only last 30 seconds of data
        if heartRateHistory.count > 30 {
            heartRateHistory.removeFirst()
        }
        
        // Calculate rolling average
        averageHeartRate = Int(Double(heartRateHistory.reduce(0, +)) / Double(heartRateHistory.count))
    }
}
