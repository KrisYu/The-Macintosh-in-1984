//
//  AppDelegate.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
       
        // we don't init from storyboard and must have a ViewController otherwise it will crash
        window = UIWindow()
        window?.rootViewController = UIViewController()
        
        let screenRect = UIScreen.main.bounds
        // This bottomView will used to hold everything
        let bottomView = window?.rootViewController?.view ?? UIView(frame: screenRect)

        
        // Once boot, the user will see this verboseBoot quickly, and when finished, the verbose boot will remove itself from superview
        let verboseBoot = AZVerboseBoot(frame: screenRect)
        bottomView.addSubview(verboseBoot)
        verboseBoot.loadBootWithDuration(SystemSettings.verboseBootTime) {
            // once down, remove verboseBoot
            verboseBoot.removeFromSuperview()
            
            // The boot window with a Finder like face view and progress bar
            let bootloader = AZBootWindow(frame: screenRect)
            bottomView.addSubview(bootloader)
            
            bootloader.animateProgress(duration: SystemSettings.bootLoaderTime) {
                
                // once done, remove bootloader
                bootloader.removeFromSuperview()
                
                // create the main soul - azdesktop
                let azdesktop = AZDesktop(frame: screenRect, menuBar: AZMenuBar(inRect: screenRect))
                
                // add desktop apps
                
                // add help notepad on desktop
                let guideNotePad = HelpNotePad(withIdentifier: "Guide")
                let guideApp = DesktopApplication(app: guideNotePad, on: azdesktop)
                
                // add about notepad on desktop
                let aboutmeNotePad = AboutMe(withIdentifier: "aboutme")
                aboutmeNotePad.windowTitle = "About Me"
                let aboutmeApp = DesktopApplication(app: aboutmeNotePad, on: azdesktop)
                
                // add picasso
                let paint = Picasso()
                let picasso = DesktopApplication(app: paint, on: azdesktop)

                azdesktop.add(desktopApp: guideApp)
                azdesktop.add(desktopApp: aboutmeApp)
                azdesktop.add(desktopApp: picasso)
                
                bottomView.addSubview(azdesktop)
            }
        }
        
        
        window?.addSubview(bottomView)
        window?.makeKeyAndVisible()

        return true
    }
}

