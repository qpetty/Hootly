//
//  CommentFormView.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class CommentFormView: UIView {
    var nibView: UIView?
    
    @IBOutlet weak var textField: SZTextView!
    @IBOutlet weak var submitButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    func loadNib() {
        nibView = NSBundle.mainBundle().loadNibNamed("CommentFormView", owner: self, options: nil)[0] as? UIView
        self.addSubview(nibView!)
        textField.placeholder = "Hoot your Hoot!";

        submitButton.layer.backgroundColor = UIColor(red: 127/255, green: 168/255, blue: 215/255, alpha: 1.0).CGColor
        submitButton.layer.cornerRadius = 4.0
        
    }
    
    override func layoutSubviews() {
        nibView!.frame = self.bounds
    }
}
