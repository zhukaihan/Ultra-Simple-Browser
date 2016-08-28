//
//  NewFavoriteItemTableViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/1/14.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class AddNewFavoriteItemTableViewController: UITableViewController {
    
    var addNewFavoriteItemParentViewController: BackForwardTableViewController!
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
        
        usrTitleTextField = UITextField(frame: CGRect(x: 10, y: 0, width: view.frame.width - 10, height: 44))
        usrTitleTextField.placeholder = "Title"
        usrTitleTextField.text = defaultTitle
        usrTitleTextField.tintColor = UIColor.gray
        usrTitleTextField.textAlignment = .left
        usrTitleTextField.clearButtonMode = .whileEditing
        usrTitleTextField.keyboardType = .default
        usrTitleTextField.spellCheckingType = .no
        usrTitleTextField.autocapitalizationType = .none
        usrTitleTextField.autocorrectionType = .no
        usrTitleTextField.enablesReturnKeyAutomatically = true
        
        usrURLTextField = UITextField(frame: CGRect(x: 10, y: 0, width: view.frame.width - 10, height: 44))
        usrURLTextField.placeholder = "URL"
        usrURLTextField.text = defaultURL
        usrURLTextField.tintColor = UIColor.gray
        usrURLTextField.textAlignment = .left
        usrURLTextField.clearButtonMode = .whileEditing
        usrURLTextField.keyboardType = .URL
        usrURLTextField.spellCheckingType = .no
        usrURLTextField.autocapitalizationType = .none
        usrURLTextField.autocorrectionType = .no
        usrURLTextField.enablesReturnKeyAutomatically = true
        
        doneButton = UIButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        doneButton.setTitle("Done", for: UIControlState())
        doneButton.setTitleColor(UIColor.black, for: UIControlState())
        doneButton.addTarget(self, action: #selector(AddNewFavoriteItemTableViewController.pressDone), for: .touchUpInside)
        
        cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(AddNewFavoriteItemTableViewController.cancelAddFavorite))
        self.navigationItem.leftBarButtonItem = cancelButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddNewFavoriteItemTableViewController.orientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        if (indexPath as NSIndexPath).section == 0 {
            if (indexPath as NSIndexPath).row == 0 {
                cell.addSubview(usrTitleTextField)
            } else {
                cell.addSubview(usrURLTextField)
            }
        } else if (indexPath as NSIndexPath).section == 1 {
            cell.addSubview(doneButton)
        }
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(AddNewFavoriteItemTableViewController.orientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self)
    }
    
    func orientationDidChange(_ sender: Notification) {
        //usrTitleTextField.frame = CGRectMake(10, 0, view.frame.width - 10, 44)
        //usrURLTextField.frame = CGRectMake(10, 0, view.frame.width - 10, 44)
        //doneButton.frame = CGRectMake(0, 0, view.frame.width, 44)
        
        addNewFavoriteItemParentViewController?.backForwardParentViewController?.orientationDidChange(sender)
    }
    
    func pressDone() {
        usrTitle = usrTitleTextField.text!
        usrURL = usrURLTextField.text!
        clickedDone = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelAddFavorite(){
        clickedDone = false
        self.dismiss(animated: true, completion: nil)
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
}
