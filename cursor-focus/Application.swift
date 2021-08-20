//
//  App.swift
//  cursor-focus
//
//  Created by Will on 23/07/20.
//  Copyright © 2020 Will. All rights reserved.
//

import Foundation
import AppKit

fileprivate let maxAllAgeSeconds: CFAbsoluteTime = 10

class Application {
    fileprivate let runningApplication: NSRunningApplication
    
    init(runningApplication: NSRunningApplication) {
        self.runningApplication = runningApplication
    }
    
    lazy var description: String = {
        "<Application \(pid) \"\(name)\">"
    }()

    lazy var pid: Int32 = {
        runningApplication.processIdentifier
    }()
    
    lazy var name: String = {
        runningApplication.localizedName ?? "n/a"
    }()
    
    func focus() {
        runningApplication.activate(options: .activateIgnoringOtherApps)
    }

    // statics

    static let dock = Application.withBundleId("com.apple.dock")

    static func withBundleId(_ bundleId:String?) -> Application? {
        guard let bundleId = bundleId else {return nil}
        return NSRunningApplication.runningApplications(withBundleIdentifier: bundleId)
            .map{Application(runningApplication: $0)}
            .first
    }
    
    static func withPid(_ pid:Int32?) -> Application? {
        guard let pid = pid else {return nil}
        return allByPid[pid]
    }
    
    fileprivate static var _allRetreivedAt: CFAbsoluteTime = 0
    fileprivate static var _all: [Application] = []
    static var all: [Application] {
        let time = CFAbsoluteTimeGetCurrent()
        if time < _allRetreivedAt + maxAllAgeSeconds {return _all}
        _allRetreivedAt = time

        _all = NSWorkspace.shared.runningApplications
        .map{Application(runningApplication: $0)}
        return _all
    }
    
    fileprivate static var _allByPidRetreivedAt: CFAbsoluteTime = 0
    fileprivate static var _allByPid: [Int32: Application] = [:]
    static var allByPid: [Int32: Application] {
        let time = CFAbsoluteTimeGetCurrent()
        if time < _allByPidRetreivedAt + maxAllAgeSeconds {
            return _allByPid
        }
        _allByPidRetreivedAt = time
        
        _allByPid = Dictionary(uniqueKeysWithValues: Application.all.map{($0.runningApplication.processIdentifier, $0)}
        )
        return _allByPid
    }
}
