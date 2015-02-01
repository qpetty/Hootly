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
    
    override init() {
        super.init()
        self.makeSampleData()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.makeSampleData()
    }
    
    func makeSampleData() {
        var sample = Hoot(userID: "Brandon", photo: UIImage(named: "hoot1"), comment: "This is a long comment", replies: 5, time: "10", rating: 8)
        sampleData.append(sample)
        
        sample = Hoot(userID: "Krisna", photo: UIImage(named: "hoot2"), comment: "This is a longer comment", replies: 5, time: "10", rating: 8)
        sampleData.append(sample)
    }
    
    @IBAction func sortList(sender: AnyObject) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        let dest = segue.destinationViewController as SingleHootViewController
        let cell = sender as HootCell
        dest.hoot = cell.hoot
        
        feedTableView.deselectRowAtIndexPath(feedTableView.indexPathForSelectedRow()!, animated: true)
    }
}

