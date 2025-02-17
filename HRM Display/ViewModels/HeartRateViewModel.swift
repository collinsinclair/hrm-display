//
//  HeartRateViewModel.swift
//  HRM Display
//
//  Created by Collin Sinclair on 2/17/25.
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
    }
    
    func startScanning() {
        bluetoothService.startScanning()
    }
    
    func stopScanning() {
        bluetoothService.stopScanning()
    }
    
    private func updateHeartRate(_ heartRate: Int) {
        currentHeartRate = heartRate
        heartRateHistory.append(heartRate)
        
        // Keep only last 30 seconds of data (assuming 1 reading per second)
        if heartRateHistory.count > 30 {
            heartRateHistory.removeFirst()
        }
        
        // Calculate rolling average
        averageHeartRate = Int(Double(heartRateHistory.reduce(0, +)) / Double(heartRateHistory.count))
    }
}
