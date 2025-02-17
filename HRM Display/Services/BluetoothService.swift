import CoreBluetooth
import Combine

struct DiscoveredDevice: Identifiable {
    let id: UUID
    let peripheral: CBPeripheral
    let name: String
}

class BluetoothService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var heartRatePeripheral: CBPeripheral?
    private let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    private let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "0x2A37")
    
    @Published var isScanning = false
    @Published var heartRate: Int? = nil
    @Published var connectedDeviceName: String = "Not Connected"
    @Published var discoveredDevices: [DiscoveredDevice] = []
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard let centralManager = centralManager,
              centralManager.state == .poweredOn else { return }
        
        discoveredDevices.removeAll()
        isScanning = true
        centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
    }
    
    func stopScanning() {
        guard let centralManager = centralManager else { return }
        isScanning = false
        centralManager.stopScan()
    }
    
    func connectTo(_ device: DiscoveredDevice) {
        guard let centralManager = centralManager else { return }
        heartRatePeripheral = device.peripheral
        heartRatePeripheral?.delegate = self
        centralManager.connect(device.peripheral, options: nil)
        connectedDeviceName = device.name
        stopScanning()
    }
    
    func disconnect() {
        guard let centralManager = centralManager,
              let peripheral = heartRatePeripheral else { return }
        centralManager.cancelPeripheralConnection(peripheral)
        heartRatePeripheral = nil
        connectedDeviceName = "Not Connected"
        heartRate = nil
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available: \(central.state.rawValue)")
            connectedDeviceName = "Bluetooth Not Available"
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
        let name = peripheral.name ?? "Unknown Device"
        let device = DiscoveredDevice(id: peripheral.identifier, peripheral: peripheral, name: name)
        
        // Only add if not already in the list
        if !discoveredDevices.contains(where: { $0.id == device.id }) {
            discoveredDevices.append(device)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([heartRateServiceCBUUID])
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedDeviceName = "Not Connected"
        heartRatePeripheral = nil
        heartRate = nil
    }
}

extension BluetoothService: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics([heartRateMeasurementCharacteristicCBUUID], for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            if characteristic.uuid == heartRateMeasurementCharacteristicCBUUID {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                   error: Error?) {
        guard let data = characteristic.value else { return }
        
        // Heart Rate data format parsing according to Bluetooth specification
        let firstByte = data[0]
        let isFormat16Bit = ((firstByte & 0x01) == 0x01)
        let heartRate = isFormat16Bit ?
            UInt16(data[1]) + (UInt16(data[2]) << 8) :
            UInt16(data[1])
        
        // Only publish valid heart rates (typically between 30 and 220 bpm)
        if heartRate >= 30 && heartRate <= 220 {
            self.heartRate = Int(heartRate)
        }
    }
}
