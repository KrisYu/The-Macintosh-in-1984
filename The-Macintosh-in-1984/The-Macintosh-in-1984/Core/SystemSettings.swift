//
//  SystemSettings.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


struct SystemSettings{
    
    static var verboseBootTime: TimeInterval =  1
    
    static var bootLoaderTime: TimeInterval = 2 
    
    // we use UI_USER_INTERFACE_IDIOM() == .pad get to know the device, and then set the values accordingly.
    static let menuBarHeight: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 30: 20
    
    // for menu drop down view, the action height
    static let actionHeight: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 30: 20
    
    struct ToolBar {
        static let height: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 30: 20
        static let lineSpace: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 3 : 2
        static let lineSideSpace: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 2 : 1
        static let buttonDimension: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 18 : 12
    }
    
    struct DesktopApplication {
        /// The width of desktop applications
        static let width:  CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 130 : 65.0
        /// The space between the image view and the frame
        static let space: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 6.0 : 3.0
    }
    
    
    struct PaintView {
        /// The size of color button
        static let size: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 20.0 : 10.0
        /// The size of brush
        static let brushSize: [Int] = UI_USER_INTERFACE_IDIOM() == .pad ? [6,10,16,24] : [3,5,8,12]
        /// The size of brush button size
        static let brushButtonSize:  [CGFloat] = UI_USER_INTERFACE_IDIOM() == .pad ? [4,6,8,10] : [2,3,4,5]
    }
    
    
    static let puzzleSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 150, height: 150) : CGSize(width: 100, height: 100)
    
    static let finderSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 546, height: 308) : CGSize(width: 364, height: 205)
    
    static let alarmClockSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 210, height: 0) : CGSize(width: 140, height: 0)
    
    static let keyCapsSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 675, height: 300) : CGSize(width: 450, height: 200)
    
    static let notepadSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 300, height: 300) : CGSize(width: 200, height: 200)
    
    static let calculatorSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 225, height: 300) : CGSize(width: 150, height: 200)
    
    static let picassoSize: CGSize = UI_USER_INTERFACE_IDIOM() == .pad ? CGSize(width: 728, height: 410) : CGSize(width: 364, height: 205)
    
    
    static var normalSizeFont : UIFont = {
        var font = UIFont(name: "Menlo-Regular", size: UI_USER_INTERFACE_IDIOM() == .pad ? 20 : 13)!
        return font
    }()
    
    static var notePadFont: UIFont = {
        var font = UIFont(name: "Menlo-Regular", size: UI_USER_INTERFACE_IDIOM() == .pad ? 15 : 10)!
        return font
    }()
    
    

    /// The space between desktop Apps
    static let desktopAppSpace: CGFloat = UI_USER_INTERFACE_IDIOM() == .pad ? 15 : 10
}

