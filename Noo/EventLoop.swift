//
//  EventLoop.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 4/26/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

var eventLoop: CFRunLoopSource? = nil
public var eventTap: CFMachPort? = nil
var timer: Timer? = nil
var currentFingerCount: Int = 0
var latestTimerId: Int = 0

public var CGEventClass: NooCGEventBase.Type = NooCGEvent.self
public var NSWorkspaceClass: NSWorkspace.Type = NSWorkspace.self
public var NSEventClass: NooNSEventBase.Type = NooNSEvent.self

func eventCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    let accessibilityEnabled = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeRetainedValue() as NSString: false] as NSDictionary);
    
    if (!accessibilityEnabled) {
        CGEventClass.tapEnable(tap: eventTap!, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), eventLoop!, CFRunLoopMode.commonModes)
        
        let alert = NSAlert()
        alert.messageText = "Accessibility has been turned off"
        alert.informativeText = "Noo will quit. Please grant Accessibility and start Noo again."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit Noo")
        alert.runModal()
        NSApp.terminate(nil)
        
        return Unmanaged.passUnretained(event)
    }
    
    if (type == CGEventType.tapDisabledByTimeout) {
        CGEventClass.tapEnable(tap: eventTap!, enable: true)
        return Unmanaged.passUnretained(event)
    }
    
    let nsEvent = NSEventClass.init(cgEvent: event)
    
    if (nsEvent.type == NSEvent.EventType.gesture) {
        let latestTouchCount = nsEvent.touches(matching: NSTouch.Phase.stationary, in: nil).count
        
        if (currentFingerCount < latestTouchCount && latestTouchCount >= 3) {
            currentFingerCount = latestTouchCount;

            let id = "finger-\(latestTouchCount)"
            
            if (
                respondTo(id) ||
                NSApplication.shared.keyWindow?.contentViewController == AppDelegate.controller // the window is in focused
            ) {
                if let _ = timer?.isValid {
                    timer?.invalidate()
                }
                
                latestTimerId += 1
                let timerId = latestTimerId;
                timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { (_: Timer) in
                    if (timerId != latestTimerId) { return; }
                    
                    if (currentFingerCount == latestTouchCount) {
                        AppDelegate.controller.gestured(id)
                        
                        if (respondTo(id)) {
                            trigger("finger-\(currentFingerCount)")
                        }
                    }
                    
                    currentFingerCount = 0;
                })
                return nil
            }

            currentFingerCount = 0;
        }
        return Unmanaged.passUnretained(event);
    }
    
    // This method responds to mouse down, up, and dragged.
    // However, we needed to swallow mouse down and dragged.
    // Otherwise, IntelliJ would not accept any mouse event when it sees a mouse down but never sees a subsequent mouse up.

    if (nsEvent.type == NSEvent.EventType.rightMouseUp || nsEvent.type == NSEvent.EventType.rightMouseDown) {
        let id = "mouse-button-right"
        
        if (nsEvent.type == NSEvent.EventType.rightMouseDown) {
            AppDelegate.controller.gestured(id)
        }
        
        if respondTo(id) {
            if (nsEvent.type == NSEvent.EventType.rightMouseUp) {
                trigger(id)
            }
            return nil;
        }
    }

    if (nsEvent.type == NSEvent.EventType.otherMouseUp || nsEvent.type == NSEvent.EventType.otherMouseDown) {
        let id = "mouse-button-\(nsEvent.buttonNumber)"
        
        if (nsEvent.type == NSEvent.EventType.otherMouseDown) {
            AppDelegate.controller.gestured(id)
        }
        
        if respondTo(id) {
            if (nsEvent.type == NSEvent.EventType.otherMouseUp) {
                trigger(id)
            }
            return nil;
        }
    }
    
    return Unmanaged.passUnretained(event);
}

func respondTo(_ id: String) -> Bool {
    let gestureOpt = AppDelegate.CONFIG.gestures[id]
    
    if (gestureOpt == nil) { return false }
    let gesture = gestureOpt!
    
    return gesture.enabled
}

func trigger(_ id: String) {
    let gestureOpt = AppDelegate.CONFIG.gestures[id]
    if (gestureOpt == nil) { return }
    let gesture = gestureOpt!
    
    if (gesture.enabled == false) { return }
    
    let keyCodeOpt = Config.KEY_MAP[gesture.key]
    if (keyCodeOpt == nil) { return }
    let keyCode = keyCodeOpt!

    let down = CGEventClass.init(virtualKey: keyCode, keyDown: true)
    let up = CGEventClass.init(virtualKey: keyCode, keyDown: false)
    
    if gesture.cmd {
        down.addFlag(CGEventFlags.maskCommand)
        up.addFlag(CGEventFlags.maskCommand)
    }

    if gesture.ctrl {
        down.addFlag(CGEventFlags.maskControl)
        up.addFlag(CGEventFlags.maskControl)
    }
    
    if gesture.option {
        down.addFlag(CGEventFlags.maskAlternate)
        up.addFlag(CGEventFlags.maskAlternate)
    }
   
    if gesture.shift {
        down.addFlag(CGEventFlags.maskShift)
        up.addFlag(CGEventFlags.maskShift)
    }
    
    down.post()
    up.post()
}
