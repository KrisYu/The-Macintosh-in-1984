//
//  FaceView.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


class FaceView: UIView {
    
    override init(frame:CGRect) {
        super.init(frame:frame)
        self.isOpaque = false
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var faceWidth: CGFloat {
        return bounds.width
    }
    
    private var faceHeight: CGFloat {
        return Ratios.HeightToWidth * faceWidth
    }
    
    private var faceCenter: CGPoint{
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    private struct Ratios {
        static let HeightToWidth: CGFloat = 0.75
        static let SpacingToWidth: CGFloat = 0.125
        static let EyeOffsetToWidth: CGFloat = 0.25
        static let EyeHeightToHeight: CGFloat = 0.1
        static let MouthHorizontalOffset: CGFloat = 0.125
        static let MouthVerticalOffset: CGFloat = 0.1
        static let NoseStartOffset: CGFloat = 0.1
        static let NoseCurveOffset: CGFloat = 0.1875
    }
    
    private enum Eye {
        case Left
        case Right
    }
    
    private func pathForEye(eye: Eye) -> UIBezierPath{
        let eyeOffset = faceWidth * Ratios.EyeOffsetToWidth
        let eyeHeight = faceHeight * Ratios.EyeHeightToHeight
        var eyeCenter = faceCenter
        eyeCenter.y -= eyeOffset
        
        switch eye {
        case .Left:
            eyeCenter.x -= eyeOffset
        case .Right:
            eyeCenter.x += eyeOffset
        }
        
        let path = UIBezierPath()
        
        path.move(to: eyeCenter)
        path.addLine(to: CGPoint(x: eyeCenter.x, y: eyeCenter.y + eyeHeight))
        path.lineWidth = 5.0
        return path
    }
    
    
    private func headPath() -> UIBezierPath {
        let rect =  UIBezierPath(rect: CGRect(x: 0,
                                              y: faceHeight * Ratios.SpacingToWidth,
                                              width: faceWidth,
                                              height: faceHeight))
        rect.lineWidth = 3.0
        return rect
    }
    
    
    
    
    override public func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        headPath().stroke()
        pathForEye(eye: .Left).stroke()
        pathForEye(eye: .Right).stroke()
        pathForMouth().stroke()
        pathForNose().stroke()
    }
    
    
    private func pathForMouth() -> UIBezierPath {
        let horizontalOffSet = faceWidth * Ratios.MouthHorizontalOffset
        let verticalOffSet = faceWidth * Ratios.MouthVerticalOffset
        
        let start = CGPoint(x: horizontalOffSet, y: faceHeight - verticalOffSet)
        let end = CGPoint(x: faceWidth - horizontalOffSet, y: faceHeight - verticalOffSet)
        
        let cp1 = CGPoint(x: start.x + faceWidth/3 , y: start.y + verticalOffSet)
        let cp2 = CGPoint(x: end.x - faceWidth/3, y: start.y + verticalOffSet)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addCurve(to: end, controlPoint1: cp1, controlPoint2: cp2)
        
        path.lineWidth = 5.0
        return path
    }
    
    private func pathForNose() -> UIBezierPath {
        
        let pt1 = CGPoint(x: faceCenter.x + faceWidth * Ratios.NoseStartOffset, y: 0)
        let pt2 = CGPoint(x: faceCenter.x - faceWidth * Ratios.NoseStartOffset / 2, y: faceHeight - faceWidth * Ratios.NoseCurveOffset)
        let pt3 = CGPoint(x: faceCenter.x + faceWidth * Ratios.NoseStartOffset / 2, y: pt2.y)
        let pt4 = CGPoint(x: pt1.x, y: bounds.maxY)
        
        let cp1 = CGPoint(x: pt2.x, y: abs(pt1.y - pt2.y)/2)
        let cp2 = CGPoint(x: faceCenter.x, y: faceHeight)
        
        let path = UIBezierPath()
        path.move(to: pt1)
        path.addQuadCurve(to: pt2, controlPoint: cp1)
        path.addLine(to: pt2)
        path.addLine(to: pt3)
        path.addQuadCurve(to: pt4, controlPoint: cp2)
        path.addLine(to: pt4)
        path.lineWidth = 5.0
        
        return path
    }
    
    
}
