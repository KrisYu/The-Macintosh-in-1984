//
//  AZApplication.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//


import UIKit

protocol AZApplicationDelegate {
    
    
    /// Delegate function called when window is about to be dragged.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - container: The application's view.
    func application(_ application: AZApplication, willStartDraggingContainer container: UIView)
    
    
    /// Delegate function called when window has finished dragging.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - container: The application's view.
    func application(_ application: AZApplication, didFinishDraggingContainer container: UIView)
    
    /// Delegate function called when user taps the toolBar of the AZApplication.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - toolBar: The toolBar that was tapped.
    ///   - point: The location of the tap.
    func application(_ application: AZApplication, didTapToolBar toolBar: AZToolBar, atPoint point: CGPoint)
    
    
    ///
    ///
    /// -Parameters:
    ///   - applicationWindow: The current application window.
    ///   - panel: The window panel view instance that was tapped.
    
    
    /// Delegate function called when user clicks the "close" button in the toolbar.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - toolBar: The toolBar that was tapped.
    func application(_ application: AZApplication, didCloseWindowWithToolBar toolBar: AZToolBar)
    
    
    /// Delegate function called after user has finished dragging. note that `point` parameter is an `inout`. This is to allow the class which conforms to this delegate the point to modify the point incase the point that was given isn't good.
    ///
    /// - Parameters:
    ///   - application: The current application window.
    ///   - point: The point the user dragged the toolbar to.
    /// - Returns: return true to allow the movement of the window to the point, and false to ignore the movement.
    func application(_ application: AZApplication, canMoveToPoint point: inout CGPoint) -> Bool
    
}


class AZApplication: UIView {
    
    /// we use this to deal with drag
    private var lastLocation = CGPoint.zero
    
    

    var delegate: AZApplicationDelegate
    
    var dataSource: MacApp
    
    
    /// hold the MacApp's container.
    var container: UIView
    
    var windowTitle: String?
    
    var containerSize: CGSize {
        return dataSource.sizeForWindow()
    }
    
    
    var toolBar: AZToolBar
    
    let toolBarHeight: CGFloat
    
    /// show a gray moving frame when we move the AZApplication
    var transitionWindowFrame: MovingWindow
    
    
    /// AZApplication contains: container - Application lives in, toolBar, transitionWindowFrame
    ///
    /// - Parameters:
    ///   - delegate: AZApplicationDelegate
    ///   - dataSource: MacApp
    init(delegate: AZApplicationDelegate, dataSource: MacApp) {
       
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.toolBar = AZToolBar()
        self.toolBarHeight = SystemSettings.ToolBar.height
        self.container = UIView()
        
        self.transitionWindowFrame = MovingWindow()
        super.init(frame: .zero)
        
        
        backgroundColor = .white
        
        // set toolBar style according to MacApp
        toolBar.style = dataSource.contentMode
        toolBar.delegate = self
        addSubview(toolBar)
        
        container.backgroundColor = .clear
        addSubview(container)
        
        windowTitle = dataSource.windowTitle
        toolBar.title = windowTitle
        transitionWindowFrame.isHidden = true
        transitionWindowFrame.backgroundColor = .clear
        addSubview(transitionWindowFrame)
        

        setup()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    /// Add gesture recognizer in setup
    func setup() {
        
        // add pan gesture to toolbar, thus we can drag
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        toolBar.addGestureRecognizer(panRecognizer)
        
        let tapGesutre = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        toolBar.addGestureRecognizer(tapGesutre)
        
    }
    
    
    
    /// target - action function, called when user tap the Application's toolBar. all opened menus will be closed and the application will bring to front.
    ///
    /// - Parameter sender: UITapGestureRecognizer
    @objc func handleTap(sender: UITapGestureRecognizer){
        delegate.application(self, didTapToolBar: toolBar, atPoint: sender.location(in: toolBar))
    }
    
    
    
    /// We use pan gesture to drag
    ///
    /// - Parameter sender: UIPanGestureRecognizer
    @objc func handlePan(sender: UIPanGestureRecognizer) {
        
        if dataSource.shouldDragApplication == false {
            return
        }
        
        let translation = sender.translation(in: self.superview!)
        
        switch sender.state {
        case .began:
            // when try to move application, the movingFrame will not hide anymore
            transitionWindowFrame.isHidden = false
            transitionWindowFrame.frame = CGRect(origin: .zero, size: bounds.size)
            transitionWindowFrame.lastLocation = transitionWindowFrame.center
           
            delegate.application(self, willStartDraggingContainer: container)
            dataSource.macApp(self, willStartDraggingContainer: container)
        case .ended:
            
            transitionWindowFrame.isHidden = true
            
            var point = convert(transitionWindowFrame.center, to: superview!)
            
            if delegate.application(self, canMoveToPoint: &point) {
                self.center = point
            }
            
            delegate.application(self, didFinishDraggingContainer: container)
            dataSource.macApp(self, didFinishDraggingContainer: container)
            return
        default:
            break
        }
        
        let point = CGPoint(x: transitionWindowFrame.lastLocation.x + translation.x, y: transitionWindowFrame.lastLocation.y + translation.y)
        transitionWindowFrame.layer.shadowOpacity = 0
        transitionWindowFrame.center = point
    }
    
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 5
        layer.cornerRadius = 2
        
        transitionWindowFrame.bounds = CGRect(origin: .zero, size: bounds.size)
        frame.size = CGSize(width: containerSize.width , height: containerSize.height + toolBarHeight)
        toolBar.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: toolBarHeight)
        container.frame = CGRect(x: 0, y: toolBar.bounds.size.height, width: containerSize.width, height: containerSize.height)
        
    }
    
    
    // donot know why, but without this method our Application will load to the cetner/ but the top-left corner will be at the center of the AZDesktop
    override func didMoveToSuperview() {
        toolBar.frame = CGRect(x: 0, y: 0, width: containerSize.width, height: toolBarHeight)
        toolBar.setNeedsLayout()
        container.frame = CGRect(x: 0, y: toolBar.bounds.size.height, width: containerSize.width, height: containerSize.height)
        // self.frame
        frame.size = CGSize(width: containerSize.width, height: containerSize.height + toolBarHeight)

        // we're doing the set up of add MacApp's container(its 'real' view) to the container view we just created
        // if we don't put this in this didMoveToSuperview, the finder and about App will only show the view once.
        // the container could be nil?
        if let view = dataSource.container {
            view.frame = container.bounds
            container.addSubview(view)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
            view.leftAnchor.constraint(equalTo: container.leftAnchor).isActive = true
            view.rightAnchor.constraint(equalTo: container.rightAnchor).isActive = true
        }
        
    }
    
    /// close Application, tell dataSource and delegate it's closed, remove it from superview
    func close()  {
        self.dataSource.willTerminateApplication()
        self.delegate.application(self, didCloseWindowWithToolBar: toolBar)
        self.removeFromSuperview()
    }
    
    
    override var description: String {
        // print the pointer address
        return String(describing: Unmanaged.passUnretained(self).toOpaque())
    }
}


/// MovingWindow gray Frame
class MovingWindow: UIView {
    
    
    /// We use this to memorize the location of Application
    var lastLocation = CGPoint.zero
    
    
    override func draw(_ rect: CGRect) {
        UIColor.gray.setStroke()
    
        let path = UIBezierPath(rect: rect)
        path.lineWidth = 4
        path.stroke()
    }
}


extension AZApplication: AZToolBarDelegate {
    func didSelectCloseMenu(_ toolBar: AZToolBar, toolButton button: AZToolButton) {
        close()
    }
}

