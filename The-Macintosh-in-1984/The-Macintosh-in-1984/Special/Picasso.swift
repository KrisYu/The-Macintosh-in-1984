//
//  Picasso.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 6/17/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class Picasso: MacApp {
    
    var container: UIView? = PaintView()
    
    var desktopIcon: UIImage?
    
    var identifier: String? = "picasso"
    
    var windowTitle: String? = "Picasso"
    
    var menuActions: [MenuAction]?
    
    var contentMode: ContentStyle = .default
    
    lazy var uniqueIdentifier: String = {
        return UUID().uuidString
    }()
    
    /// Data Source function, returns the size of the container
    func sizeForWindow() -> CGSize {
        return SystemSettings.picassoSize
    }
    
    func clear() {
        (container as? PaintView)?.clear()
    }
    
    func undo() {
        let paintView = (container as? PaintView)
        paintView?.didSelectUndo(sender: paintView?.undoButton)
    }
    
    // this size is for the deskop icon size
    let size = MacAppDesktopView.width
    
    init() {
        desktopIcon = UIImage.withBezierPath(pathForIcon(), size: CGSize(width: size, height: size))
    }
    
    func pathForIcon() -> [SpecificBezierPath] {
        
        var sbpa = [SpecificBezierPath]()
        
        let radius = size/2.5
        
        let path = UIBezierPath(arcCenter: CGPoint(x: size/2,y: size/2), radius: radius, startAngle: 0.523599, endAngle: 5.75959, clockwise: true)
        let length: CGFloat = sin(1.0472) * radius
        path.addQuadCurve(to: CGPoint(x: path.currentPoint.x, y: path.currentPoint.y + length), controlPoint: CGPoint(x: size/2 + size / 8, y: size/2))
        path.close()
        sbpa.append(SpecificBezierPath(path: path, stroke: true, fill: true, strokeColor: .black, fillColor: .black))
        
        let objectSize = size/7
        let object1 = UIBezierPath(roundedRect: CGRect(x: size/2 + size / 10, y: size/4.2, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object1, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object2 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 8, y: size/2 - size / 3, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object2, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object3 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 3, y: size/2 - size / 8, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object3, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object4 = UIBezierPath(roundedRect: CGRect(x: size/2 - size / 4, y: size/2 + size/7, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object4, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        let object5 = UIBezierPath(roundedRect: CGRect(x: size/2 + size / 10, y: size/2 + size/10, width: objectSize, height: objectSize), cornerRadius: objectSize/2)
        sbpa.append(SpecificBezierPath(path: object5, stroke: false, fill: true, strokeColor: .clear, fillColor: .white))
        
        return sbpa
    }
    
}

class PaintView: UIView {
    
    var canvas: CanvasView!
    
    var colorsView: UIStackView!
    
    var colors: [UIColor] = [#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1),#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1),#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),#colorLiteral(red: 1, green: 0.3005838394, blue: 0.2565174997, alpha: 1),#colorLiteral(red: 1, green: 0.4863265157, blue: 0, alpha: 1),#colorLiteral(red: 1, green: 0.8288275599, blue: 0, alpha: 1),#colorLiteral(red: 0.4497856498, green: 0.9784941077, blue: 0, alpha: 1),#colorLiteral(red: 0, green: 0.8252056837, blue: 0.664467752, alpha: 1),#colorLiteral(red: 0, green: 0.8362106681, blue: 1, alpha: 1),#colorLiteral(red: 0, green: 0.3225687146, blue: 1, alpha: 1),#colorLiteral(red: 0.482165277, green: 0.1738786995, blue: 0.8384277225, alpha: 1),#colorLiteral(red: 0.8474548459, green: 0.2363488376, blue: 1, alpha: 1)]
    
    var undoButton: UIButton!
    
    var brushSizeStackView: UIStackView!
    
    func clear(){
        canvas?.clear()
        undoButton?.isEnabled = false
    }
    
    convenience init(){
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup(){
        
        let settingsView = UIView()
        
        undoButton = UIButton(type: .system)
        undoButton.tintColor = .black
        undoButton.setTitle("Undo", for: [])
        undoButton.titleLabel?.font = SystemSettings.normalSizeFont
        undoButton.addTarget(self, action: #selector(didSelectUndo(sender:)), for: .touchUpInside)
        undoButton.isEnabled = false
        
        canvas = CanvasView()
        canvas.delegate = self
        canvas.backgroundColor = .clear
        
        colorsView = UIStackView()
        colorsView.axis = .vertical
        colorsView.distribution = .fillEqually
        
        brushSizeStackView = UIStackView()
        brushSizeStackView.axis = .horizontal
        brushSizeStackView.distribution = .fillEqually
        
        addSubview(canvas)
        addSubview(colorsView)
        addSubview(settingsView)
        
        colorsView.translatesAutoresizingMaskIntoConstraints = false
        colorsView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        colorsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        colorsView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        colorsView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.05).isActive = true
        
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        settingsView.heightAnchor.constraint(equalTo: colorsView.widthAnchor, multiplier: 1.0).isActive = true
        settingsView.rightAnchor.constraint(equalTo: colorsView.leftAnchor).isActive = true
        settingsView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        settingsView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        settingsView.addSubview(undoButton)
        settingsView.addSubview(brushSizeStackView)
        
        undoButton.translatesAutoresizingMaskIntoConstraints = false
        undoButton.topAnchor.constraint(equalTo: settingsView.topAnchor,constant: 4).isActive = true
        undoButton.leftAnchor.constraint(equalTo: settingsView.leftAnchor).isActive = true
        undoButton.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor,constant: -4).isActive = true
        undoButton.widthAnchor.constraint(equalTo: settingsView.widthAnchor, multiplier: 0.5).isActive = true
        
        brushSizeStackView.translatesAutoresizingMaskIntoConstraints = false
        brushSizeStackView.leftAnchor.constraint(equalTo: undoButton.rightAnchor).isActive = true
        brushSizeStackView.topAnchor.constraint(equalTo: settingsView.topAnchor).isActive = true
        brushSizeStackView.rightAnchor.constraint(equalTo: settingsView.rightAnchor).isActive = true
        brushSizeStackView.bottomAnchor.constraint(equalTo: settingsView.bottomAnchor).isActive = true
        
        canvas.translatesAutoresizingMaskIntoConstraints = false
        canvas.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        canvas.topAnchor.constraint(equalTo: topAnchor).isActive = true
        canvas.bottomAnchor.constraint(equalTo: settingsView.topAnchor).isActive = true
        canvas.rightAnchor.constraint(equalTo: colorsView.leftAnchor).isActive = true
        
        for i in 0..<colors.count{
            let button = colorButton(withColor: colors[i])
            button.tag = i
            button.addTarget(self, action: #selector(didSelectColor(sender:)), for: .touchUpInside)
            colorsView.addArrangedSubview(button)
        }
        
        let sizes: [CGFloat] = SystemSettings.PaintView.brushButtonSize
        let actualSizes = SystemSettings.PaintView.brushSize
        for i in 0..<4{
            let button = brushSizeButton(withSize: sizes[i])
            button.addTarget(self, action: #selector(didSelectBrushSize(sender:)), for: .touchUpInside)
            button.tag = actualSizes[i]
            brushSizeStackView.addArrangedSubview(button)
        }
        
        (colorsView.arrangedSubviews.first as? UIButton)?.isSelected = true
        (brushSizeStackView.arrangedSubviews.first as? UIButton)?.isSelected = true
    }
    
    @objc func didSelectBrushSize(sender: UIButton){
        
        brushSizeStackView.arrangedSubviews.forEach { ($0 as? UIButton)?.isSelected = false }
        
        sender.isSelected = true
        let size = CGFloat(sender.tag)
        canvas.lineWidth = size
    }
    
    @objc func didSelectColor(sender: UIButton){
        colorsView.arrangedSubviews.forEach { ($0 as? UIButton)?.isSelected = false }
        
        sender.isSelected = true
        
        canvas.currentColor = colors[sender.tag]
    }
    
    @objc func didSelectUndo(sender: UIButton?){
        canvas.undo()
        sender?.isEnabled = canvas.canUndo
    }
    
    func colorButton(withColor color: UIColor)->UIButton{
        let buttonSize = SystemSettings.PaintView.size
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize), cornerRadius: 2)
        path.lineWidth = 0.4
        let sbp = SpecificBezierPath(path: path, stroke: true, fill: true, strokeColor: .black, fillColor: color)
        let image = UIImage.withBezierPath([sbp], size: CGSize(width: buttonSize, height: buttonSize))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: [])
        button.setBackgroundImage(UIImage(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1996291893)), for: .selected)
        
        return button
    }
    
    func brushSizeButton(withSize size: CGFloat)-> UIButton{
        //2,3,4,5
        let path = UIBezierPath(roundedRect: CGRect(x: (10-size)/2, y: (10-size)/2, width: size, height: size), cornerRadius: size/2)
        let sbp = SpecificBezierPath(path: path, stroke: false, fill: true, strokeColor: .black, fillColor: .black)
        let image = UIImage.withBezierPath([sbp], size: CGSize(width: 10, height: 10))
        
        let button = UIButton(type: .custom)
        button.setImage(image, for: [])
        button.setBackgroundImage(UIImage(color: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.1996291893)), for: .selected)
        
        return button
    }
}

extension PaintView: CanvasDelegate{
    func didDrawIn(_ canvasView: CanvasView){
        undoButton?.isEnabled = true
    }
}

protocol CanvasDelegate{
    func didDrawIn(_ canvasView: CanvasView)
}

/// We draw on this CanvasView
class CanvasView: UIView{
    
    struct CustomPath{
        var color: UIColor
        var width: CGFloat
        var path: UIBezierPath
    }
    
    var currentColor: UIColor = .black
    
    var lineWidth: CGFloat = 3
    
    var delegate: CanvasDelegate?
    
    var canUndo: Bool{
        return paths.count > 0
    }
    
    func clear(){
        paths.removeAll()
        setNeedsDisplay()
    }
    
    func undo(){
        if paths.count > 0 {
            paths.removeLast()
            setNeedsDisplay()
        }
    }
    
    private var currentPath: UIBezierPath!
    private var paths = [CustomPath]()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath = UIBezierPath()
        currentPath.lineWidth = lineWidth
        currentPath.move(to: touches.first!.location(in: self))
        paths.append(CustomPath(color: currentColor, width: lineWidth, path: currentPath))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentPath.addLine(to: touches.first!.location(in: self))
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didDrawIn(self)
    }
    
    
    override func draw(_ rect: CGRect) {
        for customPath in paths{
            customPath.color.setStroke()
            customPath.path.stroke()
        }
    }
}
