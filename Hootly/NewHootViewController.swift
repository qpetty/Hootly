//
//  NewHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class NewHootViewController: UIViewController {
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var commentForm: CommentFormView!
    var image: UIImage?
    
    var adjustingView: UIView?
    var bottomConstraint: NSLayoutConstraint?
    
    @IBAction func closeModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        capturedImageView.image = image
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveTextFormUp:", name: UIKeyboardWillShowNotification, object: nil)
        commentForm.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        commentForm.textField.resignFirstResponder()
    }
    
    func moveTextFormUp(aNotification: NSNotification) {
        if let userInfo = aNotification.userInfo {
            
            let kbSize = userInfo[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size.height
            
            if let value = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
                for con in commentForm.superview!.constraints(){
                    if let n = con.secondItem as? CommentFormView {
                        let constraint = con as NSLayoutConstraint
                        constraint.constant = kbSize!
                    }
                    
                }
            }
            
            updateViewConstraints()
        }
    }
}