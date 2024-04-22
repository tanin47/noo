//
//  Mocks.swift
//  NooTests
//
//  Created by Tanin Na Nakorn on 5/22/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa
@testable import Noo
    
class MockCGEvent: NooCGEventBase {
    static var events: [MockCGEvent] = []
    var virtualKey: Int?;
    var keyDown: Bool?;
    var flags: CGEventFlags = CGEventFlags();
    var posted: Bool = false;
    static var tapEnableInvoked: (tap: CFMachPort, enable: Bool)?
    
    static func clear() {
        MockCGEvent.tapEnableInvoked = nil
        MockCGEvent.events.removeAll()
    }
    
    required init(virtualKey: Int, keyDown: Bool) {
        self.virtualKey = virtualKey
        self.keyDown = keyDown
        MockCGEvent.events.append(self)
    }
    
    func addFlag(_ flag: CGEventFlags) {
        flags.insert(flag)
    }
    
    func post() {
        self.posted = true
    }
    
    static func tapEnable(tap: CFMachPort, enable: Bool) {
        MockCGEvent.tapEnableInvoked = (tap: tap, enable: enable)
    }
}

class MockNSRunningApplication: NSRunningApplication {
    override open var processIdentifier: pid_t {
        get { return 1234 }
    }
}

class MockNSWorkspace: NSWorkspace {
    override class var shared: NSWorkspace {
        get {
            return MockNSWorkspace()
        }
    }
    
    override var frontmostApplication: NSRunningApplication? {
        get {
            return MockNSRunningApplication()
        }
    }
}

