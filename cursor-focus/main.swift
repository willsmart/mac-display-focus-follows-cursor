//
//  main.swift
//  cursor-focus
//
//  Created by Will on 22/07/20.
//  Copyright © 2020 Will. All rights reserved.
//

import Foundation
import AppKit


var displayCount:UInt32 = 0
var activeCount:UInt32 = 0      //used as a parameter, but value is ignored
CGGetActiveDisplayList(0, nil, &displayCount)
var displayIDList = Array<CGDirectDisplayID>(repeating: kCGNullDirectDisplay, count: Int(displayCount))
CGGetActiveDisplayList(displayCount, &(displayIDList), &activeCount)

struct Display {
    let id: CGDirectDisplayID
    let bounds: CGRect
}


let displays = displayIDList.map{displayId -> Display in
        let bounds = CGDisplayBounds(displayId)
        return Display(
            id: displayId,
            bounds: CGDisplayBounds(displayId)
        )
    }

print(["displays":displays])


func focus(display: Display) {
    let pt = CGPoint(
        x: display.bounds.origin.x,
        y: display.bounds.origin.y +  display.bounds.size.height/2
    )

    CGEvent(mouseEventSource: .none, mouseType: .leftMouseDown, mouseCursorPosition:
        pt, mouseButton: .left)?.post(tap: .cghidEventTap)
    CGEvent(mouseEventSource: .none, mouseType: .leftMouseUp, mouseCursorPosition: pt, mouseButton: .left)?.post(tap: .cghidEventTap)
    CGEvent(mouseEventSource: .none, mouseType: .mouseMoved, mouseCursorPosition: mslocation, mouseButton: .left)?.post(tap: .cghidEventTap)
}

var mslocation=CGPoint()
var eventTargetPid: Int32?

let tap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: CGEventMask(1 << CGEventType.mouseMoved.rawValue), callback: { (tapProxy, type, event, _:UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
    mslocation = event.location
    eventTargetPid = Int32(event.getIntegerValueField(.eventTargetUnixProcessID))
    return nil
}, userInfo: nil)!

let dockPid = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.processIdentifier

var currentDisplay: Display?

CFRunLoopAddSource(
    CFRunLoopGetCurrent(),
    CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0),
    .commonModes
)

let delaySeconds = 0.2
CFRunLoopAddTimer(CFRunLoopGetCurrent(), CFRunLoopTimerCreateWithHandler(
    kCFAllocatorDefault,
    CFAbsoluteTimeGetCurrent() + delaySeconds, delaySeconds, 0, 0,
    { timer in
        guard eventTargetPid != dockPid else {return}

        let display = displays.first(where: {$0.bounds.contains(mslocation)})
        guard currentDisplay?.id != display?.id else {return}

        currentDisplay = display
        guard let d = display else {return}
        focus(display: d)

        print("Now in display \(d.id)")
    }
), .commonModes)

CFRunLoopRun()
