//
//  NewHootViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 2/8/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class NewHootViewController: UIViewController, CommentFormProtocol {
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
        
        var postBody = NSMutableData()
        postBody.mp_setInteger(6, forKey: "user_id")
        postBody.mp_setFloat(5, forKey: "lat")
        postBody.mp_setFloat(5, forKey: "long")
        postBody.mp_setString(comment, forKey: "hoot_text")
        postBody.mp_setJPEGImage(image, withQuality: 1.0, forKey: "image")
        
        postBody.mp_prepareForRequest()
        
        if let hostString = NSBundle.mainBundle().objectForInfoDictionaryKey("Production URL") as? String {
            var host = NSURL(string: hostString)!
            var url = NSURL(string: "hoots", relativeToURL: host)!
            
            println("sending \(comment) to \(url.absoluteString)")
            
            var request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "POST"
            
            request.setValue(postBody.KIMultipartContentType, forHTTPHeaderField: "Content-Type")
            postBody.mp_prepareForRequest()
            request.HTTPBody = postBody
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { (response, data, error) -> Void in
                if (error != nil) {
                    NSLog("%@", error)
                    return
                }
                
                println("response: \(response)")
                
                if let dataText = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    println("posted! response data: \(dataText)")
                }
                
                self.dismissViewControllerAnimated(true, completion: nil)
            })
        } else {
            println("could not construct URL in getHoots()")
            return
        }
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
}