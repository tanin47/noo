//
//  EventLoopRespondToTestss.swift
//  NooTests
//
//  Created by Tanin Na Nakorn on 5/22/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import XCTest
@testable import Noo

class EventLoopRespondToTests: XCTestCase {
    
    override func setUp() {
        continueAfterFailure = false
        Config.DEFAULTS = UserDefaults.init(suiteName: "EventLoopTest")!
    }
    
    func testRespondTo() {
        AppDelegate.CONFIG.gestures[Config.IDS.first!]!.enabled = false
        XCTAssertEqual(false, respondTo(Config.IDS.first!))
        
        AppDelegate.CONFIG.gestures[Config.IDS.first!]!.enabled = true
        XCTAssertEqual(true, respondTo(Config.IDS.first!))
    }
}
