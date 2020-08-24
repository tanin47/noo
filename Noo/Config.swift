//
//  Config.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 5/17/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa
import os.log
import Carbon.HIToolbox.Events

public class Shortcut: NSObject {
    
    let id: String
    var enabled: Bool = false
    var cmd: Bool = true
    var ctrl: Bool = false
    var option: Bool = false
    var shift: Bool = true
    var key: String = "7"
    
    public override var description: String {
        return "Shortcut(id: \(id), enabled: \(enabled), cmd: \(cmd), ctrl: \(ctrl), option: \(option), shift: \(shift), key: \(key))"
    }
    
    init(id: String, key: String, enabled: Bool = false, cmd: Bool = false, ctrl: Bool = false, option: Bool = false, shift: Bool = false) {
        self.id = id
        self.enabled = enabled
        self.cmd = cmd
        self.ctrl = ctrl
        self.option = option
        self.shift = shift
        self.key = key
        
        super.init()
    }
    
    static func encode(_ s: Shortcut) -> [String: Any] {
        return [
            "enabled": s.enabled,
            "cmd": s.cmd,
            "ctrl": s.ctrl,
            "option": s.option,
            "shift": s.shift,
            "key": s.key
        ]
    }
    
    public static func decode(_ id: String, _ dict: [String: Any]) throws -> Shortcut {
        return Shortcut(
            id: id,
            key: dict["key"] as! String,
            enabled: dict["enabled"] as! Bool,
            cmd: dict["cmd"] as! Bool,
            ctrl: dict["ctrl"] as! Bool,
            option: dict["option"] as! Bool,
            shift: dict["shift"] as! Bool
        )
    }
  
}


class Config: NSObject {
    var gestures: [String: Shortcut] = [:]
    
    static let IDS = [
        "finger-3", "finger-4", "finger-5",
        "mouse-button-right",
        "mouse-button-2", "mouse-button-3", "mouse-button-4", "mouse-button-5", "mouse-button-6", "mouse-button-7", "mouse-button-8"
    ]
    
    static let KEYS = [
        ("0", kVK_ANSI_0),
        ("1", kVK_ANSI_1),
        ("2", kVK_ANSI_2),
        ("3", kVK_ANSI_3),
        ("4", kVK_ANSI_4),
        ("5", kVK_ANSI_5),
        ("6", kVK_ANSI_6),
        ("7", kVK_ANSI_7),
        ("8", kVK_ANSI_8),
        ("9", kVK_ANSI_9),
        ("A", kVK_ANSI_A),
        ("B", kVK_ANSI_B),
        ("C", kVK_ANSI_C),
        ("D", kVK_ANSI_D),
        ("E", kVK_ANSI_E),
        ("F", kVK_ANSI_F),
        ("G", kVK_ANSI_G),
        ("H", kVK_ANSI_H),
        ("I", kVK_ANSI_I),
        ("J", kVK_ANSI_J),
        ("K", kVK_ANSI_K),
        ("L", kVK_ANSI_L),
        ("M", kVK_ANSI_M),
        ("N", kVK_ANSI_N),
        ("O", kVK_ANSI_O),
        ("P", kVK_ANSI_P),
        ("Q", kVK_ANSI_Q),
        ("R", kVK_ANSI_R),
        ("S", kVK_ANSI_S),
        ("T", kVK_ANSI_T),
        ("U", kVK_ANSI_U),
        ("V", kVK_ANSI_V),
        ("W", kVK_ANSI_W),
        ("X", kVK_ANSI_X),
        ("Y", kVK_ANSI_Y),
        ("Z", kVK_ANSI_Z),
        ("\\", kVK_ANSI_Backslash),
        (",", kVK_ANSI_Comma),
        ("=", kVK_ANSI_Equal),
        ("`", kVK_ANSI_Grave),
        ("[", kVK_ANSI_LeftBracket),
        ("-", kVK_ANSI_Minus),
        (".", kVK_ANSI_Period),
        ("\"", kVK_ANSI_Quote),
        ("]", kVK_ANSI_RightBracket),
        (";", kVK_ANSI_Semicolon),
        ("/", kVK_ANSI_Slash),
        ("End", kVK_End),
        ("Esc", kVK_Escape),
        ("F1", kVK_F1),
        ("F2", kVK_F2),
        ("F3", kVK_F3),
        ("F4", kVK_F4),
        ("F5", kVK_F5),
        ("F6", kVK_F6),
        ("F7", kVK_F7),
        ("F8", kVK_F8),
        ("F9", kVK_F9),
        ("F10", kVK_F10),
        ("F11", kVK_F11),
        ("F12", kVK_F12),
        ("F13", kVK_F13),
        ("F14", kVK_F14),
        ("F15", kVK_F15),
        ("F16", kVK_F16),
        ("F17", kVK_F17),
        ("F18", kVK_F18),
        ("F19", kVK_F19),
        ("F20", kVK_F20),
        ("Help", kVK_Help),
        ("Home", kVK_Home),
        ("Left arrow", kVK_LeftArrow),
        ("Up arrow", kVK_UpArrow),
        ("Right arrow", kVK_RightArrow),
        ("Down arrow", kVK_DownArrow),
        ("Mute", kVK_Mute),
        ("Page down", kVK_PageDown),
        ("Page up", kVK_PageUp),
        ("Return", kVK_Return),
        ("Space", kVK_Space),
        ("Tab", kVK_Tab),
        ("Volume down", kVK_VolumeDown),
        ("Volume up", kVK_VolumeUp)
    ]
    
    static let KEY_MAP = Dictionary(uniqueKeysWithValues: KEYS)
    
    static let USER_DEFAULTS_NAMESPACE = "NooMappings"
    static var DEFAULTS = UserDefaults.standard
    static var MAPPINGS = Config.getMappings()
    
    #if DEBUG
    static var USER_DEFAULTS_FILE_NAME: String?
    #endif
    
    override init() {
        super.init()
        
        #if DEBUG
        let uiTesting = ProcessInfo.processInfo.arguments.contains("-ui-testing")
        
        if (uiTesting) {
            Config.USER_DEFAULTS_FILE_NAME = ProcessInfo.processInfo.arguments[2]
            Config.DEFAULTS = UserDefaults.init(suiteName: "EventLoopTest")!
            
            Config.MAPPINGS = Config.getMappings()
            for (key, _) in Config.MAPPINGS {
                Config.MAPPINGS.removeValue(forKey: key)
            }
            
            save()
        }
        #endif
        
        loadDefaults()
    }
    
    static func getMappings() -> [String: Any] {
        let dict = Config.DEFAULTS.dictionary(forKey: Config.USER_DEFAULTS_NAMESPACE)
        if dict == nil {
            Config.DEFAULTS.set([:], forKey: Config.USER_DEFAULTS_NAMESPACE)
        }
        return Config.DEFAULTS.dictionary(forKey: Config.USER_DEFAULTS_NAMESPACE)!
    }
    
    func loadDefaults() {
        for id in Config.IDS {
            let value = Config.MAPPINGS[id]
            
            if let shortcut = value as? [String: Any] {
                do {
                    try gestures[id] = Shortcut.decode(id, shortcut)
                } catch {
                    os_log("Error reading %@: %@", id, shortcut)
                }
            } else {
                gestures[id] = Shortcut(id: id, key: "0", enabled: false, cmd: false, ctrl: false, option: false, shift: false)
            }
        }
        
        self.save()
    }
    
    func save() {
        for (key, shortcut) in gestures {
            Config.MAPPINGS[key] = Shortcut.encode(shortcut)
        }

        Config.DEFAULTS.set(Config.MAPPINGS, forKey: Config.USER_DEFAULTS_NAMESPACE)
        
        #if DEBUG
        if Config.USER_DEFAULTS_FILE_NAME != nil {
            try! JSONSerialization.data(
                withJSONObject: Config.MAPPINGS,
                options: .prettyPrinted
            ).write(
                to: NSURL.fileURL(
                    withPathComponents: [NSTemporaryDirectory(), Config.USER_DEFAULTS_FILE_NAME!]
                )!
            )
        }
        #endif
    }
    
}
