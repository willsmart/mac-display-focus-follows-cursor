//
//  main.swift
//  cursor-focus
//
//  Created by Will on 22/07/20.
//  Copyright © 2020 Will. All rights reserved.
//

import Foundation
import AppKit


let displays = Display.all
print(Window.all.map{$0.description}.joined(separator: "\n"))

var mslocation=CGPoint()
var dockActive = false

let dockPid = NSRunningApplication.runningApplications(withBundleIdentifier: "com.apple.dock").first?.processIdentifier

let tap = CGEvent.tapCreate(tap: .cgAnnotatedSessionEventTap, place: .headInsertEventTap, options: .listenOnly, eventsOfInterest: CGEventMask(1 << CGEventType.mouseMoved.rawValue), callback: { (tapProxy, type, event, _:UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? in
    mslocation = event.location
    dockActive = Int32(event.getIntegerValueField(.eventTargetUnixProcessID)) == dockPid
    return nil
}, userInfo: nil)!


var currentDisplay: Display?
var currentWindow: Window?

CFRunLoopAddSource(
    CFRunLoopGetCurrent(),
    CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0),
    .commonModes
)

let delaySeconds = 1.0
CFRunLoopAddTimer(CFRunLoopGetCurrent(), CFRunLoopTimerCreateWithHandler(
    kCFAllocatorDefault,
    CFAbsoluteTimeGetCurrent() + delaySeconds, delaySeconds, 0, 0,
    { timer in
        guard !dockActive else {return}
       print("\n\n")
        print(Window.all.map{$0.description}.joined(separator: "\n"))
        
        guard let w = Window.at(mslocation) else {return}
        guard w.id != currentWindow?.id else {return}

        currentWindow = w
        w.focus()
        print("Focus \(w)")
    }
), .commonModes)

CFRunLoopRun()
