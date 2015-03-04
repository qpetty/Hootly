//
//  LocationPrompt.swift
//  Hootly
//
//  Created by Krisna Sorathia on 2/15/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class LocationPrompt: UIViewController {
    @IBOutlet weak var acceptLocationButton: UIButton!
    @IBOutlet weak var declineLocationButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        acceptLocationButton.layer.backgroundColor = UIColor.whiteColor().CGColor
        acceptLocationButton.layer.cornerRadius = 4.0
        
        declineLocationButton.layer.borderWidth = 1.0
        declineLocationButton.layer.cornerRadius = 4.0
        declineLocationButton.layer.borderColor = UIColor.whiteColor().CGColor
    }
    @IBAction func buttonPressed(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let defaults = NSUserDefaults.standardUserDefaults()
        let userIDData = NSKeyedArchiver.archivedDataWithRootObject(NSNumber(bool: true))
        
        defaults.setObject(userIDData, forKey: appDelegate.locationScreenShown)
        defaults.synchronize()
        self.performSegueWithIdentifier("EnterApp", sender: sender)
    }
}
