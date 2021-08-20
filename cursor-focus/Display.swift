//
//  Display.swift
//  cursor-focus
//
//  Created by Will on 23/07/20.
//  Copyright © 2020 Will. All rights reserved.
//

import Foundation
import AppKit

class Display {
    let id: CGDirectDisplayID
    let bounds: CGRect

    init(id: CGDirectDisplayID, bounds: CGRect) {
        self.id = id
        self.bounds = bounds
    }

    lazy var description: String = {
        "<Display \(id) at \(bounds)>"
    }()

    // statics
    
    static var all:[Display] {
        var displayCount:UInt32 = 0
        var activeCount:UInt32 = 0      //used as a parameter, but value is ignored
        CGGetActiveDisplayList(0, nil, &displayCount)
        var displayIDList = Array<CGDirectDisplayID>(repeating: kCGNullDirectDisplay, count: Int(displayCount))
        CGGetActiveDisplayList(displayCount, &(displayIDList), &activeCount)

        return displayIDList.map{displayId -> Display in
            return Display(
                id: displayId,
                bounds: CGDisplayBounds(displayId)
            )
        }
    }

    func focus(mslocation: CGPoint) {
        let pt = CGPoint(
            x: bounds.origin.x,
            y: bounds.origin.y +  bounds.size.height/2
        )
        CGEvent(mouseEventSource: .none, mouseType: .leftMouseDown, mouseCursorPosition:
            pt, mouseButton: .left)?.post(tap: .cghidEventTap)
        CGEvent(mouseEventSource: .none, mouseType: .leftMouseUp, mouseCursorPosition: pt, mouseButton: .left)?.post(tap: .cghidEventTap)
        CGEvent(mouseEventSource: .none, mouseType: .mouseMoved, mouseCursorPosition: mslocation, mouseButton: .left)?.post(tap: .cghidEventTap)
    }
}

