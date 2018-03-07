//
//  ViewController.swift
//  PartitionsDuino
//
//  Created by Maxime Boudreau2 on 18-01-16.
//  Copyright © 2018 MxBoud. All rights reserved.
//

import Cocoa
import Quartz.PDFKit
import ORSSerial








class ViewController: NSViewController,ORSSerialPortDelegate, NSUserNotificationCenterDelegate{
  
 
 
  
  @IBOutlet weak var connectDisconnectButton: NSButton!
  @IBOutlet weak var availablePorts: NSPopUpButton!
  @objc dynamic let serialPortManager = ORSSerialPortManager.shared()
  let availableBaudRates = [300, 1200, 2400, 4800, 9600, 14400, 19200, 28800, 38400, 57600, 115200, 230400]
  var shouldAddLineEnding = false
  
  @IBOutlet weak var connectedDeviceLabel: NSTextField!
  
  
  @objc dynamic var serialPort: ORSSerialPort? {
    //serialPortManager.av
    didSet {
      oldValue?.close()
      oldValue?.delegate = nil
      serialPort?.delegate = self
      serialPort?.baudRate = 9600
      if(serialPort != nil ){
      
      }
      
  
      
    }
  }
  
  @IBOutlet weak var pdfViewer: PDFViewSC!
  @IBOutlet weak var UserMessage: NSTextField!
  //var cerealObject = Cereal()
  
 
  public func PDFViewDidReceiveADocument() {
   UserMessage.stringValue.removeAll()
    
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    availablePorts.removeItem(withTitle: "No Value")
    let nc = NotificationCenter.default
    
    pdfViewer.parent = self
    
    
    
    
    nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
    nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    
    NSUserNotificationCenter.default.delegate = self
    
    //TO DO: Make sure previous stuff is cancelled at DEINIT
   
    
   
  }
  deinit{
    //TO DO : Deactivate listener to NSUserNotificationCenter.
  }
  
  
                      
  override var representedObject: Any? {
    didSet {
    // Update the view, if already loaded.
    }
  }
  func changePDFPage() {
    print("ItWorks")
    if (pdfViewer != nil) {
       pdfViewer!.goToNextPage(self)
    }
   
  }
  func goToPreviousPage() {
    if (pdfViewer != nil) {
      pdfViewer!.goToPreviousPage(self)
    }
  }
  
  func updateConnectButton(message: String?) {
    if(message != nil){
    print(message!)
    }
  }
  /*
  @IBAction func refreshPortList(_ sender: NSButton) {
    print("RefreshPortListPressed")
    let ports = serialPortManager.availablePorts
    availablePorts.removeAllItems()
    if (ports.count == 0){
      availablePorts.addItems(withTitles: ["No port available"])
    }
    else {
      for port  in ports{
          //print(port.name)
          availablePorts.addItems(withTitles: [port.name])
      }
    }
    */
    
    
    
    //if (cerealObject.serialPort != nil ){
    //  if (cerealObject.serialPort!.isOpen){
       // cerealObject.connectSerial()
     // }
      
  //}
  @IBAction func connectDisconnect(_ sender: Any) {
    print("pressed")
    if (serialPort != nil ){
      if (serialPort!.isOpen){
        serialPort!.close()
      }
      else {
            serialPort!.open()
            serialPort!.delegate = self
        //TO DO : FLUSH BUFFER
      }
      
    
    }
    else {
      //print("SerialPort have been deleted. Not good.")
      
      print(serialPortManager.availablePorts[0].name)
   let portIndex = availablePorts.indexOfSelectedItem
      
      
      
      serialPort = serialPortManager.availablePorts[portIndex]
      serialPort!.baudRate = 9600
      serialPort!.open()
     print("portSupposedToOpen")
      serialPort!.delegate = self
      
      }
    
      
      
      //ManageButtons
      if (serialPort!.isOpen){
       
      }
      else {
        
      }
      
  
    
  
  }
  
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
    print("receivedData")
    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
      print(string)
      if (string ==  "NextPage"){
        
        changePDFPage()
      }
      if (string == "PreviousPage"){
        goToPreviousPage()
      }
    
  }
  }
  
  
  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    print("open")
     connectDisconnectButton.title = "Disconnect PartitionsDuino"
    connectedDeviceLabel.stringValue = "Connected to: " + serialPort.name
    //Handshake
    
    
    
        //if (viewController != nil){
      //viewController!.updateConnectButton(message:"Open")
    }
  func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    print("close")
    connectDisconnectButton.title = "Connect PartitionsDuino"
    connectedDeviceLabel.stringValue = "No device connected"
    //if (viewController != nil){
    //viewController!.updateConnectButton(message:"Open")
  }
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    print("warning, no more PartionduinoConnected")
  }
  
  func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
    let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
      center.removeDeliveredNotification(notification)
    }
  }
  
  func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
    return true
  }
  
  // MARK: - Notifications
  
  @objc func serialPortsWereConnected(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let connectedPorts = userInfo[ORSConnectedSerialPortsKey] as! [ORSSerialPort]
      print("Ports were connected: \(connectedPorts)")
      self.postUserNotificationForConnectedPorts(connectedPorts)
    }
  }
  @objc func serialPortsWereDisconnected(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      let disconnectedPorts: [ORSSerialPort] = userInfo[ORSDisconnectedSerialPortsKey] as! [ORSSerialPort]
      print("Ports were disconnected: \(disconnectedPorts)")
      self.postUserNotificationForDisconnectedPorts(disconnectedPorts)
    }
  }
  @objc func postUserNotificationForConnectedPorts(_ connectedPorts: [ORSSerialPort]) {
    let unc = NSUserNotificationCenter.default
    for port in connectedPorts {
      let userNote = NSUserNotification()
      userNote.title = NSLocalizedString("Serial Port Connected", comment: "Serial Port Connected")
      userNote.informativeText = "Serial Port \(port.name) was connected to your Mac."
      userNote.soundName = nil;
      unc.deliver(userNote)
    }
  }
  @objc func postUserNotificationForDisconnectedPorts(_ disconnectedPorts: [ORSSerialPort]) {
    let unc = NSUserNotificationCenter.default
    for port in disconnectedPorts {
      let userNote = NSUserNotification()
      userNote.title = NSLocalizedString("Serial Port Disconnected", comment: "Serial Port Disconnected")
      userNote.informativeText = "Serial Port \(port.name) was disconnected from your Mac."
      userNote.soundName = nil;
      unc.deliver(userNote)
    }
  }
  
  }




