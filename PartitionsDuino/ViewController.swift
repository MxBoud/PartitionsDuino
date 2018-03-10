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
  @IBOutlet weak var pdfViewer: PDFViewSC!
  @IBOutlet weak var userMessage: NSTextField!
  @IBOutlet weak var connectedDeviceLabel: NSTextField!
  @IBOutlet weak var dataInLabel: NSTextField!
  
  @objc dynamic let serialPortManager = ORSSerialPortManager.shared() //AvailablePorts referenced by NSPopUpButton "availablePorts".
  @objc dynamic var serialPort: ORSSerialPort? {//Assigned by the the value selected in "availablePorts".
    
    didSet {
      oldValue?.close()
      oldValue?.delegate = nil
      serialPort?.delegate = self
      serialPort?.baudRate = 9600
    }
  }
  
 
  public func PDFViewDidReceiveADocument() {
    
   //UserMessage.stringValue.removeAll()
    //let color = UserMessage.textColor
    
    NSAnimationContext.runAnimationGroup({ (context) -> Void in
      context.duration = 1//length of the animation time in seconds
     
      userMessage.animator().alphaValue = 0
        //NSColor.init(red: 1, green: 1, blue: 0, alpha : 1)
      //init(srgbRed: color?.redComponent,green: color?.greenComponent,blue: color?.blueComponent,0)//negative width of scroll view
     
    }, completionHandler: { () -> Void in
      //insert any completion code here
    })
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //availablePorts.removeItem(withTitle: "No Value") //Not sure this is a good idea (had some issues since if the default value is the serialport you want to connect to, it wont work unless you reselect it. 
    
    //Configuring Notification center
    let nc = NotificationCenter.default
    nc.addObserver(self, selector: #selector(serialPortsWereConnected(_:)), name: NSNotification.Name.ORSSerialPortsWereConnected, object: nil)
    nc.addObserver(self, selector: #selector(serialPortsWereDisconnected(_:)), name: NSNotification.Name.ORSSerialPortsWereDisconnected, object: nil)
    NSUserNotificationCenter.default.delegate = self
    //TO DO: Make sure previous stuff is cancelled at DEINIT
    
   pdfViewer.parent = self //To be able to receive message from the pdfViewer object
  }
  
  
  deinit{
    //TO DO : Deactivate listener to NSUserNotificationCenter.
  }
  
  
  func didReceiveSerialMessage(message : NSString){
    //print("Message")
    dataInLabel.stringValue = message as String
    
   //dataInLabel.alphaValue = 1
    NSAnimationContext.runAnimationGroup({ (context) -> Void in
      context.duration = 1//length of the animation time in seconds
      dataInLabel.animator().alphaValue = 0
     
    }, completionHandler: { () -> Void in
      //insert any completion code here
      print("AnimationDone")
      self.dataInLabel.stringValue = ""
      self.dataInLabel.alphaValue = 1
    })
    

    
    
  }
  // - MARK - Manage PDFView content
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
  
  // - MARK - (real part of view controller, other code should probably be in subclasses)
  @IBAction func connectDisconnect(_ sender: Any) {
      dataInLabel.alphaValue = 1
    if (serialPort != nil ){
      if (serialPort!.isOpen){
        serialPort!.close() // Close port if opened.
      }
        
      else {
            serialPort!.open()
            serialPort!.delegate = self
            
        //TO DO : FLUSH BUFFER (Maybe?)
      }
    }
  }
  
  // - MARK - (Incoming data controller ( from ORSSerialPort framework).
  func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data){
    
    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        {
          didReceiveSerialMessage(message:string)
          if (string ==  "NextPage")
            {
              changePDFPage()
            }
          if (string == "PreviousPage")
            {
              goToPreviousPage() // Not yet implemented in the arduino firmware.
            }
    
        }
    }
  
  // - MARK delegate functions from ORSSerialPort (Mostly copy pasted from ORSSerialPort demo)
  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    print("open")
    connectDisconnectButton.title = "Disconnect PartitionsDuino"
    connectedDeviceLabel.stringValue = "Connected to: " + serialPort.name
    //TO DO : Handshake
    }
  
  func serialPortWasClosed(_ serialPort: ORSSerialPort) {
    print("close")
    connectDisconnectButton.title = "Connect PartitionsDuino"
    connectedDeviceLabel.stringValue = "No device connected"
  }
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    print("warning, no more PartionduinoConnected")
  }
  
  // MARK: - Notifications  (Mostly copy pasted from ORSSerialPort demo)
  func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
    let popTime = DispatchTime.now() + Double(Int64(3.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: popTime) { () -> Void in
      center.removeDeliveredNotification(notification)
    }
  }
  
  func userNotificationCenter(_ center: NSUserNotificationCenter, shouldPresent notification: NSUserNotification) -> Bool {
    return true
    }
  
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




