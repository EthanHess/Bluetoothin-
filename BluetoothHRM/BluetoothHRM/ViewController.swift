//
//  ViewController.swift
//  BluetoothHRM
//
//  Created by Ethan Hess on 5/12/16.
//  Copyright © 2016 Ethan Hess. All rights reserved.
//

import UIKit
import QuartzCore
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    //IB Properties
    
    @IBOutlet var deviceInfo : UITextView!
    @IBOutlet var heartImage : UIImageView!
    
    //properties
    
    var centralManager : CBCentralManager!
    var polarH7HRMPeripheral : CBPeripheral! //example peripheral monitoring heart rate
    
    //other properties
    
    var connected = NSString()
    var bodyData = NSString()
    var manufacturer = NSString()
    var polarH7DeviceData = NSString()
    var heartRate = Int()
    
    var heartRateBPM : UILabel!
    var pulseTimer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        polarH7DeviceData = ""
        view.backgroundColor = UIColor.groupTableViewBackgroundColor()
        
        heartImage.image = UIImage(named: "")
        
        deviceInfo.text = ""
        deviceInfo.textColor = UIColor.blueColor()
        deviceInfo.backgroundColor = UIColor.lightGrayColor()
        deviceInfo.userInteractionEnabled = false
        
        heartRateBPM = UILabel(frame: CGRectMake(55, 30, 75, 50))
        heartRateBPM.textColor = UIColor.whiteColor()
        heartRateBPM.text = NSString(format: "%i", 0) as String
        heartImage.addSubview(heartRateBPM)
        
        let serviceOne = CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID)
        let serviceTwo = CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID)
        
        let services = [serviceOne, serviceTwo]
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.scanForPeripheralsWithServices(services, options: nil)
        
    }
    
    //Eventually move to extension out of main VC, just an example
    
    //CENTRAL MANAGER DEL.
    
    //called when connected succesfully
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        
        connected = NSString(format: "Connected: %@", peripheral.state == CBPeripheralState.Connected ? "YES" : "NO")
        
        print(self.connected)
    }
    
    //contains info (called advertisement data) about peripheral
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        let localName = advertisementData[CBAdvertisementDataLocalNameKey]
        
        if localName?.length > 0 {
            
            print(localName)
            
            centralManager.stopScan()
            polarH7HRMPeripheral = peripheral
            peripheral.delegate = self
            centralManager.connectPeripheral(peripheral, options: nil)
            
        }
    }
    
    //called when device state changed 
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        if central.state == CBCentralManagerState.PoweredOff {
            print("Powered off")
        }
        else if central.state == CBCentralManagerState.PoweredOn {
            print("Ready!")
        }
        else if central.state == CBCentralManagerState.Unauthorized {
            print("Unauthorized")
        }
        else if central.state == CBCentralManagerState.Unknown {
            print("Unknown")
        }
        else if central.state == CBCentralManagerState.Unsupported {
            print("Unsupported on this platform")
        }
    }
    
    //PERIPHERAL DEL.
    
    //what central manager is interacting with
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        for service in peripheral.services! {
            
            print(service.UUID)
            peripheral.discoverCharacteristics(nil, forService: service)
        }
    }
    
    //invoked when said service's characteristics are discovered
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if service.UUID == CBUUID(string: POLARH7_HRM_HEART_RATE_SERVICE_UUID) {
            
            for charactersitic in service.characteristics! {
                
                if charactersitic.UUID == CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID) {
                    
                    //heart rate found
                    self.polarH7HRMPeripheral.setNotifyValue(true, forCharacteristic: charactersitic)
                }
                
                else if charactersitic.UUID == CBUUID(string: POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID) {
                    
                    //body sensor location found
                    self.polarH7HRMPeripheral.readValueForCharacteristic(charactersitic)
                }
                
            }
        }
        
        //get info about manufacturer
        
        if service.UUID == CBUUID(string: POLARH7_HRM_DEVICE_INFO_SERVICE_UUID) {
            
            for charactersitic in service.characteristics! {
                
                if charactersitic.UUID == CBUUID(string: POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID) {
                    
                    self.polarH7HRMPeripheral.readValueForCharacteristic(charactersitic)
                }
            }
        }
        
    }
    
    //when characteristic's value changes
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        //update heart rate
        
        if characteristic.UUID == CBUUID(string: POLARH7_HRM_MEASUREMENT_CHARACTERISTIC_UUID) {
            
            self.getHeartBPMData(characteristic, error: error)
        }
        
        //update manf. name
        
        if characteristic.UUID == CBUUID(string: POLARH7_HRM_MANUFACTURER_NAME_CHARACTERISTIC_UUID) {
            
            self.getManufactererName(characteristic)
        }
        
        //body location
            
        else if characteristic.UUID == CBUUID(string: POLARH7_HRM_BODY_LOCATION_CHARACTERISTIC_UUID) {
            
            self.getBodyLocation(characteristic)
        }
        
        //update info text view
        
        deviceInfo.text = NSString(format: "%@\n%@\n%@\n", connected, bodyData, manufacturer) as String
        
    }
    
    //helper methods for heart rate etc. 
    
    func getHeartBPMData(characteristic: CBCharacteristic, error: NSError?) {
        
        //TODO: Finish helper methods
        
        
    }
    
    func getManufactererName(characteristic: CBCharacteristic) {
        
        
    }
    
    func getBodyLocation(characteristic: CBCharacteristic) {
        
        
    }
    
    func heartBeat() {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

