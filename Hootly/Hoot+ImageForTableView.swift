//
//  Hoot+ImageForTableView.swift
//  Hootly
//
//  Created by Quinton Petty on 2/17/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

extension Hoot {

    func fetchImage(fetchedImage: (UIImage) -> (Void)) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), { () -> Void in
            self.loadImageFromDiskOrNetwork(fetchedImage)
        })
        
    }
    
    private func loadImageFromDiskOrNetwork(fetchedImage: (UIImage) -> (Void)) {
        
        if let imageURL = self.photoURL as? NSURL {
            
            // Check to see if the url corresponds to an image on disk or in the network
            if imageURL.fileURL == false {
                let documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
                let imageSubdirectory = documentsDirectory.stringByAppendingPathComponent("Images")
                
                //Check if the image subdirectory has been made, if it hasnt, lets make it!
                let imageDirectoryisPresent = NSFileManager.defaultManager().fileExistsAtPath(imageSubdirectory)
                if imageDirectoryisPresent == false {
                    NSFileManager.defaultManager().createDirectoryAtPath(imageSubdirectory, withIntermediateDirectories: true, attributes: nil, error: nil)
                }
                
                //Create the image file
                NSLog("Fetching Image from network \(imageURL)")
                if let imageData = NSData(contentsOfURL: imageURL) {
                    if let image = UIImage(data: imageData) {
                        //return image
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            fetchedImage(image)
                        })
                        
                        //Write to disk
                        let photoURL = imageSubdirectory.stringByAppendingPathComponent(imageURL.lastPathComponent!)
                        let written = NSFileManager.defaultManager().createFileAtPath(photoURL, contents: imageData, attributes: nil)
                        if written == true {
                            
                            if let writtenPhotoURL = NSURL(fileURLWithPath: photoURL) {
                                self.photoURL = writtenPhotoURL
                                self.managedObjectContext?.save(nil)
                            } else {
                                println("strangly could not get a URL corresponding to \(photoURL)")
                            }

                        } else {
                            println("could not write: \(photoURL)")
                        }
                    }
                }
            } else {
                NSLog("Fetching Image from disk \(imageURL)")
                if let urlContents = NSData(contentsOfURL: imageURL) {
                    if let image = UIImage(data: urlContents) {
                        dispatch_async(dispatch_get_main_queue(), { () -> Void in
                            fetchedImage(image)
                        })
                    }
                }
            }
        }
        
    }
}