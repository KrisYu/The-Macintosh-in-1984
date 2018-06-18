//
//  RectView.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit

class RectView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        UIColor.black.setStroke()
        UIBezierPath(rect: rect).stroke()
    }
    
}

