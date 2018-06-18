//
//  OSBootWindow.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


/// This boot window has a Finder FaceView, ProgressBar, and text
class AZBootWindow: UIView {
    
    var messageLabel: UILabel!
    var titleLabel: UILabel!
    var macOSFace: FaceView!
    var progressView: ProgressBarView!
    
    
    /// Animate the progress bar.
    ///
    /// - Parameters:
    ///   - duration: time. (but not very accurate)
    ///   - completion: when finished, execute this closure.
    func animateProgress(duration: TimeInterval, completion: (()->Void)?){
        progressView.animateProgress(duration: duration, completion: completion)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var width: CGFloat {
        return bounds.width
    }
    
    private var height: CGFloat {
        return bounds.height
    }
    
    private func setup() {
        
        let faceWidth = height / 4
        let faceHeight = faceWidth
        macOSFace = FaceView(frame: CGRect(x: width / 2 - faceWidth / 2,
                                           y: height / 6,
                                           width: faceWidth,
                                           height: faceHeight))
        addSubview(macOSFace)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont(name: "Marion-Regular", size: 50)
        titleLabel.text = "Mac OS"
        titleLabel.sizeToFit()
        titleLabel.center = center
        addSubview(titleLabel)
        
        let innerRect = RectView(frame: CGRect(x: width / 2 - width * Ratios.innerRectWidth / 2,
                                               y: height / 10,
                                               width: width * Ratios.innerRectWidth,
                                               height: height * Ratios.innerRectHeight))
        addSubview(innerRect)
        
        
        messageLabel = UILabel()
        messageLabel.font = UIFont.boldSystemFont(ofSize: 15)
        messageLabel.text = "Starting up..."
        messageLabel.sizeToFit()
        messageLabel.center.x = center.x
        messageLabel.center.y = height * Ratios.messageLabelOffset
        addSubview(messageLabel)
        
        progressView = ProgressBarView(frame: CGRect(x: width / 2 - width * Ratios.progressViewWidth/2 ,
                                                     y: height - height / 6,
                                                     width: width * Ratios.progressViewWidth,
                                                     height: 20))
        
        addSubview(progressView)
        backgroundColor = .white
    }
    
    
    
    
    private struct Ratios {
        static let faceViewWidth: CGFloat = 0.25
        static let faceViewVerticalOffset: CGFloat = 0.18
        static let messageLabelOffset: CGFloat = 0.75
        static let innerRectWidth: CGFloat = 0.6
        static let innerRectHeight: CGFloat = 0.5
        static let progressViewWidth: CGFloat = 0.4
    }
    
}
