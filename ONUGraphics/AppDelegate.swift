//
//  AppDelegate.swift
//  ONUGraphics
//
//  Created by Andrii Zinoviev on 21.03.2021.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private var window: NSWindow?
    
    private func createWindow(with viewController: XViewController) {
        let window = NSWindow(contentViewController: viewController)
        window.title = "ONUGraphics"
        window.makeKeyAndOrderFront(nil)
        self.window = window
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        guard let chosenImage = XUtils.chooseImage() else {
            return
        }
        
        let mainViewController = MainViewController()
        mainViewController.updateImage(chosenImage)
        self.createWindow(with: mainViewController)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        NSApplication.shared.terminate(self)
        return true
    }
}

