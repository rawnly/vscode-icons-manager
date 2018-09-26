//
//  AppDelegate.swift
//  VSCode Icons Manager
//
//  Created by Federico Vitale on 26/09/2018.
//  Copyright © 2018 Federico Vitale. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    
    @IBAction func openIssues(_ sender: Any) {
        openURL(url: "https://github.com/rawnly/vscode-icon-manager/issues")
    }
    
    @IBAction func openIcons(_ sender: Any) {
        openURL(url: "https://github.com/dhanishgajjar/vscode-icons")
    }
    
    @IBAction func learnMore(_ sender: Any) {
        openURL(url: "https://github.com/rawnly/vscode-icon-manager")
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}


func openURL(url: String)
{
    guard let url = URL(string: url) else { return };
    NSWorkspace.shared.open(url);
}
