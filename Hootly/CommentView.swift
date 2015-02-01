//
//  CommentView.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class CommentView: UIView {
    var nibView: UIView?
    
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var time: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }
    
    func loadNib() {
        nibView = NSBundle.mainBundle().loadNibNamed("CommentView", owner: self, options: nil)[0] as? UIView
        self.addSubview(nibView!)
    }
    
    override func layoutSubviews() {
        nibView!.frame = self.bounds
    }
}