//  MacApp.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


/// Apps will conform to this protocol
protocol MacApp {
    
    /// A unique application identifier
    var uniqueIdentifier: String {get}
    
    /// A type application identifier
    var identifier: String? {get}
    
    /// The application main view
    var container: UIView? {get set}
    
    /// The application menu bar actions
    var menuActions: [MenuAction]? {get set}
    
    /// The window title of the application
    var windowTitle: String? {get set}
    
    /// The content mode style use `light` to get a black toolbar and `default` for a one with 5 lines.
    var contentMode: ContentStyle {get}
    
    /// Can the application be dragged around.
    var shouldDragApplication: Bool {get}
    
    /// The icon of the application if it appears on the desktop.
    var desktopIcon: UIImage? {get set}
    
    /// Delegate function, called when container will start dragging.
    func macApp(_ application: AZApplication, willStartDraggingContainer container: UIView)
    
    /// Delegate function, called when container has finished dragging.
    func macApp(_ application: AZApplication, didFinishDraggingContainer container: UIView)
    
    /// Called after application has launched.
    func didLaunchApplication(in view: AZDesktop, withApplication app: AZApplication)
    
    /// Called before application is lanuched.
    func willLaunchApplication(in view: AZDesktop,withApplication app: AZApplication)
    
    /// Called when application is about to be terminated.
    func willTerminateApplication()
    
    /// Data Source function, returns the size of the container.
    func sizeForWindow()->CGSize
    
}

/// enum : light `default`
enum ContentStyle {
    case light
    case `default`
}

// use extensions to make default methods/value for MacApp protocol
extension MacApp{
    
    /// Can the application be dragged around.
    var shouldDragApplication: Bool{
        return true
    }
    
    /// The icon of the application if it appears on the desktop.
    var desktopIcon: UIImage?{
        return UIImage()
    }
    
    /// The content mode style use `light` to get a black toolbar and `default` for a one with 5 lines.
    public var contentMode: ContentStyle{
        return .default
    }
    
    /// A type application identifier
    public var identifier: String?{
        return nil
    }
    
    /// The application menu bar actions
    var menuActions: [MenuAction]? {
        return nil
    }
    
    
    ///  Called after application has launched.
    ///
    /// - Parameters:
    ///   - desktop: AZDesktop, simulate the desktop view.
    ///   - app: AZApplication, the launched application.
    func didLaunchApplication(in desktop: AZDesktop, withApplication app: AZApplication){}
    
    
    /// Called before application is lanuched
    ///
    /// - Parameters:
    ///   - desktop: AZDesktop, simulate the desktop view.
    ///   - app: AZApplication, the launched application.
    func willLaunchApplication(in desktop: AZDesktop,withApplication app: AZApplication){}
    
    /// Called when application is about to be terminated.
    func willTerminateApplication(){}
    
    /// Delegate function called when application is about to be dragged.
    ///
    /// - Parameters:
    ///   - application: The current application.
    ///   - container: The current application's container.
    func macApp(_ application: AZApplication, willStartDraggingContainer container: UIView){}
    
    /// Delegate function called when application finished dragging.
    ///
    /// - Parameters:
    ///   - application: The current application UIView.
    ///   - container: The current application's container.
    func macApp(_ application: AZApplication, didFinishDraggingContainer container: UIView){}
}

