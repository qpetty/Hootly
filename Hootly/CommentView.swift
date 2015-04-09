//
//  CommentView.swift
//  Hootly
//
//  Created by Quinton Petty on 1/31/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class CommentView: NibDesignable {
    var nibView: UIView?
    var hoot: Hoot?
    var hootComment: HootComment?
    
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var replies: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var upVoteButton: UIButton!
    @IBOutlet weak var downVoteButton: UIButton!
    @IBOutlet weak var repliesImage: UIImageView!
    
    @IBAction func upVoteButtonDidPress(sender: AnyObject) {
        if hoot != nil {
            HootAPIToCoreData.postHootUpVote(hoot!.id.integerValue, completed: { (success) -> (Void) in
                return
            })
        } else if hootComment != nil {
            HootAPIToCoreData.postCommentUpVote(hootComment!.id.integerValue, completed: { (success) -> (Void) in
                return
            })
        }
        
        upVoteButton.transform = CGAffineTransformMakeTranslation(0, -5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: nil,
            animations: {
                self.upVoteButton.transform = CGAffineTransformMakeTranslation(0, 0)
                self.setVoted(1)

                if self.hoot != nil {
                    self.hoot!.voted = 1
                    self.hoot!.rating = self.hoot!.rating.integerValue + 1
                    //Fixes the case when updating the hoot score on a singlehootviewcontroller
                    self.setRatingText(self.hoot!.rating)
                } else if self.hootComment != nil {
                    self.hootComment!.voted = 1
                    self.hootComment!.score = self.hootComment!.score.integerValue + 1
                }
            }, completion: nil)
    }

    @IBAction func downVoteButtonDidPress(sender: AnyObject) {
        if hoot != nil {
            HootAPIToCoreData.postHootDownVote(hoot!.id.integerValue, completed: { (success) -> (Void) in
                return
            })
        } else if hootComment != nil {
            HootAPIToCoreData.postCommentDownVote(hootComment!.id.integerValue, completed: { (success) -> (Void) in
                return
            })
        }
        
        downVoteButton.transform = CGAffineTransformMakeTranslation(0, 5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: nil,
            animations: {
                self.downVoteButton.transform = CGAffineTransformMakeTranslation(0, 0)
                self.setVoted(-1)
                
                if self.hoot != nil {
                    self.hoot!.voted = -1
                    self.hoot!.rating = self.hoot!.rating.integerValue - 1
                    //Fixes the case when updating the hoot score on a singlehootviewcontroller
                    self.setRatingText(self.hoot!.rating)
                } else if self.hootComment != nil {
                    self.hootComment!.voted = -1
                    self.hootComment!.score = self.hootComment!.score.integerValue - 1
                }
            }, completion: nil)
    }
    
    func showReplies(show: Bool) {
        if show {
            replies.hidden = false
            repliesImage.hidden = false
        } else {
            replies.hidden = true
            repliesImage.hidden = true
        }
    }
    
    func setValuesWithHoot(newHoot: Hoot) {
        hoot = newHoot
        
        setCommentText(newHoot.comment)
        setRatingText(newHoot.rating)
        setReplyText(newHoot.replies)
        setHootTime(newHoot.time)
        setVoted(newHoot.voted.integerValue)
        
        showReplies(true)
    }
    
    func setValuesWithComment(newComment: HootComment) {
        hootComment = newComment
        
        setCommentText(newComment.text)
        setRatingText(newComment.score)
        setHootTime(newComment.time)
        setVoted(newComment.voted.integerValue)

        showReplies(false)
    }
    
    func setReplyText(number: NSNumber) {
        replies.text = "\(number) replies"
    }
    
    func setRatingText(number: NSNumber) {
        rating.text = "\(number)"
    }
    
    func setCommentText(text: String) {
        comment.text = text
    }
    
    func setVoted(voted: Int) {
        self.upVoteButton.setBackgroundImage(UIImage(named: "Upvote"), forState: UIControlState.Disabled)
        self.downVoteButton.setBackgroundImage(UIImage(named: "Downvote"), forState: UIControlState.Disabled)
        
        if voted == 0 {
            self.upVoteButton.enabled = true
            self.downVoteButton.enabled = true
        } else {
            self.upVoteButton.enabled = false
            self.downVoteButton.enabled = false
            
            if voted == 1 {
                self.upVoteButton.setBackgroundImage(UIImage(named: "UpvoteActive"), forState: UIControlState.Disabled)
            } else {
                self.downVoteButton.setBackgroundImage(UIImage(named: "DownvoteActive"), forState: UIControlState.Disabled)
            }
        }
    }
    
    func setHootTime(date: NSDate) {
        let elapsedTime = NSDate().timeIntervalSinceDate(date)
        
        let formatter = NSDateComponentsFormatter()
        formatter.unitsStyle = .Abbreviated
        
        let components = NSDateComponents()
        
        if elapsedTime / (3600 * 24) > 1 {
            components.day = Int(elapsedTime / (3600 * 24))
        } else if elapsedTime / 3600 > 1 {
            components.hour = Int(elapsedTime / 3600)
        } else if elapsedTime / 60 > 1 {
            components.minute = Int(elapsedTime / 60)
        } else {
            components.second = Int(elapsedTime)
        }
        
        time.text = formatter.stringFromDateComponents(components)
    }
}