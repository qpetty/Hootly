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
    
    let maxImageSize = 640 as CGFloat
    
    @IBAction func closeModal(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        capturedImageView.image = image
        commentForm.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "moveTextFormUp:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardAway:", name: UIKeyboardWillHideNotification, object: nil)
        commentForm.textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(animated: Bool) {
        commentForm.textField.resignFirstResponder()
    }
    
    func commentToSubmit(comment: String) {
        if image?.size.height >= maxImageSize || image?.size.height >= maxImageSize {
            let newSize = CGSize(width: maxImageSize, height: maxImageSize)
            
            UIGraphicsBeginImageContext(newSize)
            image!.drawInRect(CGRect(x: 0, y: 0, width: newSize.width, height: newSize.width))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        if HootAPIToCoreData.postHoot(image!, comment: comment, delegate: self) == true {
            commentForm.enabled = false
        } else {
            let client = FFAlertClient.sharedAlertClientWithMessage("Cannot either connect to the internet or get your location. Please try again.", cancelButtonTitle: "OK")
            client.showWithCompletion { (isCanceled) -> Void in
                //Dismissed
            }
        }
    }
    
    func exitWithoutComment() {
        return
    }
    
    func moveTextFormUp(aNotification: NSNotification) {
        if let userInfo = aNotification.userInfo {
            let kbSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size.height
            keyboardHeight.constant = kbSize
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func keyboardAway(aNotification: NSNotification) {
        
        if let info = aNotification.userInfo {
            
            keyboardHeight.constant = 0
            
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
        let client = FFAlertClient.sharedAlertClientWithMessage("Error occured while uploading hoot. Please try again.", cancelButtonTitle: "OK")
        client.showWithCompletion { (isCanceled) -> Void in
            //Dismissed
        }
        NSLog("Error: \(error) uploading hoot")
        commentForm.enabled = true
    }
    
    func connection(connection: NSURLConnection, didSendBodyData bytesWritten: Int, totalBytesWritten: Int, totalBytesExpectedToWrite: Int) {
        commentForm.status = NSMakeRange(totalBytesWritten, totalBytesExpectedToWrite)
    }
}