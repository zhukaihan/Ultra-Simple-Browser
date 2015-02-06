//
//  BackForwardTableViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/5.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit
import CoreData

class BackForwardTableViewController: UITableViewController {
    
    var backForwardParentViewController: ViewController!
    var tag: Int! = 0
    var Favoriteitems = [NSManagedObject]()
    var addNewFavoriteTableViewController: NewFavoriteItemTableViewController! = NewFavoriteItemTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = false
        
        let listLabel: UILabel = UILabel()
        if self.tag != 2 {
            listLabel.text = "History of this Tab"
            listLabel.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
            let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "dismissSelf")
            var toolBarItems = [
                listLabelItem,
                self.backForwardParentViewController.flexibleSpaceBarButtonItem,
                cancelButton
            ]
            self.setToolbarItems(toolBarItems, animated: true)
        } else {
            listLabel.text = "Favorites"
            listLabel.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
            let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSelf")
            let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "startAddingFavorites")
            var toolBarItems = [
                addButton,
                self.backForwardParentViewController.flexibleSpaceBarButtonItem,
                listLabelItem,
                self.backForwardParentViewController.flexibleSpaceBarButtonItem,
                cancelButton
            ]
            self.setToolbarItems(toolBarItems, animated: true)
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if ((addNewFavoriteTableViewController.viewshowed) && (addNewFavoriteTableViewController.clickedDone)) {
            addFavorites()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        
        if self.tag == 0 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.backForwardList.backList.count
            return number!
        } else if self.tag == 1 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.backForwardList.forwardList.count
            return number!
        } else if self.tag == 2 {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName:"Favorites")
            Favoriteitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
            let number = Favoriteitems.count
            return number
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("cellforrowatindexpath")
        let tableviewcell = UITableViewCell()
        //tableviewcell.textLabel?.text = webViews[currentWebView]?.backForwardList.backItem?.title
        if self.tag == 0 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView]?.backForwardList.itemAtIndex(0 - indexPath.row - 1)?.title
        } else if self.tag == 1 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView]?.backForwardList.itemAtIndex(indexPath.row + 1)?.title
        } else if self.tag == 2 {
            if Favoriteitems.count != 0 {
                let theFavoriteitem = Favoriteitems[indexPath.row]
                let urlstring = theFavoriteitem.valueForKey("title") as String?
                tableviewcell.textLabel?.text = urlstring
            }
        }
        //return webViews[currentWebView]?.backForwardList.backList.first as UITableViewCell
        return tableviewcell
        
        /*
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as UITableViewCell
        
        return cell*/
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissSelf()
        var thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.backForwardList.itemAtIndex(0)
        if self.tag == 0 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.backForwardList.itemAtIndex(0 - indexPath.row - 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.goToBackForwardListItem(thewknavitem!)
        } else if self.tag == 1 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.backForwardList.itemAtIndex(indexPath.row + 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView]?.goToBackForwardListItem(thewknavitem!)
        } else if self.tag == 2 {
            let theFavoriteitem = Favoriteitems[indexPath.row]
            let urlstring = theFavoriteitem.valueForKey("url") as String?
            self.backForwardParentViewController.textField.text = urlstring
            self.backForwardParentViewController.didClickGo()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if self.tag == 2 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(Favoriteitems[indexPath.row])
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "tableReload", userInfo: nil, repeats: false)
        } else if editingStyle == .Insert {
        }
    }
    
    func dismissSelf() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func startAddingFavorites() {
        println("startaddingfavorites")
        addNewFavoriteTableViewController = NewFavoriteItemTableViewController(style: .Grouped)
        let title: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView]?.title
        let url: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView]?.URL?.absoluteString
        addNewFavoriteTableViewController.defaultTitle = title
        if url != nil {
            addNewFavoriteTableViewController.defaultURL = url
        }
        var addNewFavoriteNavigationController = UINavigationController(rootViewController: addNewFavoriteTableViewController)
        self.navigationController?.presentViewController(addNewFavoriteNavigationController, animated: true, completion: nil)
    }
    
    func addFavorites() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Favorites")
        var Favoriteitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
        let entity =  NSEntityDescription.entityForName("Favorites", inManagedObjectContext: managedContext)
        
        let favoriteItem = NSEntityDescription.insertNewObjectForEntityForName("Favorites", inManagedObjectContext: managedContext) as NSManagedObject
        
        favoriteItem.setValue(addNewFavoriteTableViewController.usrTitle, forKey: "title")
        favoriteItem.setValue(addNewFavoriteTableViewController.usrURL, forKey: "url")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \\(error), \(error?.userInfo)")
        }
        
        //Favoriteitems.append(favoriteItem)
        
        addNewFavoriteTableViewController = NewFavoriteItemTableViewController()
        
        tableView.reloadData()
    }
    
    func tableReload() {
        tableView.reloadData()
    }

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
