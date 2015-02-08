//
//  CameraOverlayView.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class CameraOverlayView: UIView {
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        
        CGContextBeginPath(context)
        
        //make all black
        
        let background = CGRectMake(0,0,frame.size.width,frame.size.height);
        UIColor.blueColor().setFill()
        CGContextAddRect(context, background);
        
        //make box
        
        UIColor.blackColor().setFill()
        
        let border = 1.0 as CGFloat;
        let verticalOffset = (frame.size.height - frame.size.width) / (CGFloat)(2.0)
        let square = CGRectMake(border * 0.5,
                                border * 0.5 + verticalOffset,
                                frame.size.width - border,
                                frame.size.width - border);
        
        CGContextAddRect(context, square)
        
        CGContextEOFillPath(context)
    }
    
    override func layoutSubviews() {
        backgroundColor = UIColor.clearColor()
    }
}