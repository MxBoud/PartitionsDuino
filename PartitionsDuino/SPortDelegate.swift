//
//  sPortDelegate.swift
//  PartitionsDuino
//
//  Created by Maxime Boudreau2 on 18-01-28.
//  Copyright © 2018 MxBoud. All rights reserved.
//

import Foundation
import ORSSerial
import Cocoa


class SPortDelegate : NSViewController,NSUserNotificationCenterDelegate {
  
  func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
    print("test")
  }
  
  
  func serialPortWasOpened(_ serialPort: ORSSerialPort) {
    print("open")
    //if (viewController != nil){
    //viewController!.updateConnectButton(message:"Open")
  }
}
