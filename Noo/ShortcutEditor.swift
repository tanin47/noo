//
//  ShortcutEditor.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 5/17/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa

class ShortcutEditor: NSView {
    
    let shortcut: Shortcut
    let cmdButton: NSButton
    let ctrlButton: NSButton
    let optionButton: NSButton
    let shiftButton: NSButton
    let keyPopUpButton: NSPopUpButton
    
    
    var enabled: Bool {
        get {
            return shortcut.enabled
        }
    }
    
    init(frame frameRect: NSRect, shortcut: Shortcut) {
        self.shortcut = shortcut
        cmdButton = NSButton.init()
        ctrlButton = NSButton.init()
        optionButton = NSButton.init()
        shiftButton = NSButton.init()
        keyPopUpButton = NSPopUpButton.init()
        
        super.init(frame: NSMakeRect(0, 0, 0, 0))
        
        self.translatesAutoresizingMaskIntoConstraints = false
        cmdButton.translatesAutoresizingMaskIntoConstraints = false
        ctrlButton.translatesAutoresizingMaskIntoConstraints = false
        optionButton.translatesAutoresizingMaskIntoConstraints = false
        shiftButton.translatesAutoresizingMaskIntoConstraints = false
        keyPopUpButton.translatesAutoresizingMaskIntoConstraints = false
        
        keyPopUpButton.addItems(withTitles: Config.KEYS.map { tuple in return tuple.0 })
        
        self.addSubview(cmdButton)
        self.addSubview(ctrlButton)
        self.addSubview(optionButton)
        self.addSubview(shiftButton)
        self.addSubview(keyPopUpButton)
        
        cmdButton.title = "Cmd"
        ctrlButton.title = "Ctrl"
        optionButton.title = "Option"
        shiftButton.title = "Shift"
        
        cmdButton.bezelStyle = NSButton.BezelStyle.rounded
        ctrlButton.bezelStyle = NSButton.BezelStyle.rounded
        optionButton.bezelStyle = NSButton.BezelStyle.rounded
        shiftButton.bezelStyle = NSButton.BezelStyle.rounded
        
        cmdButton.setButtonType(NSButton.ButtonType.pushOnPushOff)
        ctrlButton.setButtonType(NSButton.ButtonType.pushOnPushOff)
        optionButton.setButtonType(NSButton.ButtonType.pushOnPushOff)
        shiftButton.setButtonType(NSButton.ButtonType.pushOnPushOff)
        keyPopUpButton.bezelStyle = NSPopUpButton.BezelStyle.rounded
        
        cmdButton.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        ctrlButton.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        optionButton.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        shiftButton.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        keyPopUpButton.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-2-[cmd]-2-[ctrl]-2-[option]-2-[shift]-2-[key(==100)]",
            options: [],
            metrics: nil,
            views: ["cmd": cmdButton, "ctrl": ctrlButton, "option": optionButton, "shift": shiftButton, "key": keyPopUpButton]
        ))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[cmd]-(>=1)-|",
            options: [],
            metrics: nil,
            views: ["cmd": cmdButton]
        ))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[ctrl]-(>=1)-|",
            options: [],
            metrics: nil,
            views: ["ctrl": ctrlButton]
        ))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[option]-(>=1)-|",
            options: [],
            metrics: nil,
            views: ["option": optionButton]
        ))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[shift]-(>=1)-|",
            options: [],
            metrics: nil,
            views: ["shift": shiftButton]
        ))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-1-[key]-(>=1)-|",
            options: [],
            metrics: nil,
            views: ["key": keyPopUpButton]
        ))
        
        self.needsUpdateConstraints = true
        
        cmdButton.action = #selector(checked)
        cmdButton.target = self
        ctrlButton.action = #selector(checked)
        ctrlButton.target = self
        optionButton.action = #selector(checked)
        optionButton.target = self
        shiftButton.action = #selector(checked)
        shiftButton.target = self
        keyPopUpButton.action = #selector(keySelected)
        keyPopUpButton.target = self
    }
    
    @objc func checked(_ sender: NSButton) {
        if sender == cmdButton {
            shortcut.cmd = cmdButton.state == NSButton.StateValue.on
        } else if sender == ctrlButton {
            shortcut.ctrl = ctrlButton.state == NSButton.StateValue.on
        } else if sender == optionButton {
            shortcut.option = optionButton.state == NSButton.StateValue.on
        } else if sender == shiftButton {
            shortcut.shift = shiftButton.state == NSButton.StateValue.on
        }
        
        update()
        AppDelegate.CONFIG.save()
    }
    
    @objc func keySelected(_ sender: NSPopUpButton) {
        shortcut.key = keyPopUpButton.selectedItem!.title
        update()
        AppDelegate.CONFIG.save()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update() {
        cmdButton.state = shortcut.cmd ? NSButton.StateValue.on : NSButton.StateValue.off
        ctrlButton.state = shortcut.ctrl ? NSButton.StateValue.on : NSButton.StateValue.off
        optionButton.state = shortcut.option ? NSButton.StateValue.on : NSButton.StateValue.off
        shiftButton.state = shortcut.shift ? NSButton.StateValue.on : NSButton.StateValue.off
        keyPopUpButton.selectItem(withTitle: shortcut.key)
        isHidden = !shortcut.enabled
    }
}
