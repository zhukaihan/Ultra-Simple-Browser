//
//  NewFavoriteItemTableViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/1/14.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class NewFavoriteItemTableViewController: UITableViewController, UITableViewDataSource, UITableViewDelegate {
    
    var thepassingvalue: Int = 0
    var viewshowed: Bool = false
    var clickedDone: Bool = false
    var defaultTitle: String = ""
    var defaultURL: String = ""
    var usrTitle: String = ""
    var usrURL: String = ""
    var usrTitleTextField: UITextField!
    var usrURLTextField: UITextField!
    var doneButton: UIButton!
    var cancelButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewshowed = true
        
        usrTitleTextField = UITextField(frame: CGRectMake(10, 0, view.frame.width - 10, 44))
        usrTitleTextField.placeholder = "Title"
        usrTitleTextField.text = defaultTitle
        usrTitleTextField.tintColor = UIColor.grayColor()
        usrTitleTextField.textAlignment = .Left
        usrTitleTextField.clearButtonMode = .WhileEditing
        usrTitleTextField.keyboardType = .Default
        usrTitleTextField.spellCheckingType = .No
        usrTitleTextField.autocapitalizationType = .None
        usrTitleTextField.autocorrectionType = .No
        usrTitleTextField.enablesReturnKeyAutomatically = true
        
        usrURLTextField = UITextField(frame: CGRectMake(10, 0, view.frame.width - 10, 44))
        usrURLTextField.placeholder = "URL"
        usrURLTextField.text = defaultURL
        usrURLTextField.tintColor = UIColor.grayColor()
        usrURLTextField.textAlignment = .Left
        usrURLTextField.clearButtonMode = .WhileEditing
        usrURLTextField.keyboardType = .URL
        usrURLTextField.spellCheckingType = .No
        usrURLTextField.autocapitalizationType = .None
        usrURLTextField.autocorrectionType = .No
        usrURLTextField.enablesReturnKeyAutomatically = true
        
        doneButton = UIButton(frame: CGRectMake(0, 0, view.frame.width, 44))
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
        doneButton.addTarget(self, action: "pressDone", forControlEvents: .TouchUpInside)
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelAddFavorite")
        self.navigationItem.leftBarButtonItem = cancelButton
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.addSubview(usrTitleTextField)
            } else {
                cell.addSubview(usrURLTextField)
            }
        } else if indexPath.section == 1 {
            cell.addSubview(doneButton)
        }
        
        return cell
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "orientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.removeObserver(self)
    }
    
    func orientationDidChange() {
        usrTitleTextField.frame = CGRectMake(10, 0, view.frame.width - 10, 44)
        usrURLTextField.frame = CGRectMake(10, 0, view.frame.width - 10, 44)
        doneButton.frame = CGRectMake(0, 0, view.frame.width, 44)
    }
    
    func pressDone() {
        usrTitle = usrTitleTextField.text
        usrURL = usrURLTextField.text
        clickedDone = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancelAddFavorite(){
        clickedDone = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
