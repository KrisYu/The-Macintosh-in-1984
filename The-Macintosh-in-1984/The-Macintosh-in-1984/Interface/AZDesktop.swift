//
//  AZDesktop.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class AZDesktop: UIView {

    var applicationIdentifiers: [String: AZApplication] = [:]
    
    /// Other apps
    var activeApplications: [MacApp] = []
    
    /// desktop apps
    var desktopApplications: [DesktopApplication] = []
    
    /// The finder app
    // we use weak here because finder also captures desktop, we have a memory cycle here
    lazy var rootApplication: MacApp = { [weak self] in
        let finder = Finder()
        finder.desktop = self
        return finder
    }()
    
    /// OS Menu Bar
    var menuBar: AZMenuBar
    

    init(frame: CGRect, menuBar: AZMenuBar) {
        self.menuBar = menuBar
        
        super.init(frame: frame)
        
        addSubview(menuBar)
        menuBar.dataSource = self
        menuBar.applicationMenuUpdate()
        
        backgroundColor = .gray
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The applications that appear when clicking the  menu.
    lazy var osMenus: [MenuAction] = {
        var menus = [MenuAction]()
        
        menus.append(MenuAction(title: "About the Finder...",action: {
            let newApplicationWindow = self.createApplication(from: self.rootApplication)
            self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(type: .seperator))
        
        menus.append(MenuAction(title: "Alarm Clock", action: {
            let newApplicationWindow = self.createApplication(from: AlarmClock())
            self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
        
        menus.append(MenuAction(title: "Calculator", action: {
            let newApplicationWindow = self.createApplication(from: Calculator())
            self.loadApplication(newApplicationWindow)
        }, subMenus: nil))
        
        
        menus.append(MenuAction(title: "Control Panel", enabled: false))
        
        menus.append(MenuAction(title: "Key Caps", action: {
            let applicationWindow = self.createApplication(from: KeyCaps())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
            
        
        menus.append(MenuAction(title: "Note Pad", action: {
            let applicationWindow = self.createApplication(from: NotePad())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        
        menus.append(MenuAction(title: "Puzzle", action: {
            let applicationWindow = self.createApplication(from: Puzzle())
            self.loadApplication(applicationWindow)
        }, subMenus: nil))
        
        
        menus.append(MenuAction(title: "Scrapbook", enabled: false))

        
        
        return menus
    }()
    
    
    /// A helper function that creates an instance of AZApplication using an instance of a MacApp. Note however that if the app exists in memory it will return it.
    func createApplication(from app: MacApp) -> AZApplication {
        let application = AZApplication(delegate: self, dataSource: app)
        
        
        let nApp : AZApplication = applicationIdentifiers[(application.dataSource.identifier) ?? (application.dataSource.uniqueIdentifier)] ?? application
        
        return nApp
    }
    
    /// Checks if application `MacApp` exists in memory.
    ///
    /// - Parameter app : The app that contains an identifier which we want to check.
    /// - Returns: true if the app exists, else false
    func doseApplicationExistInMemory(app: MacApp) -> Bool {
        if let _ = applicationIdentifiers[(app.identifier ?? app.uniqueIdentifier)] {
            return true
        } else {
            return false
        }
    }
    
    /// Load an AZApplication
    ///
    /// - Parameter app: The AZApplication which we want to load into the AZDesktop.
    func loadApplication(_ app: AZApplication) {
        loadApplication(app, under: menuBar)
    }
    
    /// Load an AZApplication
    ///
    /// - Parameters:
    ///     - app: The AZApplication which we want to load into the AZDesktop.
    ///     - menuBar: The menuBar which we are loading the application under.
    func loadApplication(_ app: AZApplication, under menuBar: AZMenuBar) {
        let nApp = applicationIdentifiers[(app.dataSource.identifier) ?? (app.dataSource.uniqueIdentifier)] ?? app
        
        nApp.dataSource.willLaunchApplication(in: self, withApplication: app)
        
        if let identifier = app.dataSource.identifier {
            
            // check if unique id exists already
            if let application = self.applicationIdentifiers[identifier] {
                
                // check if window is already subview
                if application.isDescendant(of: self){
                    // bring to front
                    bringAppToFront(application)
                    return
                } else {
                    // add subview
                    menuBar.closeAllMenus()
                    addAppAsSubView(application)
                }
            } else {
                // add application to UI and IDs
                applicationIdentifiers[identifier] = app
                menuBar.closeAllMenus()
                addAppAsSubView(app)
            }
        } else {
            // add application to ui without adding unique id
            menuBar.closeAllMenus()
            addAppAsSubView(app)
        }
        
        nApp.dataSource.didLaunchApplication(in: self, withApplication: nApp)
    }
    
    /// Add app as subview in AZApplication
    ///
    /// - Parameter application: the application we added
    func addAppAsSubView(_ application: AZApplication) {
        insertSubview(application, belowSubview: menuBar)
        activeApplications.append(application.dataSource)
        
        print("======================== Applications=============================")
        print("activeApplications: \(activeApplications)")
        print("applicationIdentifiers\(applicationIdentifiers)")
        print("======================== Applications End =============================")
        
        if application.frame.origin == .zero {
            application.center = center
        }
        application.layoutIfNeeded()
    }
    
    
    
    /// Bring Application to the front
    func bringAppToFront(_ application: AZApplication) {
        
        let id: String = application.dataSource.uniqueIdentifier
        var i = 0
        for app in activeApplications{
            if app.uniqueIdentifier == id {
                activeApplications.append(activeApplications.remove(at: i))
                break
            }
            i += 1
        }
        
        bringSubview(toFront: application)
        bringSubview(toFront: menuBar)
    }
    
    
    /// The `close` function is a function that is used to terminate a certain application
    ///
    /// - Parameter app: The app which we want to terminate
    func close(app: MacApp) {
        if let nApp = applicationIdentifiers[(app.identifier ?? (app.uniqueIdentifier))] {
            nApp.close()
        }
    }
    
    /// The `add` function allow us to load desktop applications. The placement of the applications will be set automatically based on already existing applications on the desktop.
    ///
    /// - Parameter app: The app which we want to display on the desktop
    func add(desktopApp app: DesktopApplication) {
        
        let space = SystemSettings.desktopAppSpace
        
        let initalHeight: CGFloat = SystemSettings.menuBarHeight + space
        let initalWidth: CGFloat = bounds.width - MacAppDesktopView.width - space * 2
        
        var heightCounter: CGFloat = initalHeight
        var widthCounter: CGFloat = initalWidth
        
        for i in 0..<desktopApplications.count{
            let app = desktopApplications[i]
            let height = app.macAppDesktopView.frame.height + space * 2
            if heightCounter + height > bounds.height {
                //reset height to initial value
                heightCounter = initalHeight
                
                //move left
                widthCounter -= MacAppDesktopView.width
            }else{
                heightCounter += height
            }
            
        }
        
        app.macAppDesktopView.frame.origin = CGPoint(x: widthCounter, y: heightCounter)
        insertSubview(app.macAppDesktopView, at: 0)
        desktopApplications.append(app)
    }
    
}


// MARK: - AZApplicationDelegate
extension AZDesktop: AZApplicationDelegate{
    
    func application(_ application: AZApplication, willStartDraggingContainer container: UIView) {
        self.menuBar.closeAllMenus()
        bringAppToFront(application)
    }
    
    func application(_ application: AZApplication, didFinishDraggingContainer container: UIView) {
    }
    
    func application(_ application: AZApplication, didTapToolBar toolBar: AZToolBar, atPoint point: CGPoint) {
        self.menuBar.closeAllMenus()
        bringAppToFront(application)
    }

    
    func application(_ application: AZApplication, didCloseWindowWithToolBar toolBar: AZToolBar) {
        
        var i = 0
        
        for app in activeApplications {
            if app.uniqueIdentifier == application.dataSource.uniqueIdentifier {
                activeApplications.remove(at: i)
                break
            }
            i += 1
        }
        
        if let identifier = application.dataSource.identifier {
            switch identifier {
            case "calculator":
                applicationIdentifiers[identifier] = nil
            case "alarmclock":
                applicationIdentifiers[identifier] = nil
            default:
                break
            }
        } else {
            let uniqueId = application.dataSource.uniqueIdentifier
            applicationIdentifiers[uniqueId] = nil
        }
        
        
       
    }
    
    func application(_ application: AZApplication, canMoveToPoint point: inout CGPoint) -> Bool {
        let halfHeight = application.bounds.midY
        let osHeight = self.bounds.height
        
        if point.y < AZMenuBar.height + halfHeight {
            point.y = AZMenuBar.height + halfHeight
            return true
        } else if point.y > osHeight + halfHeight - AZMenuBar.height {
            point.y = osHeight + halfHeight - AZMenuBar.height
            return true
        }
        return true
    }

}


// MARK: - AZMenuBarDataSource
extension AZDesktop: AZMenuBarDataSource {
    func menuActions(_ toolBar: AZMenuBar) -> [MenuAction] {
        let topApp: MacApp = rootApplication
        return topApp.menuActions ?? []
    }
    
    func osMenuActions(_ toolBar: AZMenuBar) -> [MenuAction] {
        return self.osMenus
    }
}

// MARK: - DesktopAppDelegate
extension AZDesktop: DesktopAppDelegate {
    
    func didDoubleClick(_ application: DesktopApplication) {
        
        menuBar.closeAllMenus()
        
        // we create app form DesktopApplication app property
        let azApplication = createApplication(from: application.app)
        
        
        if azApplication.isDescendant(of: self) {
            bringAppToFront(azApplication)
            return
        }
        
        loadApplication(azApplication)
    }
    
    func willStartDragging(_ application: DesktopApplication) {
        self.menuBar.closeAllMenus()
    }
    
    func didFinishDragging(_ application: DesktopApplication) {
        
    }
    
    
}
