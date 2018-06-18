//
//  DesktopApplication.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 6/15/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


/// Apps on desktop, such as AboutMe/Help/Pissco
protocol DesktopAppDelegate{
    
    
    /// Called when desktop application is doubled tapped.
    ///
    /// - Parameter application: The current desktop application.
    func didDoubleClick(_ application: DesktopApplication)
    
    /// Called when application is about to start dragging.
    ///
    /// - Parameter application: The current Desktop Application.
    func willStartDragging(_ application: DesktopApplication)
    
    /// Called when dragging is over.
    ///
    /// - Parameter application: The current Desktop Application.
    func didFinishDragging(_ application: DesktopApplication)
    
}

/// DesktopViewConnectionDelegate is the bridge between the MacAppDesktopView and the DesktopAppDelegate.
protocol DesktopViewConnectionDelegate{
    
    
    /// Called when desktop application is doubled tapped.
    func didDoubleClick()
    
    /// Called when application is about to start dragging.
    func willStartDragging()
    
    /// Called when dragging is over.
    func didFinishDragging()
}

/// The DesktopAppDataSource is what provides the display meta data to the Desktop Application View
protocol DesktopAppDataSource{
    
    /// The image that will be displayed as an icon
    var image: UIImage {get}
    
    /// The title/text that will be displayed on the app
    var name: String {get}
}

class DesktopApplication {
    
    /// The data source for this Desktop Application
    var app: MacApp
    
    /// The delegate for this Desktop Application
    var delegate: DesktopAppDelegate
    
    /// The Desktop View
    var macAppDesktopView: MacAppDesktopView!
    
    /// A strong reference to the current desktop, in case the desktop application needs to make some changes to it.
    var desktop: AZDesktop
    
    
    /// This function creates an instance of Desktop Application using `MacApp` instance and `AZDesktop` instance. Where the `MacApp` is used as a data source and the `AZDesktop` is used as a delegate.
    ///
    /// - Parameters:
    ///   - app: The app which we want to display on the desktop. Note that this MacApp must have a desktopIcon value.
    ///   - desktop: The AZDesktop instance on which we are display the desktop application.
    /// - Returns: The new created instance of DesktopApplication
    init(app: MacApp, on desktop: AZDesktop){
        self.app = app
        self.desktop = desktop
        self.delegate = desktop
        
        setup()
    }
    
    func setup() {
        self.macAppDesktopView = MacAppDesktopView(dataSource: self)
        self.macAppDesktopView.delegate = self
    }
    
}

/// Conform to DesktopViewConnectionDelegate
extension DesktopApplication: DesktopViewConnectionDelegate{
    func didFinishDragging() {
        delegate.didFinishDragging(self)
    }
    
    func willStartDragging() {
        delegate.willStartDragging(self)
    }
    
    func didDoubleClick(){
        delegate.didDoubleClick(self)
    }
    
}

/// Conform to DesktopAppDataSource
extension DesktopApplication: DesktopAppDataSource{
    var name: String {
        return app.windowTitle ?? ""
    }
    
    var image: UIImage {
        return app.desktopIcon!
    }
}


/// The MacAppDesktopView. It's the icon on the desktop.
class MacAppDesktopView: UIView{
    
    /// The data source
    var dataSource: DesktopAppDataSource
    
    /// The delegate
    var delegate: DesktopViewConnectionDelegate?
    
    /// The icon (as image view)
    var icon: UIImageView
    
    /// The text label
    var text: UILabel
    
    /// The transition window frame (The border the user sees when the app is being dragged)
    var transitionWindowFrame: MovingApplication
    
    /// The last location (A property used for dragging)
    var lastLocation: CGPoint = .zero
    
    /// The width of desktop applications
    static let width: CGFloat = SystemSettings.DesktopApplication.width
    
    /// The space between the image view and the frame
    static let space: CGFloat = SystemSettings.DesktopApplication.space
    
    /// The scale of the image relative to the width
    static let imageScale: CGFloat = 0.8
    
    
    /// initialization should always be done using this initailizer because a data source is needed in order to calculate the view's frame height.
    ///
    /// - Parameter dataSource: The desktop app data source which contains an image and a string.
    init(dataSource: DesktopAppDataSource) {
        //calculate needed height
        let imageWidth = MacAppDesktopView.imageScale * MacAppDesktopView.width
        let imageHeight = imageWidth
        let textWidth = MacAppDesktopView.width - MacAppDesktopView.space * 2
        let textHeight = Utils.heightForView(dataSource.name, font: SystemSettings.notePadFont, width: textWidth, numberOfLines: 0)
        let totalHeight = textHeight + imageHeight
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: MacAppDesktopView.width, height: totalHeight))


        // setup image view
        icon = UIImageView(frame: CGRect(x: (MacAppDesktopView.width - imageWidth)/2, y: 0, width: imageWidth, height: imageHeight))
        icon.image = dataSource.image
        icon.contentMode = .scaleAspectFit
        
        
        
        // setup text view
        text = UILabel(frame: CGRect(x: (MacAppDesktopView.width - textWidth)/2, y: imageWidth, width: textWidth, height: textHeight))
        text.backgroundColor = .white
        text.text = dataSource.name
        text.font = SystemSettings.notePadFont
        text.textAlignment = .center
        text.numberOfLines = 0
        
        // setup transition frame
        transitionWindowFrame = MovingApplication(textHeight: textHeight, textWidth: textWidth, totalWidth: MacAppDesktopView.width)
        transitionWindowFrame.isHidden = true
        transitionWindowFrame.backgroundColor = .clear
        self.dataSource = dataSource

        super.init(frame: rect)

        
        addSubview(icon)
        addSubview(text)
        addSubview(transitionWindowFrame)

        setup()

    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // add gesture recognizers
    func setup(){
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:))))
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        tapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(tapGesture)
    }
    
    
    /// Selector function, handles taps
    ///
    /// - Parameter sender: UITapGestureRecognizer
    @objc func handleTap(sender: UITapGestureRecognizer){
        delegate?.didDoubleClick()
    }
    
    
    /// Selector fuction, handles drag
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @objc func handlePan(sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: self.superview!)
        
        switch sender.state{
        case .began:
            transitionWindowFrame.isHidden = false
            transitionWindowFrame.frame = CGRect(origin: .zero, size: bounds.size)
            transitionWindowFrame.lastLocation = self.transitionWindowFrame.center
            delegate?.willStartDragging()
            break
        case .ended:
            transitionWindowFrame.isHidden = true
            self.center = convert(transitionWindowFrame.center, to: superview!)
            delegate?.didFinishDragging()
            return
        default:
            break
        }
        
        let point = CGPoint(x: transitionWindowFrame.lastLocation.x + translation.x ,
                            y: transitionWindowFrame.lastLocation.y + translation.y)
        transitionWindowFrame.center = point
    }
}


/// This is the class of which we create the transitioning window frame for the icon on desktop.
class MovingApplication: UIView{
    
    var lastLocation = CGPoint(x: 0, y: 0)
    
    var width: CGFloat
    
    var imageSize: CGFloat
    
    var textHeight: CGFloat
    
    var textWidth: CGFloat
    
    init(textHeight: CGFloat, textWidth: CGFloat, totalWidth: CGFloat) {
        self.textHeight = textHeight
        self.textWidth = textWidth
        self.width = totalWidth
        self.imageSize = totalWidth * MacAppDesktopView.imageScale
        
        super.init(frame: CGRect(x: 0,
                                 y: 0,
                                 width: textWidth,
                                 height: totalWidth * MacAppDesktopView.imageScale + textHeight))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        UIColor.lightGray.setStroke()
        
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: (width - imageSize)/2, y: 0))
        path.addLine(to: CGPoint(x: (width - imageSize)/2, y: imageSize))
        path.addLine(to: CGPoint(x: 0, y: imageSize))
        path.addLine(to: CGPoint(x: 0, y: textHeight + imageSize))
        path.addLine(to: CGPoint(x: textWidth, y: textHeight + imageSize))
        path.addLine(to: CGPoint(x: textWidth, y: imageSize))
        path.addLine(to: CGPoint(x: imageSize, y: imageSize))
        path.addLine(to: CGPoint(x: imageSize , y: 0))
        path.close()
        
        path.lineWidth = 1
        path.stroke()
    }
}
