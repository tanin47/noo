//
//  EventLoopEventCallBackTests.swift
//  NooTests
//
//  Created by Tanin Na Nakorn on 5/22/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import XCTest
@testable import Noo


func mockCallback(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent, refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    return nil
}

class EventLoopEventCallBackTests: XCTestCase {
    var OriginalCGEventClass = CGEventClass
    var OriginalNSWorkspaceClass = NSWorkspaceClass
    var OriginalNSEventClass = NSEventClass
    
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
        NSEventClass = OriginalNSEventClass
    }
    
    func checkKeyEvent() {
        XCTAssertEqual(2, MockCGEvent.events.count)
        XCTAssertEqual(
            [CGEventFlags.maskCommand,CGEventFlags.maskCommand],
            MockCGEvent.events.map({ e in e.flags })
        )
        XCTAssertEqual(
            [Config.KEY_MAP["F3"], Config.KEY_MAP["F3"]],
            MockCGEvent.events.map({ e in e.virtualKey })
        )
        XCTAssertEqual(
            [1234, 1234],
            MockCGEvent.events.map({ e in e.pid })
        )
        
        let down = MockCGEvent.events[0];
        let up = MockCGEvent.events[1];
        
        XCTAssertEqual(true, down.keyDown)
        XCTAssertEqual(false, up.keyDown)
    }
    
    func testTimeout() {
        let event = CGEvent.init(keyboardEventSource: nil, virtualKey: 0, keyDown: false)!
        XCTAssertEqual(
            event,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: CGEventType.tapDisabledByTimeout, event: event, refcon: nil)?.takeUnretainedValue()
        )
    }
    
    func testLeftClick() {
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.left)!
        XCTAssertEqual(
            event,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
    }
    
    func testMouseButtonNotConfigured() {
        let mouseButton = 2;
        
        AppDelegate.CONFIG.gestures["mouse-button-\(mouseButton)"]!.enabled = false
        
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.leftMouseDown, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.init(rawValue: UInt32(mouseButton))!)!
        XCTAssertEqual(
            event,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
    }
    
    func testRightMouseDown() {
        AppDelegate.CONFIG.gestures["mouse-button-right"] = Shortcut(
            id: "mouse-button-right",
            key: "F3",
            enabled: true,
            cmd: true
        )
        
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.rightMouseDown, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.right)!
        XCTAssertEqual(
            nil,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
        XCTAssertEqual(0, MockCGEvent.events.count)
    }
    
    func testRightMouseUp() {
        AppDelegate.CONFIG.gestures["mouse-button-right"] = Shortcut(
            id: "mouse-button-right",
            key: "F3",
            enabled: true,
            cmd: true
        )
        
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.rightMouseUp, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.right)!
        XCTAssertEqual(
            nil,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
        
        checkKeyEvent()
    }
    
    func testOtherMouseDown() {
        let mouseButton = 5;
        
        AppDelegate.CONFIG.gestures["mouse-button-\(mouseButton)"] = Shortcut(
            id: "mouse-button-\(mouseButton)",
            key: "F3",
            enabled: true,
            cmd: true
        )
        
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.otherMouseDown, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.init(rawValue: UInt32(mouseButton))!)!
        XCTAssertEqual(
            nil,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
        XCTAssertEqual(0, MockCGEvent.events.count)
    }
    
    func testOtherMouseUp() {
        let mouseButton = 5;
        
        AppDelegate.CONFIG.gestures["mouse-button-\(mouseButton)"] = Shortcut(
            id: "mouse-button-\(mouseButton)",
            key: "F3",
            enabled: true,
            cmd: true
        )
        
        let event = CGEvent.init(mouseEventSource: nil, mouseType: CGEventType.otherMouseUp, mouseCursorPosition: CGPoint(), mouseButton: CGMouseButton.init(rawValue: UInt32(mouseButton))!)!
        XCTAssertEqual(
            nil,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
        
        checkKeyEvent()
    }
    
    func testFingerNotConfigured() {
        AppDelegate.CONFIG.gestures["finger-3"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-4"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            static var capturedEvent: CGEvent?
            required init(cgEvent: CGEvent) {
                MockNSEvent.capturedEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                return Set.init(arrayLiteral: NSTouch.init(), NSTouch.init(), NSTouch.init())
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let event = CGEvent.init(keyboardEventSource: nil, virtualKey: 0, keyDown: false)!
        XCTAssertEqual(
            event,
            eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue()
        )
        XCTAssertEqual(
            MockNSEvent.capturedEvent,
            event
        )
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.14) as Date)
        XCTAssertEqual(0, MockCGEvent.events.count)
    }
    
    func testFinger3() {
        AppDelegate.CONFIG.gestures["finger-3"] = Shortcut(
           id: "finger-3",
           key: "F3",
           enabled: true,
           cmd: true
       )
        AppDelegate.CONFIG.gestures["finger-4"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            static var capturedEvent: CGEvent?
            required init(cgEvent: CGEvent) {
                MockNSEvent.capturedEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                return Set.init(arrayLiteral: NSTouch.init(), NSTouch.init(), NSTouch.init())
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let event = CGEvent.init(keyboardEventSource: nil, virtualKey: 0, keyDown: false)!
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: event.type, event: event, refcon: nil)?.takeUnretainedValue())
        XCTAssertEqual(MockNSEvent.capturedEvent, event)
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        checkKeyEvent()
    }
    
    func testFinger34() {
        AppDelegate.CONFIG.gestures["finger-3"] = Shortcut(
           id: "finger-3",
           key: "A",
           enabled: true,
           cmd: true
       )
        AppDelegate.CONFIG.gestures["finger-4"] = Shortcut(
          id: "finger-4",
          key: "F3",
          enabled: true,
          cmd: true
      )
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            
            let cgEvent: CGEvent
            required init(cgEvent: CGEvent) {
                self.cgEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                if NSEvent.init(cgEvent: self.cgEvent)?.keyCode == 3 {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch())
                } else {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch(), NSTouch())
                }
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let eventFinger3 = CGEvent.init(keyboardEventSource: nil, virtualKey: 3, keyDown: true)!
        let eventFinger4 = CGEvent.init(keyboardEventSource: nil, virtualKey: 4, keyDown: false)!
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger3.type, event: eventFinger3, refcon: nil)?.takeUnretainedValue())
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.01) as Date)
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger4.type, event: eventFinger4, refcon: nil)?.takeUnretainedValue())
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        checkKeyEvent()
    }
    
    func testFinger43with4Disabled() {
        AppDelegate.CONFIG.gestures["finger-3"] = Shortcut(
           id: "finger-3",
           key: "F3",
           enabled: true,
           cmd: true
       )
        AppDelegate.CONFIG.gestures["finger-4"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            
            let cgEvent: CGEvent
            required init(cgEvent: CGEvent) {
                self.cgEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                if NSEvent.init(cgEvent: self.cgEvent)?.keyCode == 3 {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch())
                } else {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch(), NSTouch())
                }
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let eventFinger3 = CGEvent.init(keyboardEventSource: nil, virtualKey: 3, keyDown: true)!
        let eventFinger4 = CGEvent.init(keyboardEventSource: nil, virtualKey: 4, keyDown: false)!
        
        XCTAssertEqual(eventFinger4, eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger4.type, event: eventFinger4, refcon: nil)?.takeUnretainedValue())
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        XCTAssertEqual(0, MockCGEvent.events.count)
        
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger3.type, event: eventFinger3, refcon: nil)?.takeUnretainedValue())
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        checkKeyEvent()
    }
    
    func testFingerCancel3() {
        AppDelegate.CONFIG.gestures["finger-3"] = Shortcut(
           id: "finger-3",
           key: "A",
           enabled: true,
           cmd: true
       )
        AppDelegate.CONFIG.gestures["finger-4"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            
            let cgEvent: CGEvent
            required init(cgEvent: CGEvent) {
                self.cgEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                if NSEvent.init(cgEvent: self.cgEvent)?.keyCode == 3 {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch())
                } else {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch(), NSTouch(), NSTouch())
                }
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let eventFinger3 = CGEvent.init(keyboardEventSource: nil, virtualKey: 3, keyDown: true)!
        let eventFinger5 = CGEvent.init(keyboardEventSource: nil, virtualKey: 5, keyDown: false)!
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger3.type, event: eventFinger3, refcon: nil)?.takeUnretainedValue())
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.01) as Date)
        XCTAssertEqual(eventFinger5, eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger5.type, event: eventFinger5, refcon: nil)?.takeUnretainedValue())
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        XCTAssertEqual(0, MockCGEvent.events.count)
    }
    
    func testFinger34With3Disabled() {
        AppDelegate.CONFIG.gestures["finger-3"]!.enabled = false
        AppDelegate.CONFIG.gestures["finger-4"] = Shortcut(
                  id: "finger-4",
                  key: "F3",
                  enabled: true,
                  cmd: true
              )
        AppDelegate.CONFIG.gestures["finger-5"]!.enabled = false
        
        class MockNSEvent: NooNSEventBase {
            
            let cgEvent: CGEvent
            required init(cgEvent: CGEvent) {
                self.cgEvent = cgEvent
            }
            
            var type: NSEvent.EventType {
                get { return NSEvent.EventType.gesture }
            }
            
            var buttonNumber: Int {
                get { return 0 }
            }
            
            func touches(matching phase: NSTouch.Phase, in view: NSView?) -> Set<NSTouch> {
                if NSEvent.init(cgEvent: self.cgEvent)?.keyCode == 3 {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch())
                } else {
                    return Set.init(arrayLiteral: NSTouch(), NSTouch(), NSTouch(), NSTouch())
                }
            }
        }
        
        NSEventClass = MockNSEvent.self
        
        let eventFinger3 = CGEvent.init(keyboardEventSource: nil, virtualKey: 3, keyDown: true)!
        let eventFinger4 = CGEvent.init(keyboardEventSource: nil, virtualKey: 4, keyDown: false)!
        XCTAssertEqual(eventFinger3, eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger3.type, event: eventFinger3, refcon: nil)?.takeUnretainedValue())
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.01) as Date)
        XCTAssertNil(eventCallback(proxy: CGEventTapProxy(bitPattern: 1)!, type: eventFinger4.type, event: eventFinger4, refcon: nil)?.takeUnretainedValue())
        
        RunLoop.current.run(until: NSDate.init(timeIntervalSinceNow: 0.11) as Date)
        checkKeyEvent()
    }
}
