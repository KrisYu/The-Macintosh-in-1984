//
//  Utils.swift
//  The-Macintosh-in-1984
//
//  Created by Xue Yu on 5/26/18.
//  Copyright © 2018 XueYu. All rights reserved.
//

import UIKit


struct Utils {
    
    static func widthForView(_ text: String, font: UIFont, height: CGFloat) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: CGFloat.greatestFiniteMagnitude, height: height))
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.textAlignment = .center
        label.sizeToFit()
        return label.frame.width
    }
    
    
    static func heightForView(_ text: String, font: UIFont, width: CGFloat, numberOfLines: Int = 1) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = numberOfLines
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        label.textAlignment = .center
        label.sizeToFit()
        return label.frame.height
    }
    
    static func currentTime() -> String{
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: Date())
    }
    
    static func extenedTime() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.dateStyle = .none
        timeFormatter.timeStyle = .medium
        return timeFormatter.string(from: Date())
    }
    
}

struct SpecificBezierPath {
    var path: UIBezierPath
    var stroke: Bool
    var fill: Bool
    var strokeColor : UIColor = .black
    var fillColor: UIColor = .clear
}

extension UIImage {
    
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
    
    static func withBezierPath(_ paths: [SpecificBezierPath],
                        size: CGSize,
                        scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        
        var image: UIImage?
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        for item in paths {
            if item.fill{
                item.fillColor.setFill()
                item.path.fill()
            }
            if item.stroke{
                item.strokeColor.setStroke()
                item.path.stroke()
            }
        }
    
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    
    }
}



extension CGSize {
    static func + (left: CGSize, right: CGSize) -> CGSize{
        return CGSize(width: left.width + right.width, height: left.height + right.height)
    }
}
