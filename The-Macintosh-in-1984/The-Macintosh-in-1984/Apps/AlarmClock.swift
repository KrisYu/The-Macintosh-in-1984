//
//  AlarmClock.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class AlarmClock: MacApp {
    
    var desktopIcon: UIImage?
    
    var identifier: String? = "alarmclock"
    
    var windowTitle: String? = "Clock"

    var menuActions: [MenuAction]?
    
    var container: UIView?
    
    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    func sizeForWindow() -> CGSize {
        return SystemSettings.alarmClockSize
    }
    
    init() {
        container = UIView()
    }
    
    var app: AZApplication?
    
    var isActive = false
    
    func willLaunchApplication(in view: AZDesktop, withApplication app: AZApplication) {
        isActive = true
    }
    
    func willTerminateApplication() {
        isActive = false
    }
    
    func didLaunchApplication(in view: AZDesktop, withApplication app: AZApplication) {
        if self.app == nil {
            self.app = app
            self.app?.toolBar.drawLines = false
            self.app?.toolBar.title = Utils.extenedTime()
            recusiveTimer()
        } else {
            self.app?.toolBar.title = "lol"
        }
    }
    
    var timer: Timer!
    func recusiveTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.app?.toolBar.title = Utils.extenedTime()
        })        
    }
}
