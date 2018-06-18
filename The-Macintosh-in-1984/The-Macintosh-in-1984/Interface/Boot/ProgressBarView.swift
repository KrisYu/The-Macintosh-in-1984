//
//  ProgressBarView.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class ProgressBarView : UIView {
    
    private var line = UIBezierPath()
    private var shapeLayer = CAShapeLayer()
    private var progressLayer = CAShapeLayer()
    private var timer: Timer?
    
    private var progress: Double = 0.1 {
        didSet(newValue){
            progressLayer.strokeEnd = CGFloat(newValue)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        
        createLine()
        
        shapeLayer.path = line.cgPath
        shapeLayer.lineWidth = bounds.height
        shapeLayer.strokeColor = UIColor.lightGray.cgColor
        
        progressLayer.path = line.cgPath
        progressLayer.lineWidth = bounds.height
        progressLayer.strokeColor = UIColor.darkGray.cgColor
        progressLayer.strokeEnd = 0.1
        

        
        
        self.layer.addSublayer(shapeLayer)
        self.layer.addSublayer(progressLayer)
    }
    
    
    private func createLine(){
        line.move(to: CGPoint(x: 0, y:  bounds.midY))
        line.addLine(to: CGPoint(x: bounds.maxX, y: bounds.midY))
    }
    
    
    func animateProgress(duration:TimeInterval, completion: (()->Void)?) {
        
        let progressIncrement = 1.0 / duration
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            
            if self.progress >= 1.0 {
                self.timer?.invalidate()
                completion?()
                return
            }
            
            self.progress += progressIncrement
        }
    }
    
    

}
