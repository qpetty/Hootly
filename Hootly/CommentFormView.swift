//
//  CommentFormView.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

protocol CommentFormProtocol: class {
    func commentToSubmit(comment: String)
    func exitWithoutComment()
}

class CommentFormView: UIView, UITextViewDelegate {
    var nibView: UIView?
    var active: Bool
    
    private let characterLimit = 140
    
    @IBOutlet weak var textField: SZTextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var statusSizeToRightEdge: NSLayoutConstraint!
    weak var delegate: CommentFormProtocol?
    
    required init(coder aDecoder: NSCoder) {
        active = false
        super.init(coder: aDecoder)
        loadNib()
    }
    
    override init(frame: CGRect) {
        active = false
        super.init(frame: frame)
        loadNib()
    }
    
    func loadNib() {
        nibView = NSBundle.mainBundle().loadNibNamed("CommentFormView", owner: self, options: nil)[0] as? UIView
        self.addSubview(nibView!)
        textField.placeholder = "Hoot your Hoot!";

        submitButton.layer.backgroundColor = UIColor(red: 127/255, green: 168/255, blue: 215/255, alpha: 1.0).CGColor
        submitButton.layer.cornerRadius = 4.0
        status = NSMakeRange(0, 100)
    }
    
    override func layoutSubviews() {
        nibView!.frame = self.bounds
    }
    
    var status: NSRange {
        get {
            let length = frame.size.width
            let filled = (length - statusSizeToRightEdge.constant) / length * 100
            return NSMakeRange(Int(filled), 100)
        }
        set(newStatus) {
            let status = (1.0 - (Float(newStatus.location) / Float(newStatus.length))) * Float(frame.size.width)
            statusSizeToRightEdge.constant = CGFloat(status)
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.layoutIfNeeded()
            })
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let len = countElements(textView.text) - range.length + countElements(text)
        
        if len > characterLimit {
            return false
        } else if len > 0 {
            active = true
        } else {
            active = false
        }

        return true
    }
    
    @IBAction func submitComment(sender: AnyObject) {
        if active {
            delegate?.commentToSubmit(textField.text)
        } else {
            delegate?.exitWithoutComment()
        }
        textField.text = ""
        active = false
    }
}
