//
//  BluetoothService.swift
//  HRM Display
//
//  Created by Collin Sinclair on 2/17/25.
//

import CoreBluetooth
import Combine

class BluetoothService: NSObject, ObservableObject {
    private var centralManager: CBCentralManager?
    private var heartRatePeripheral: CBPeripheral?
    private let heartRateServiceCBUUID = CBUUID(string: "0x180D")
    private let heartRateMeasurementCharacteristicCBUUID = CBUUID(string: "0x2A37")
    
    @Published var isScanning = false
    @Published var heartRate: Int = 0
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        guard let centralManager = centralManager,
              centralManager.state == .poweredOn else { return }
        
        isScanning = true
        centralManager.scanForPeripherals(withServices: [heartRateServiceCBUUID])
    }
    
    func stopScanning() {
        guard let centralManager = centralManager else { return }
        isScanning = false
        centralManager.stopScan()
    }
}

extension BluetoothService: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            print("Bluetooth is powered on")
        } else {
            print("Bluetooth is not available: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                       advertisementData: [String: Any], rssi RSSI: NSNumber) {
        heartRatePeripheral = peripheral
        heartRatePeripheral?.delegate = self
        central.connect(peripheral, options: nil)
        central.stopScan()
        isScanning = false
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices([heartRateServiceCBUUID])
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
        
        self.heartRate = Int(heartRate)
    }
}
