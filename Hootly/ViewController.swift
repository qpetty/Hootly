//
//  ViewController.swift
//  Hootly
//
//  Created by Quinton Petty on 1/24/15.
//  Copyright (c) 2015 Octave Labs LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var feedTableView: UITableView!
    
    var sampleData: [Hoot] = []
    
    let CELL_HEIGHT = 80.0 as CGFloat
    
    override init() {
        super.init()
        self.makeSampleData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeSampleData()
    }
    
    func makeSampleData() {
        var sample = Hoot(userID: "Brandon", photo: UIImage(named: "hoot1"), comment: "This is a long comment", replies: 5, time: "1", rating: 8)
        sampleData.append(sample)
        
        sample = Hoot(userID: "Krisna", photo: UIImage(named: "hoot2"), comment: "This is a longer comment", replies: 5, time: "10", rating: 8)
        sampleData.append(sample)
        
        sampleData.sort {$0.time < $1.time}
    }
    
    @IBAction func sortList(sender: AnyObject) {
        if let segment = sender as? UISegmentedControl {
            switch segment.selectedSegmentIndex {
            case 1:
                sampleData.sort {$0.time > $1.time}
            default:
                sampleData.sort {$0.time < $1.time}
            }
            
            feedTableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            feedTableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        } else {
            println("Expected UISegementdControl")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return self.view.frame.size.width + CELL_HEIGHT
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = feedTableView.dequeueReusableCellWithIdentifier("Hoot", forIndexPath: indexPath) as HootCell
        
        cell.setHoot(sampleData[indexPath.row])
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case "DetailHoot":
            let dest = segue.destinationViewController as SingleHootViewController
            let cell = sender as HootCell
            dest.hoot = cell.hoot
            
            feedTableView.deselectRowAtIndexPath(feedTableView.indexPathForSelectedRow()!, animated: true)
        case "Camera":
            println("camera appearing")
        default:
            println("unrecognized segue")
        }
    }
}

