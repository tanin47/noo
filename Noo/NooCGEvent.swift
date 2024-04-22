//
//  NooCGEvent.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 5/21/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa

public protocol NooCGEventBase {
    init(virtualKey: Int, keyDown: Bool);
    func addFlag(_ flag: CGEventFlags);
    func post();
    static func tapEnable(tap: CFMachPort, enable: Bool);
}

class NooCGEvent: NooCGEventBase {
    let event: CGEvent
    required init(virtualKey: Int, keyDown: Bool) {
        event = CGEvent.init(keyboardEventSource: nil, virtualKey: UInt16(virtualKey), keyDown: keyDown)!
    }
    
    func addFlag(_ flag: CGEventFlags) {
        event.flags.insert(flag)
    }
    
    func post() {
        event.post(tap: .cghidEventTap)
    }
    
    static func tapEnable(tap: CFMachPort, enable: Bool) {
        CGEvent.tapEnable(tap: tap, enable: enable)
    }
}

public protocol NooNSEventBase {
    init(cgEvent: CGEvent);
    var type: NSEvent.EventType { get };
    var buttonNumber: Int { get };
    func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch>;
}

class NooNSEvent: NooNSEventBase {
    let event: NSEvent
    required init(cgEvent: CGEvent) {
        event = NSEvent.init(cgEvent: cgEvent)!
    }
    
    var type: NSEvent.EventType {
        get { return event.type }
    }
    
    var buttonNumber: Int {
        get { return event.buttonNumber }
    }
    
    func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
        return event.touches(matching: phase, in: view)
    }
}
