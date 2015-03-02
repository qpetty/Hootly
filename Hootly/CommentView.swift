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
                self.hootComment!.voted = NSNumber(bool: true)
                return
            })
        }
        
        upVoteButton.transform = CGAffineTransformMakeTranslation(0, -5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: nil,
            animations: {
                self.upVoteButton.transform = CGAffineTransformMakeTranslation(0, 0)
                self.upVoteButton.setBackgroundImage(UIImage(named: "UpvoteActive"), forState: UIControlState.Disabled)
                self.setVoted(true)
                
                if self.hoot != nil {
                    self.hoot!.rating = self.hoot!.rating.integerValue + 1
                } else if self.hootComment != nil {
                    self.hootComment!.score = self.hootComment!.score.integerValue + 1
                }
            }, nil)
    }

    @IBAction func downVoteButtonDidPress(sender: AnyObject) {
        if hoot != nil {
            HootAPIToCoreData.postHootDownVote(hoot!.id.integerValue, completed: { (success) -> (Void) in
                return
            })
        } else if hootComment != nil {
            HootAPIToCoreData.postCommentDownVote(hootComment!.id.integerValue, completed: { (success) -> (Void) in
                self.hootComment!.voted = NSNumber(bool: true)
                return
            })
        }
        
        downVoteButton.transform = CGAffineTransformMakeTranslation(0, 5)
        
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.6, options: nil,
            animations: {
                self.downVoteButton.transform = CGAffineTransformMakeTranslation(0, 0)
                self.downVoteButton.setBackgroundImage(UIImage(named: "DownvoteActive"), forState: UIControlState.Disabled)
                self.setVoted(true)
                
                if self.hoot != nil {
                    self.hoot!.rating = self.hoot!.rating.integerValue - 1
                } else if self.hootComment != nil {
                    self.hootComment!.score = self.hootComment!.score.integerValue - 1
                }
            }, nil)
    }
    
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
        setTime(newHoot.time)
        
        showReplies(true)
    }
    
    func setValuesWithComment(newComment: HootComment) {
        hootComment = newComment
        
        setCommentText(newComment.text)
        setRatingText(newComment.score)
        setTime(newComment.time)
        setVoted(newComment.voted.boolValue)

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
    
    func setVoted(voted: Bool) {
        if voted == true {
            self.upVoteButton.enabled = false
            self.downVoteButton.enabled = false
        } else {
            self.upVoteButton.enabled = true
            self.downVoteButton.enabled = true
            
            self.upVoteButton.setBackgroundImage(UIImage(named: "Upvote"), forState: UIControlState.Disabled)
            self.downVoteButton.setBackgroundImage(UIImage(named: "Downvote"), forState: UIControlState.Disabled)
        }
    }
    
    func setTime(date: NSDate) {
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