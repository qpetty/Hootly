//
//  SquareImagePickerViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class SquareImagePickerController: UIImagePickerController {
    var imageRect: NSValue?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        var view = CameraOverlayView()
        let topBarSize = 40 as CGFloat
        let bottomBarSize = 70 as CGFloat
        var width = self.view.frame.size.width
        //var height = width * (CGFloat)(4.0 / 3.0)
        var height = self.view.frame.size.height - topBarSize - bottomBarSize
        
        view.frame = CGRect(x: 0, y: topBarSize, width: width, height: height)
        cameraOverlayView = view
    }
}