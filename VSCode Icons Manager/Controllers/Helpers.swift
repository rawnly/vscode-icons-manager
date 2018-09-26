//
//  Helpers.swift
//  VSCode Icons Manager
//
//  Created by Federico Vitale on 27/09/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Foundation
import Cocoa

func dialogOKCancel(question: String, text: String, style: NSAlert.Style = .warning) -> Bool {
    let alert = NSAlert()
    
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .critical
    
    
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    
    return alert.runModal() == .alertFirstButtonReturn
}


