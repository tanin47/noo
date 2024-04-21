//
//  SettingsViewController.swift
//  Noo
//
//  Created by Tanin Na Nakorn on 4/28/20.
//  Copyright © 2020 Tanin Na Nakorn. All rights reserved.
//

import Cocoa

class SettingsViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextViewDelegate, NSWindowDelegate {
    
    var blinkingId: Int = 0
    var instructionView: NSStackView
    var scrollView: NSScrollView
    var tableView: NSTableView
    var originColumn: NSTableColumn
    var shortcutColumn: NSTableColumn
    var editingShortcutEditor: ShortcutEditor?
    static let LABELS: [String: String] = [
        "finger-3": "3-finger touch",
        "finger-4": "4-finger touch",
        "finger-5": "5-finger touch",
        "mouse-button-right": "Mouse right button",
        "mouse-button-2": "Mouse button 2",
        "mouse-button-3": "Mouse button 3",
        "mouse-button-4": "Mouse button 4",
        "mouse-button-5": "Mouse button 5",
        "mouse-button-6": "Mouse button 6",
        "mouse-button-7": "Mouse button 7",
        "mouse-button-8": "Mouse button 8"
    ]
    
    init() {
        scrollView = NSScrollView()
        tableView = NSTableView()
        instructionView = NSStackView()
        originColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Origin"))
        shortcutColumn = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("Shortcut"))
        super.init(nibName: nil, bundle: nil)

        instructionView.edgeInsets = NSEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        instructionView.orientation = .vertical
        instructionView.alignment = .centerX
        instructionView.wantsLayer = true

        let instructionText = NSTextField()
        instructionText.isBezeled = false
        instructionText.drawsBackground = false
        instructionText.isEditable = false
        instructionText.isSelectable = true
        instructionText.stringValue = "Click a mouse button to identify its button number"
        instructionView.addArrangedSubview(instructionText)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        scrollView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.vertical)
        scrollView.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: NSLayoutConstraint.Orientation.horizontal)
        scrollView.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.vertical)
        
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false
        scrollView.documentView = tableView
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[table]-0-|", options: [], metrics: nil, views: ["table": tableView]))
        scrollView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[table]-26-|", options: [], metrics: nil, views: ["table": tableView]))
        
        tableView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        tableView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.vertical)
        tableView.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: NSLayoutConstraint.Orientation.horizontal)
        tableView.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: NSLayoutConstraint.Orientation.vertical)
        
        tableView.gridStyleMask = NSTableView.GridLineStyle.init(arrayLiteral: NSTableView.GridLineStyle.solidHorizontalGridLineMask, NSTableView.GridLineStyle.solidVerticalGridLineMask)
        tableView.allowsEmptySelection = true
        tableView.allowsColumnSelection = false
        tableView.allowsMultipleSelection = false
        tableView.allowsTypeSelect = false
        tableView.allowsColumnResizing = true
        tableView.allowsColumnReordering = false
        tableView.usesAutomaticRowHeights = true
        tableView.columnAutoresizingStyle = NSTableView.ColumnAutoresizingStyle.lastColumnOnlyAutoresizingStyle;
        
        tableView.dataSource = self;
        tableView.delegate = self;
        
        originColumn.title = "Action"
        originColumn.width = 130
        originColumn.headerCell.alignment = NSTextAlignment.center
        shortcutColumn.title = "Key combination"
        shortcutColumn.headerCell.alignment = NSTextAlignment.center
        
        tableView.addTableColumn(originColumn)
        tableView.addTableColumn(shortcutColumn)
    }
    
    func gestured(_ id: String) {
        if (NSApplication.shared.keyWindow?.contentViewController != self) { return }
        
        var rowIndex = -1
        
        for i in 0...(Config.IDS.count - 1) {
            if id == Config.IDS[i] {
                rowIndex = i
                break
            }
        }
        
        if (rowIndex == -1) {
            return
        }
        
        let view = tableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: false)
        
        if (view != nil) {
            blinkingId += 1
            animateBlinking(view!, id: blinkingId, visible: false, count: 4)
        }
    }
    
    func animateBlinking(_ view: NSView, id: Int, visible: Bool, count: Int) {
        if (blinkingId != id) {
            view.alphaValue = 1.0
            return
        }
        
        if (count <= 0) { return }
        
        NSAnimationContext.runAnimationGroup({ (context) in
            context.duration = 0.125
            view.animator().alphaValue = visible ? 1.0 : 0.0
            
        }, completionHandler:{
            self.animateBlinking(view, id: id, visible: !visible, count: count - 1)
        })
    }
    
    @objc func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = NSView(frame: NSRect.init(x: 0, y: 0, width: 480, height: 10))
        self.view.becomeFirstResponder()
        let view = NSStackView(views: [instructionView, scrollView])
        view.alignment = .centerX
        view.orientation = .vertical
        view.setCustomSpacing(0.0, after: instructionView)
        
        self.view.addSubview(view)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[view]-0-|", options: [], metrics: nil, views: ["view": view]))
        
        self.view.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
        self.view.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.vertical)
        self.view.setContentHuggingPriority(NSLayoutConstraint.Priority.defaultLow, for: NSLayoutConstraint.Orientation.horizontal)
        self.view.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.vertical)
        
        tableView.sizeLastColumnToFit()
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return Config.IDS.count;
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false;
    }
    
    @objc func checked(_ sender: NSButton) {
        let button = tableView.view(atColumn: 0, row: sender.tag, makeIfNecessary: true)!.subviews[0] as! NSButton;
        let editor = tableView.view(atColumn: 1, row: sender.tag, makeIfNecessary: true)! as! ShortcutEditor;
        
        editor.shortcut.enabled = button.state == NSControl.StateValue.on
        editor.update()
        AppDelegate.CONFIG.save()
    }
    
    func update() {
        for rowIndex in 0...(tableView.numberOfRows - 1) {
            let button = tableView.view(atColumn: 0, row: rowIndex, makeIfNecessary: true)!.subviews[0] as! NSButton;
            let editor = tableView.view(atColumn: 1, row: rowIndex, makeIfNecessary: true)! as! ShortcutEditor;
            
            editor.update()
            button.state = editor.enabled ? NSButton.StateValue.on : NSButton.StateValue.off
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if (tableColumn == originColumn) {
            var viewOpt = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as NSView?;
            if viewOpt == nil {
                viewOpt = NSView.init()
            }
            
            let view = viewOpt! as NSView
            let button = NSButton.init()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setButtonType(NSButton.ButtonType.switch)
            button.title = SettingsViewController.LABELS[Config.IDS[row]]!
            button.action = #selector(checked)
            button.target = self
            button.tag = row
            
            view.addSubview(button)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-2-[button]", options: [], metrics: nil, views: ["button":button]))
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[button]-2-|", options: [], metrics: nil, views: ["button":button]))
            view.setContentCompressionResistancePriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
            view.setContentHuggingPriority(NSLayoutConstraint.Priority.required, for: NSLayoutConstraint.Orientation.horizontal)
            
            return view
        } else if (tableColumn == shortcutColumn) {
            var viewOpt = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! ShortcutEditor?;
            if viewOpt == nil {
                viewOpt = ShortcutEditor.init(frame: NSRect.init(x: 0, y: 0, width: 1, height: 1), shortcut: AppDelegate.CONFIG.gestures[Config.IDS[row]]!)
            }
            
            let view = viewOpt! as ShortcutEditor
            
            return view
        }
        
        return nil
    }
}
