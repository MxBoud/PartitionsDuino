//
//  Cereal.swift
//  PartitionsDuino
//
//  Created by Maxime Boudreau2 on 18-01-23.
//  Copyright © 2018 MxBoud. All rights reserved.
//

import Foundation
import ORSSerial
import Cocoa


class Cereal:  NSViewController, ORSSerialPortDelegate, NSUserNotificationCenterDelegate {
  var viewController : ViewController?
  let serialPortManager = ORSSerialPortManager.shared()
  let availableBaudRates = [300, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 57600, 115200, 230400]
  var shouldAddLineEnding = false
  
  
  var serialPort: ORSSerialPort? {
    didSet {
      oldValue?.close()
      oldValue?.delegate = nil
      serialPort?.delegate = self
    }
  }
  
  func connectSerial(){
    
    serialPort = ORSSerialPort(path: "/dev/cu.wchusbserial1420")
    if (serialPort != nil) {
      serialPort!.baudRate = 9600
      
      //serialPort!.SetValue(path:"/dev/cu.wchusbserial1420" )
      //serialPort!.path =
      serialPort!.open()
      
      print(serialPort!.path)
    }
  }
  
  // MARK: - ORSSerialPortDelegate
  
  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    print("open")
    if (viewController != nil){
      viewController!.updateConnectButton(message:"Open")
    }
    //self.openCloseButton.title = "Close"
  }
  
  func serialPortWasClosed(_ serialPort: ORSSerialPort) {
   // self.openCloseButton.title = "Open"
    viewController!.updateConnectButton(message:"Close")
  }
  
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
      print(string)
      if (string == "NextPage") {
        print("passed")
        if(viewController != nil){
        viewController!.changePDFPage()
        }
        
      }
      
      //self.receivedDataTextView.textStorage?.mutableString.append(string as String)
      //self.receivedDataTextView.needsDisplay = true
    }
  }
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    self.serialPort = nil
    print("SerialPortRemoved")
   // self.openCloseButton.title = "Open"
  }
  
  
}
