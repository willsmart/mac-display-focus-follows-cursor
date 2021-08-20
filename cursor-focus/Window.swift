//
//  Window.swift
//  cursor-focus
//
//  Created by Will on 23/07/20.
//  Copyright © 2020 Will. All rights reserved.
//

import Foundation
import AppKit

fileprivate let maxAllAgeSeconds: CFAbsoluteTime = 10
fileprivate let systemWideElement = AXUIElementCreateSystemWide()

class Window {
    let id: CFNumber
    let bounds: CGRect
    let ownerPid: Int32
    let layer: Int
    let axelement: AXUIElement

    init(id:CFNumber, bounds: CGRect, ownerPid: Int32, layer: Int, axelement: AXUIElement) {
        self.id = id
        self.bounds = bounds
        self.ownerPid = ownerPid
        self.layer = layer
        self.axelement = axelement
    }
    
    lazy var description: String = {
        "<Window \(id) layer \(layer) from \(ownerPid) at \(bounds)>"
    }()
    
    lazy var app: Application? = {
        Application.withPid(ownerPid)
    }()

    func setAsMain() {
        AXUIElementSetAttributeValue(axelement, NSAccessibility.Attribute.main.rawValue as CFString,
        true as CFTypeRef)
    }
    func focus() {
        setAsMain()
        app?.focus()
        Window._allRetreivedAt = 0
    }
    
    // statics
    
    static func top(onDisplay display:Display) -> Window? {
        let all = self.all
        return all.first{display.bounds.intersects($0.bounds)}
    }
    
    static func at(_ point: CGPoint) -> Window? {
        let all = self.all
        return all.first{$0.bounds.contains(point)}
    }
    

    fileprivate static var _allRetreivedAt: CFAbsoluteTime = 0
    fileprivate static var _all: [Window] = []
    static var all:[Window] {
        let time = CFAbsoluteTimeGetCurrent()
        if time < _allRetreivedAt + maxAllAgeSeconds {return _all}
        _allRetreivedAt = time

        guard let cfwindows = CGWindowListCopyWindowInfo(
            CGWindowListOption(
                arrayLiteral: .optionOnScreenOnly, .excludeDesktopElements
            ),
            kCGNullWindowID
        ) as? [CFDictionary] else {
            print("No access to window list")
            exit(1)
        }
        
        _all = cfwindows.compactMap{cfwindow -> Window? in
            guard let window = cfwindow as? [CFString: AnyObject] else {return nil}
            
            let layer = window[kCGWindowLayer] as! CFNumber as! Int
            // Layer is 0 for our target windows
            guard layer == 0 else {return nil}
    
            let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds] as! CFDictionary)!
            
            var _el:AXUIElement?
            AXUIElementCopyElementAtPosition(systemWideElement, Float(bounds.origin.x+5), Float(bounds.origin.y+5), &_el)
            guard let el = _el else {return nil}
            
            let pid = Int32(truncating:window[kCGWindowOwnerPID] as! CFNumber)
            return Window(
                id: window[kCGWindowNumber] as! CFNumber,
                bounds: bounds,
                ownerPid: pid,
                layer: layer,
                axelement: el
            )
        }
        
        return _all
    }
    
}
