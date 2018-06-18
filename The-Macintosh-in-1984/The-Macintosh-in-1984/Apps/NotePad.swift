//
//  NotePad.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 6/9/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class NotePad: MacApp {
    
    var desktopIcon: UIImage?
    
    var identifier: String? = "notepad"

    var windowTitle: String? = "Note Pad"
    
    var menuActions: [MenuAction]? = nil
    
    var currentText: [String]
    
    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    var noteCount: Int {
        return currentText.count
    }
    
    init(withIdentifier id: String = "notepad") {
        identifier = id
        currentText = Array(repeating: "", count: 8)
        currentText[0] = "Hello world"
        container = NotePadView()
        container?.backgroundColor = .clear
        (container as? NotePadView)?.delegate = self
        (container as? NotePadView)?.dataSource = self
    }
    
    var container: UIView?
    
    func reloadData() {
        (container as? NotePadView)?.updateInterface()
    }
    
    func willTerminateApplication() {
        
    }
    
    func willLaunchApplication(in view: AZDesktop, withApplication app: AZApplication) {
        
    }
    
    func didLaunchApplication(in view: AZDesktop, withApplication app: AZApplication) {
        
    }
    
    func sizeForWindow() -> CGSize {
        return SystemSettings.notepadSize
    }

}

extension NotePad: NotePadDataSource {
    func notePad(_ notepad: NotePadView, textForPageAtIndex index: Int) -> String? {
        return currentText[index]
    }
    
    func numberOfNotes(_ notepad: NotePadView) -> Int {
        return noteCount
    }
    
}

extension NotePad: NotePadDelegate{
    func notePad(_ notepad: NotePadView, didChangeTo index: Int) {
        
    }
    
    func notePad(_ notepad: NotePadView, didChangeTo text: String, atIndex index: Int) {
        self.currentText[index] = text
    }
    
    
}

protocol NotePadDelegate {
    
    /// Delegate Function, called when user changes pages.
    ///
    /// - Parameters:
    ///     - notepad: The notepad view.
    ///     - index: The new page which the notepad switched to.
    func notePad(_ notepad: NotePadView, didChangeTo index: Int)
   
    /// Delegate Function, called when user changes pages.
    ///
    /// - Parameters:
    ///     - notepad: The notepad view.
    ///     - index: The page at which the user typed.
    func notePad(_ notepad: NotePadView, didChangeTo text: String, atIndex index: Int)
}


protocol NotePadDataSource {
    
    /// Data Source Function, used to determine the amount of pages the notepad contains.
    ///
    /// - Parameters notepad: The notepad view.
    /// - Return: The number of pages for the notepad.
    func numberOfNotes(_ notepad: NotePadView) -> Int
    
    
    /// Data Source Function, used to determine the text for a certain page.
    ///
    /// - Parameters
    ///     - notepad: The notepad view.
    ///     - index: The index for which we want to specify the text.
    /// - Return: A string that will be set on the notepad at a certain page.
    func notePad(_ notepad: NotePadView, textForPageAtIndex index: Int) -> String?
    
}


class NotePadView: UIView {
    
    /// The textview which display the text.
    var textView: UITextView!
    
    /// The label which displays the current page.
    var pageLabel: UILabel!
    
    /// The delegate of the notepad.
    var delegate: NotePadDelegate?
    
    /// The datasource of the notepad.
    var dataSource: NotePadDataSource? {
        didSet{
            updateInterface()
        }
    }

    var pageCurlAnimationDuration: TimeInterval = 0.1
    
    /// The current page of the notepad
    var currentPage: Int = 0
    
    /// The aspect ratio which determines the page curl section size
    let pageCurlRatio: CGFloat = 0.1
    
    /// Computed variable to get the page count
    var pageCount: Int {
        return dataSource?.numberOfNotes(self) ?? 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        lines().forEach { $0.stroke() }
    }
    
    func lines() -> [UIBezierPath] {
        
        var arrayOfLines = [UIBezierPath]()
        
        let space: CGFloat = 2
        let startingPoint = bounds.height - 2
        
        for i in 0...1 {
            
            let y = startingPoint - space * CGFloat(i)
            let startX = bounds.minX
            let endX = bounds.maxX
            
            let path = UIBezierPath()
            path.move(to: CGPoint(x: startX, y: y))
            path.addLine(to: CGPoint(x: endX, y: y))
            path.lineWidth = 1
            arrayOfLines.append(path)
        }
        
        let specialPath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = bounds.width * pageCurlRatio
        specialPath.move(to: CGPoint(x: bounds.maxX, y: specialY))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        
        arrayOfLines.append(specialPath)
        
        return arrayOfLines
    }
    
    /// Primary setup function for the view.
    func setup()  {
        layer.masksToBounds = true
        textView = UITextView()
        textView.font = SystemSettings.notePadFont
        textView.tintColor = .black
        textView.backgroundColor = .clear
        textView.delegate = self
        
        addSubview(textView)
        
        pageLabel = UILabel()
        pageLabel.font = SystemSettings.notePadFont
        addSubview(pageLabel)
        
        
        pageLabel.translatesAutoresizingMaskIntoConstraints = false
        pageLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: pageLabel.topAnchor, constant: -8).isActive = true
        textView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        textView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
    }
    
    
    override func didMoveToSuperview() {
        // setup bottom anchor when view is moved to superview. This is done here in the setup the view frame size is still 0?
        pageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(frame.size.width * pageCurlRatio)/2).isActive = true
    }
    
    
    /// Handle Tap is a target function that handles the tap gesture recognizer that is set on the view.
    ///
    /// - Parameter sender: The Tap Gesture Recognizer
    @objc func handleTap(sender: UITapGestureRecognizer)  {
        
        /// declare function that checks if pint is within 3 points
        func sign(p1: CGPoint, p2: CGPoint, p3: CGPoint) -> CGFloat{
            
            let val1 = (p1.x - p3.x) * (p2.y - p3.y)
            let val2 = (p2.x - p3.x) * (p1.y - p3.y)
            return (val1 - val2)
        }
        
        func pointInTriangle(pt: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint) -> Bool{
            
            var b1 = false,  b2 = false, b3 = false
    
            b1 = sign(p1: pt, p2: p1, p3: p2) < 0.0;
            b2 = sign(p1: pt, p2: p2, p3: p3) < 0.0;
            b3 = sign(p1: pt, p2: p3, p3: p1) < 0.0;
            return ((b1 == b2) && (b2 == b3))
            
        }
        
        
        // touch point
        let point = sender.location(in: self)
        
        // declare the are rect of the page curl
        let scaleSize = bounds.width * pageCurlRatio
        let areaOfSelection = CGRect(x: 0,
                                     y: bounds.maxY - scaleSize - 6,
                                     width: scaleSize,
                                     height: scaleSize)

        
        // check if touch point is on page curl
        if areaOfSelection.contains(point) {
            
            let startScale: CGAffineTransform
            let endScale: CGAffineTransform
            let startCenter: CGPoint
            let endCenter: CGPoint
            let forward: Bool
            let oldIndex = currentPage
            
            
            // check if touch point is in the lower triagnle or the upper triangle
            if pointInTriangle(pt: point,
                               p1: CGPoint(x: areaOfSelection.minX, y: areaOfSelection.minY),
                               p2: CGPoint(x: areaOfSelection.minX, y: areaOfSelection.maxY),
                               p3: CGPoint(x: areaOfSelection.maxX , y: areaOfSelection.maxY)){
                // go backward
                goBackward()
                startScale = CGAffineTransform(scaleX: 0.1, y: 0.1)
                endScale = .identity
                startCenter = CGPoint(x: bounds.maxX, y: bounds.minY)
                endCenter = center
                forward = false
            } else {
                // go forward
                goForward()
                startScale = CGAffineTransform(scaleX: 0.9, y: 0.9)
                endScale = CGAffineTransform(scaleX: 0.1, y: 0.1)
                startCenter = center
                endCenter = CGPoint(x: bounds.maxX, y: bounds.minY)
                forward = true
            }
            
            // animate page curl
            let view = DummyNotePad(frame: self.frame)
            view.textView.frame = textView.frame
            view.pageLabel.frame = pageLabel.frame
            view.textView.text = dataSource?.notePad(self, textForPageAtIndex: (forward ? oldIndex : currentPage))
            view.textView.isEditable = false
            view.pageLabel.text = "\(forward ? oldIndex : currentPage) + 1"
            view.backgroundColor = .white
            addSubview(view)
            
            view.center = startCenter
            view.transform = startScale
            
            UIView.animate(withDuration: pageCurlAnimationDuration, animations: {
                view.center = endCenter
                view.transform = endScale
            }, completion: {(completion) in
                
    
                self.updateInterface()
                self.delegate?.notePad(self, didChangeTo: self.currentPage)
                view.removeFromSuperview()
            })
        }
        
    }
    
    func updateInterface() {
        pageLabel.text = "\(currentPage + 1)"
        textView.text = dataSource?.notePad(self, textForPageAtIndex: currentPage) ?? ""
    }
    
    
    /// Function updates the current page to move forward. IF the next page is "greater" than the pages in the notepad then the current page will be set to 0.
    func goForward() {
        currentPage = currentPage + 1 > pageCount - 1 ? 0 : currentPage + 1
    }
    
    /// Function updates the current page to move backward. If the next page is "less" than 0 (negative value), then the current page will be set to the max amount of pages.
    func goBackward() {
        currentPage = currentPage - 1 < 0 ? pageCount - 1 : currentPage - 1
    }
}

class DummyNotePad: UIView {
    
    /// The textview which displays the text.
    var textView: UITextView!
    
    /// The label which displays the current page.
    var pageLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        let borderLayer = CAShapeLayer()
        borderLayer.frame = bounds
        borderLayer.path = shapePath().cgPath
        layer.mask = borderLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        textView = UITextView()
        textView.font = SystemSettings.notePadFont
        textView.tintColor = .black
        textView.backgroundColor = .clear
        addSubview(textView)
        
        pageLabel = UILabel()
        pageLabel.font = SystemSettings.notePadFont
        addSubview(pageLabel)
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.white.setFill()
        shapePath().fill()
        
        UIColor.black.setStroke()
        line().stroke()
        
        let startingPoint = bounds.height - 2
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = bounds.width * pageCurlRatio
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        path.lineWidth = 1
        path.stroke()
    }
    
    
    let pageCurlRatio: CGFloat = 0.3
    let space: CGFloat = 2
    
    // get the path of the shape needed
    func shapePath() -> UIBezierPath {
        let startingPoint = bounds.height - 2
        let shapePath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = bounds.width * pageCurlRatio
        shapePath.move(to: CGPoint(x: bounds.maxX, y: specialY))
        shapePath.addLine(to: CGPoint(x: curlSize, y: specialY))
        shapePath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        shapePath.addLine(to: CGPoint(x: bounds.minX, y: bounds.minY))
        shapePath.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        shapePath.close()
        
        return shapePath
    }
    
    
    // get the lines to draw
    func line() -> UIBezierPath {
        
        let startingPoint = bounds.height - 2
        let specialPath = UIBezierPath()
        let specialY: CGFloat = startingPoint - space * 2
        let curlSize: CGFloat = bounds.width * pageCurlRatio
        specialPath.move(to: CGPoint(x: bounds.maxX, y: specialY))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        specialPath.addLine(to: CGPoint(x: 0, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY - curlSize))
        specialPath.addLine(to: CGPoint(x: curlSize, y: specialY))
        
        return specialPath
    }
    
}

extension NotePadView: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.delegate?.notePad(self, didChangeTo: textView.text, atIndex: currentPage)
    }
}
