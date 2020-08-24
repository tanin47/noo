//
//  NooUITests.swift
//  NooUITests
//
//  Created by Tanin Na Nakorn on 5/22/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import XCTest

extension Shortcut {
    override public func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Shortcut else { return false }
        return self.id == other.id &&
            self.key == other.key &&
            self.enabled == other.enabled &&
            self.cmd == other.cmd &&
            self.ctrl == other.ctrl &&
            self.option == other.option &&
            self.shift == other.shift;
    }
}

class NooUITests: XCTestCase {
    
    var app: XCUIApplication!
    var userDefaultsFileName: String!

    override func setUp() {
        continueAfterFailure = false
        userDefaultsFileName = NSUUID().uuidString
        app = XCUIApplication()
        app.launchArguments = ["-ui-testing", userDefaultsFileName]
        app.launch()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func readConfig(_ id: String) -> Shortcut {
        let data = try! Data(contentsOf: NSURL.fileURL(withPathComponents: [NSTemporaryDirectory(), "..", "tanin.noo", userDefaultsFileName])!)
        let mappings = try! JSONSerialization.jsonObject(with: data) as! [String:Any]
        
        return try! Shortcut.decode(id, mappings[id]! as! [String:Any])
    }

    func testExample() {
        let statusItem = app.statusItems.firstMatch
        statusItem.click()
        statusItem.menuItems.firstMatch.click()

        let row = app.tableRows.element(boundBy: 1)
        row.cells.firstMatch.checkBoxes.firstMatch.click()
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 0).click()
        row.cells.element(boundBy: 1).descendants(matching: .popUpButton).element(boundBy: 0).click()
        row.menuItems.element(boundBy: 3).click()
        
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "3", enabled: true, cmd: true))

        row.cells.element(boundBy: 1).descendants(matching: .popUpButton).element(boundBy: 0).click()
        row.menuItems.element(boundBy: 5).click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: true, cmd: true))
        
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 1).click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: true, cmd: true, ctrl: true))
        
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 2).click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: true, cmd: true, ctrl: true, option: true))
        
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 3).click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: true, cmd: true, ctrl: true, option: true, shift: true))
        
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 0).click()
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 1).click()
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 2).click()
        row.cells.element(boundBy: 1).descendants(matching: .checkBox).element(boundBy: 3).click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: true))
        
        row.cells.firstMatch.checkBoxes.firstMatch.click()
        XCTAssertEqual(readConfig("finger-4"), Shortcut(id: "finger-4", key: "5", enabled: false))
        
        let anotherRow = app.tableRows.element(boundBy: 5)
        anotherRow.cells.firstMatch.checkBoxes.firstMatch.click()
        XCTAssertEqual(readConfig("mouse-button-3"), Shortcut(id: "mouse-button-3", key: "0", enabled: true))
    }
}
