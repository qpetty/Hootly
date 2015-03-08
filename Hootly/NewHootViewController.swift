//
//  NewHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class NewHootViewController: UIViewController, CommentFormProtocol, NSURLConnectionDataDelegate {
    @IBOutlet weak var capturedImageView: UIImageView!
    @IBOutlet weak var commentForm: CommentFormView!
    @IBOutlet weak var keyboardHeight: NSLayoutConstraint!
    
    var image: UIImage?
    var adjustingView: UIView?
    var bottomConstraint: NSLayoutConstraint?
    
    @IBAction func closeModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        capturedImageView.image = image
        commentForm.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveTextFormUp:", name: UIKeyboardWillShowNotification, object: nil)
        commentForm.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        commentForm.textField.resignFirstResponder()
    }
    
    func commentToSubmit(comment: String) {
        HootAPIToCoreData.postHoot(image!, comment: comment, delegate: self)
    }
    
    func exitWithoutComment() {
        return
    }
    
    func moveTextFormUp(aNotification: NSNotification) {
        if let userInfo = aNotification.userInfo {
            
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as NSValue).CGRectValue().size.height
            keyboardHeight.constant = kbSize
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    // MARK: - NSURLConnectionDataDelegate Methods
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func connection(connection: NSURLConnection, didFailWithError error: NSError) {
        NSLog("couldnt submit this hoot")
    }
    
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        commentForm.status = NSMakeRange(totalBytesWritten, totalBytesExpectedToWrite)
    }
}