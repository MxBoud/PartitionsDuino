//
//  PDFViewSC.swift
//  PartitionsDuino
//
//  Created by Maxime Boudreau2 on 18-03-06.
//  Copyright © 2018 MxBoud. All rights reserved.
//

import Foundation
import Cocoa
import Quartz.PDFKit

class PDFViewSC : PDFView {//Subclass for adding a listener to the document variable so that the app knows when the document is changed.
  
  override var document: PDFDocument? {
    didSet{//Add an observer so that when a document is added, a message is sent to the ViewController 
      if (parent != nil){
        parent!.PDFViewDidReceiveADocument()
      }
    }
  }
  
  var parent : ViewController? //Reference to the view controller, so that the message "PDFViewDidReceiveADocument()" can be sent.
}
