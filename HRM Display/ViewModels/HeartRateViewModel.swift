import Foundation
import Combine

class HeartRateViewModel: ObservableObject {
    private let bluetoothService: BluetoothService
    private var cancellables = Set<AnyCancellable>()
    
    // Keep track of session start time
    private var sessionStartTime: Date?
    
    // Store timestamps with heart rate values
    private struct HeartRateMeasurement {
        let timestamp: Date
        let value: Int
    }
    private var heartRateHistory: [HeartRateMeasurement] = []
    
    @Published var currentHeartRate: Int = 0
    @Published var averageHeartRate: Int = 0
    @Published var isScanning: Bool = false
    @Published var deviceName: String = "Not Connected"
    @Published var discoveredDevices: [DiscoveredDevice] = []
    @Published var showDeviceSheet = false
    @Published private(set) var chartData: [HeartRateDataPoint] = []
    
    // Configuration
    private let averageWindowSeconds: TimeInterval = 60
    
    init(bluetoothService: BluetoothService = BluetoothService()) {
        self.bluetoothService = bluetoothService
        
        // Subscribe to heart rate updates
        bluetoothService.$heartRate
            .sink { [weak self] heartRate in
                if let heartRate = heartRate {
                    self?.updateHeartRate(heartRate)
                }
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
        // Clear history when disconnecting
        heartRateHistory.removeAll()
        chartData.removeAll()
        currentHeartRate = 0
        averageHeartRate = 0
        sessionStartTime = nil
    }
    
    private func updateHeartRate(_ heartRate: Int) {
        currentHeartRate = heartRate
        
        // Add new measurement with timestamp
        let measurement = HeartRateMeasurement(timestamp: Date(), value: heartRate)
        heartRateHistory.append(measurement)
        
        // Sort measurements by timestamp (should already be sorted, but being defensive)
        let sortedMeasurements = heartRateHistory.sorted { $0.timestamp < $1.timestamp }
        
        // Calculate time span of our data
        guard let firstMeasurement = sortedMeasurements.first else {
            averageHeartRate = currentHeartRate
            addDataPoint(instantaneous: heartRate, average: heartRate)
            return
        }
        
        let timeSpan = Date().timeIntervalSince(firstMeasurement.timestamp)
        
        if timeSpan < averageWindowSeconds {
            // Less than 60 seconds of data - use simple arithmetic mean
            let sum = sortedMeasurements.reduce(0) { $0 + $1.value }
            averageHeartRate = Int(Double(sum) / Double(sortedMeasurements.count))
        } else {
            // We have at least 60 seconds of data - use rolling time-weighted average
            let cutoffTime = Date().addingTimeInterval(-averageWindowSeconds)
            
            // Remove measurements older than the window
            heartRateHistory.removeAll { $0.timestamp < cutoffTime }
            
            // Recalculate sorted measurements after removal
            let windowedMeasurements = heartRateHistory.sorted { $0.timestamp < $1.timestamp }
            
            var weightedSum = 0.0
            var totalTime = 0.0
            
            // Calculate time-weighted average
            for i in 1..<windowedMeasurements.count {
                let previousMeasurement = windowedMeasurements[i-1]
                let currentMeasurement = windowedMeasurements[i]
                
                let timeInterval = currentMeasurement.timestamp.timeIntervalSince(previousMeasurement.timestamp)
                weightedSum += Double(previousMeasurement.value) * timeInterval
                totalTime += timeInterval
            }
            
            // Add the most recent measurement's contribution
            if let lastMeasurement = windowedMeasurements.last {
                let timeInterval = Date().timeIntervalSince(lastMeasurement.timestamp)
                weightedSum += Double(lastMeasurement.value) * timeInterval
                totalTime += timeInterval
            }
            
            averageHeartRate = totalTime > 0 ? Int(weightedSum / totalTime) : currentHeartRate
        }
        
        addDataPoint(instantaneous: heartRate, average: averageHeartRate)
    }
    
    private func addDataPoint(instantaneous: Int, average: Int) {
        // Only add valid heart rate measurements
        guard instantaneous > 0 && average > 0 else { return }
        
        let now = Date()
        // Set session start time if this is the first data point
        if sessionStartTime == nil {
            sessionStartTime = now
        }
        
        let point = HeartRateDataPoint(
            timestamp: now,
            instantaneous: instantaneous,
            average: average
        )
        chartData.append(point)
    }
}
