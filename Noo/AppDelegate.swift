//
//  AppDelegate.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 4/26/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    
    static let CONFIG = Config()
    static let controller: SettingsViewController = SettingsViewController()
    
    var statusItem: NSStatusItem?;
    let window: NSWindow;
    
    override init() {
        NSLog("Init Noo.app")
        
        self.window = NSWindow.init(
            contentRect: NSRect.init(x: 0, y: 0, width: 10, height: 10),
            styleMask: NSWindow.StyleMask.init(arrayLiteral: NSWindow.StyleMask.closable, NSWindow.StyleMask.resizable, NSWindow.StyleMask.miniaturizable, NSWindow.StyleMask.titled),
            backing: NSWindow.BackingStoreType.buffered,
            defer: false)
        window.isReleasedWhenClosed = false;
        window.setIsVisible(false)
        
        super.init()
        
        
        window.contentViewController = AppDelegate.controller
        window.title = "Noo"
        window.delegate = AppDelegate.controller
    }
    
    @objc func showSettings() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(self)
        window.setIsVisible(true)
    }

    
    @objc func terminate() {
        NSApp.terminate(nil)
    }
    
    @objc func hide() {
        statusItem!.isVisible = false;
    }
    
    func setupEventLoop() {
        let accessibilityEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: true] as NSDictionary);
        NSLog("Noo can access Accessibility: %@", accessibilityEnabled ? "true" : "false");
        
        eventTap = CGEvent.tapCreate(
            tap: CGEventTapLocation.cghidEventTap,
            place: CGEventTapPlacement.headInsertEventTap,
            options: CGEventTapOptions.defaultTap,
            eventsOfInterest: NSEvent.EventTypeMask.init(
                arrayLiteral:
                NSEvent.EventTypeMask.otherMouseUp,
                NSEvent.EventTypeMask.otherMouseDown,
                NSEvent.EventTypeMask.otherMouseDragged,
                NSEvent.EventTypeMask.rightMouseUp,
                NSEvent.EventTypeMask.rightMouseDown,
                NSEvent.EventTypeMask.rightMouseDragged,
                NSEvent.EventTypeMask.gesture
            ).rawValue,
            callback: eventCallback,
            userInfo: nil)
        
        if eventTap == nil {
            NSLog("Unable to invoke CGEvent.tapCreate. Please enable Accessibility for Noo.app");
            let alert = NSAlert()
            alert.messageText = "Accessibility is off"
            alert.informativeText = "Please grant Accessibility and start Noo again."
            alert.alertStyle = .warning
            alert.addButton(withTitle: "Open the Accessibility setting and quit Noo")
            alert.runModal()
            
            let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
            NSWorkspace.shared.open(url)
            
            NSApp.terminate(nil)
            return
        }
        
        eventLoop = CFMachPortCreateRunLoopSource(nil, eventTap!, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), eventLoop!, CFRunLoopMode.commonModes)
        
        CGEvent.tapEnable(tap: eventTap!, enable: true);
    }
    
    func setupStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: 25)
        item.isVisible = true
        
        item.button!.cell!.font = NSFont.init(name: "Font Awesome 5 Free", size: 14)
        
        item.button!.title = "\u{f8cc}"
        item.button!.isEnabled = true
        
        item.menu = NSMenu.init(title: "Noo")
        item.menu!.addItem(withTitle: "Settings", action: #selector(showSettings), keyEquivalent: "")
        item.menu!.addItem(withTitle: "Hide this menu", action: #selector(hide), keyEquivalent: "")
        item.menu!.addItem(NSMenuItem.separator())
        item.menu!.addItem(withTitle: "Quit", action: #selector(terminate), keyEquivalent: "")
        statusItem = item
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // App is activated by user double-clicking on the binary.
        statusItem!.isVisible = true;
        showSettings()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupEventLoop()
        
        let event = NSAppleEventManager.shared().currentAppleEvent
        let launchedAsLogInItem =
            event?.eventID == kAEOpenApplication &&
            event?.paramDescriptor(forKeyword: keyAEPropData)?.enumCodeValue == keyAELaunchedAsLogInItem
        
        if (!launchedAsLogInItem) {
            showSettings()
        }
    }
}
