//
//  EventLoopTests.swift
//  NooTests
//
//  Created by Tanin Na Nakorn on 5/18/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import XCTest
@testable import Noo

class EventLoopTriggerTests: XCTestCase {
    
    var OriginalCGEventClass = CGEventClass
    var OriginalNSWorkspaceClass = NSWorkspaceClass
    
    override func setUp() {
        continueAfterFailure = false
        MockCGEvent.clear()
        Config.DEFAULTS = UserDefaults.init(suiteName: "EventLoopTest")!
        AppDelegate.CONFIG.loadDefaults()
        
        CGEventClass = MockCGEvent.self
        NSWorkspaceClass = MockNSWorkspace.self
    }
    
    override func tearDown() {
        CGEventClass = OriginalCGEventClass
        NSWorkspaceClass = OriginalNSWorkspaceClass
    }
    
    func testTriggerCmd() {
        let id = Config.IDS.first!
        AppDelegate.CONFIG.gestures[id] = Shortcut(
            id: id,
            key: "A",
            enabled: true,
            cmd: true
        )
        
        trigger(id)
        
        XCTAssertEqual(2, MockCGEvent.events.count)
        XCTAssertEqual(
            [CGEventFlags.maskCommand,CGEventFlags.maskCommand],
            MockCGEvent.events.map({ e in e.flags })
        )
        XCTAssertEqual(
            [Config.KEY_MAP["A"], Config.KEY_MAP["A"]],
            MockCGEvent.events.map({ e in e.virtualKey })
        )
        XCTAssertEqual(
            [true, true],
            MockCGEvent.events.map({ e in e.posted })
        )
        
        let down = MockCGEvent.events[0];
        let up = MockCGEvent.events[1];
        
        XCTAssertEqual(true, down.keyDown)
        XCTAssertEqual(false, up.keyDown)
    }
    
    func testTriggerCmdCtrl() {
        let id = Config.IDS.first!
        AppDelegate.CONFIG.gestures[id] = Shortcut(
            id: id,
            key: "F3",
            enabled: true,
            cmd: true,
            ctrl: true
        )
        
        trigger(id)
        
        XCTAssertEqual(2, MockCGEvent.events.count)
        
        let flags = CGEventFlags.init(arrayLiteral: CGEventFlags.maskCommand, CGEventFlags.maskControl)
        XCTAssertEqual(
            [flags, flags],
            MockCGEvent.events.map({ e in e.flags })
        )
        XCTAssertEqual(
            [Config.KEY_MAP["F3"], Config.KEY_MAP["F3"]],
            MockCGEvent.events.map({ e in e.virtualKey })
        )
        XCTAssertEqual(
            [true, true],
            MockCGEvent.events.map({ e in e.posted })
        )
        
        let down = MockCGEvent.events[0];
        let up = MockCGEvent.events[1];
        
        XCTAssertEqual(true, down.keyDown)
        XCTAssertEqual(false, up.keyDown)
    }
    
    func testTriggerCmdCtrlOption() {
        let id = Config.IDS.first!
        AppDelegate.CONFIG.gestures[id] = Shortcut(
            id: id,
            key: "7",
            enabled: true,
            cmd: true,
            ctrl: true,
            option: true
        )
        
        trigger(id)
        
        XCTAssertEqual(2, MockCGEvent.events.count)
        
        let flags = CGEventFlags.init(arrayLiteral: CGEventFlags.maskCommand, CGEventFlags.maskControl, CGEventFlags.maskAlternate)
        XCTAssertEqual(
            [flags, flags],
            MockCGEvent.events.map({ e in e.flags })
        )
        XCTAssertEqual(
            [Config.KEY_MAP["7"], Config.KEY_MAP["7"]],
            MockCGEvent.events.map({ e in e.virtualKey })
        )
        XCTAssertEqual(
            [true, true],
            MockCGEvent.events.map({ e in e.posted })
        )
        
        let down = MockCGEvent.events[0];
        let up = MockCGEvent.events[1];
        
        XCTAssertEqual(true, down.keyDown)
        XCTAssertEqual(false, up.keyDown)
    }
    
    func testTriggerCmdCtrlOptionShift() {
        let id = Config.IDS.first!
        AppDelegate.CONFIG.gestures[id] = Shortcut(
            id: id,
            key: "7",
            enabled: true,
            cmd: true,
            ctrl: true,
            option: true,
            shift: true
        )
        
        trigger(id)
        
        XCTAssertEqual(2, MockCGEvent.events.count)
        
        let flags = CGEventFlags.init(arrayLiteral: CGEventFlags.maskCommand, CGEventFlags.maskControl, CGEventFlags.maskAlternate, CGEventFlags.maskShift)
        XCTAssertEqual(
            [flags, flags],
            MockCGEvent.events.map({ e in e.flags })
        )
        XCTAssertEqual(
            [Config.KEY_MAP["7"], Config.KEY_MAP["7"]],
            MockCGEvent.events.map({ e in e.virtualKey })
        )
        XCTAssertEqual(
            [true, true],
            MockCGEvent.events.map({ e in e.posted })
        )
        
        let down = MockCGEvent.events[0];
        let up = MockCGEvent.events[1];
        
        XCTAssertEqual(true, down.keyDown)
        XCTAssertEqual(false, up.keyDown)
    }

}
