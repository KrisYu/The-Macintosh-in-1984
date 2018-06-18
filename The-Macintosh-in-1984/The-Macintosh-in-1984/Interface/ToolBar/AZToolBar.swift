//
//  AZToolBar.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

protocol AZToolBarDelegate {
    /// The function will be called when we click the close button on ToolBar
    func didSelectCloseMenu(_ toolBar: AZToolBar, toolButton button: AZToolButton)
}

class AZToolBar: UIView {
    
    var title: String?{
        get {
            return titleLabel.text
        }
        set {
            titleLabel.text = newValue
            setNeedsLayout()
        }
    }
    
    var titleLabel: UILabel!
    
    var closeButton: AZToolButton!
    
    var delegate: AZToolBarDelegate?
    
    var style: ContentStyle = .default{
        didSet {
            contentStyleUpdate()
        }
    }
    
    var drawLines: Bool = true {
        didSet {
            setNeedsDisplay()
            // setNeedsDisplay will call draw rect
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        
        titleLabel = UILabel()
        titleLabel.text = ""
        titleLabel.textAlignment = .center
        titleLabel.font = SystemSettings.normalSizeFont
        addSubview(titleLabel)
        
        closeButton = AZToolButton(type: .custom)
        closeButton.addTarget(self, action: #selector(buttonResponder(sender:)), for: .touchUpInside)
        addSubview(closeButton)
        
        contentStyleUpdate()
    }
    
    
    func contentStyleUpdate() {
        
        titleLabel.textColor = style == .default ? .black : .white
        titleLabel.backgroundColor = style == .default ? .white : .black
        closeButton.setBackgroundImage(UIImage(color: style == .default ? .black : .white), for: .highlighted)
        closeButton.backgroundColor = style == .default ? .white : .black
        backgroundColor = style == .default ? .clear : .black
        
        setNeedsDisplay()
    }
    
    override func layoutSubviews() {
        let buttonSize = SystemSettings.ToolBar.buttonDimension
        
        // button x offset : 10, title height ratio: 0.9
        closeButton.frame = CGRect(x: 10, y: (bounds.height - buttonSize)/2, width: buttonSize, height: buttonSize)
        closeButton.layer.borderColor = UIColor.white.cgColor
        closeButton.layer.borderWidth = 1
        
        let titleWidth = Utils.widthForView(title!, font: titleLabel.font, height: bounds.height * 0.9) + 10
        titleLabel.frame = CGRect(x: (bounds.width - titleWidth) / 2, y: 0, width: titleWidth, height: bounds.height * 0.9)
    }
    
    override func draw(_ rect: CGRect) {
        
        if style == .default {
            UIColor.black.set()
            if drawLines {
                titleLines().forEach{ $0.stroke() }
            }
        }
    }
    
    @objc func buttonResponder(sender: AZToolButton) {
        delegate?.didSelectCloseMenu(self, toolButton: sender)
    }
    
    func titleLines() -> [UIBezierPath] {
        
        var lines = [UIBezierPath]()
        
        let space = SystemSettings.ToolBar.lineSpace
        let sideSpace = SystemSettings.ToolBar.lineSideSpace
        
        // linesCount : 5
        let startingPoint = (bounds.height - space * 5) / 2
        
        for i in 0...5 {
            let path = UIBezierPath()
            let posY = CGFloat(i) * space + startingPoint
            let startX = bounds.minX + sideSpace
            let endX = bounds.maxX - sideSpace
            
            path.move(to: CGPoint(x: startX, y: posY))
            path.addLine(to: CGPoint(x: endX, y: posY))
            path.lineWidth = 1
            
            lines.append(path)
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
        path.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
        path.lineWidth = 1
        lines.append(path)
        
        return lines
    }
    
    


}
