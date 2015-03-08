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

@IBDesignable
class CommentFormView: NibDesignable, UITextViewDelegate {
    var active = false
    
    private let characterLimit = 140
    
    @IBOutlet weak var textField: SZTextView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var statusSizeToRightEdge: NSLayoutConstraint!
    weak var delegate: CommentFormProtocol?
    
    @IBInspectable var borderColor: UIColor = UIColor(red: 127/255, green: 168/255, blue: 215/255, alpha: 1.0) {
        didSet {
            submitButton.layer.backgroundColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            submitButton.layer.cornerRadius = cornerRadius
            submitButton.layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var placeholderText: String = "Hoot your Hoot!"{
        didSet {
            textField.placeholder = placeholderText
        }
    }
    
    @IBInspectable var initialStatus: Int = 0 {
        didSet {
            status = NSMakeRange(initialStatus, 100)
        }
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
