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
    var segmentedControl: UISegmentedControl = UISegmentedControl()
    var segmentedControlButton: UIBarButtonItem!
    var Favoriteitems = [NSManagedObject]()
    var Historyitems = [NSManagedObject]()
    var addNewFavoriteTableViewController: AddNewFavoriteItemTableViewController! = AddNewFavoriteItemTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        self.navigationController?.toolbarHidden = false
        
        let listLabel: UILabel = UILabel()
        if (self.tag != 2) && (self.tag != 3) {
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
            segmentedControl.insertSegmentWithTitle("Favorites", atIndex: 0, animated: true)
            segmentedControl.insertSegmentWithTitle("Historys", atIndex: 1, animated: true)
            segmentedControl.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            segmentedControl.addTarget(self, action: "segmentedControlPressed:", forControlEvents: .ValueChanged)
            segmentedControlButton = UIBarButtonItem(customView: segmentedControl)
            configFavoritesToolbar()
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
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if self.tag == 0 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.backList.count
            return number
        } else if self.tag == 1 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.forwardList.count
            return number
        } else if self.tag == 2 {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            var fetchRequest = NSFetchRequest(entityName:"Favorites")
            let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            Favoriteitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
            let number = Favoriteitems.count
            return number
        } else if self.tag == 3 {
            println("to History Row")
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            var fetchRequest = NSFetchRequest(entityName:"Historys")
            let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            Historyitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
            let number = Historyitems.count
            println(number)
            return number
        } else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableviewcell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        
        if self.tag == 0 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(0 - indexPath.row - 1)?.title
            tableviewcell.detailTextLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(0 - indexPath.row - 1)?.URL.absoluteString
        } else if self.tag == 1 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(indexPath.row + 1)?.title
            tableviewcell.detailTextLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(indexPath.row + 1)?.URL.absoluteString
        } else if self.tag == 2 {
            if Favoriteitems.count != 0 {
                let theFavoriteitem = Favoriteitems[indexPath.row]
                let titlestring = theFavoriteitem.valueForKey("title") as String?
                tableviewcell.textLabel?.text = titlestring
                let urlstring = theFavoriteitem.valueForKey("url") as String?
                tableviewcell.detailTextLabel?.text = urlstring
            }
        } else if self.tag == 3 {
            var dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd hh:mm"
            if Historyitems.count != 0 {
                let theHistoryitem = Historyitems[indexPath.row]
                let titlestring = theHistoryitem.valueForKey("title") as String?
                tableviewcell.textLabel?.text = titlestring!
                let datestring = dateFormatter.stringFromDate(theHistoryitem.valueForKey("time") as NSDate)
                let urlstring = theHistoryitem.valueForKey("url") as String?
                tableviewcell.detailTextLabel?.text = datestring + " | " + urlstring!
            }
        }
        
        return tableviewcell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        dismissSelf()
        var thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(0)
        if self.tag == 0 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(0 - indexPath.row - 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].goToBackForwardListItem(thewknavitem!)
        } else if self.tag == 1 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.itemAtIndex(indexPath.row + 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].goToBackForwardListItem(thewknavitem!)
        } else if self.tag == 2 {
            let theFavoriteitem = Favoriteitems[indexPath.row]
            let urlstring = theFavoriteitem.valueForKey("url") as String?
            self.backForwardParentViewController.textField.text = urlstring
            self.backForwardParentViewController.didClickGo()
        } else if self.tag == 3 {
            let theHistoryitem = Historyitems[indexPath.row]
            let urlstring = theHistoryitem.valueForKey("url") as String?
            self.backForwardParentViewController.textField.text = urlstring
            self.backForwardParentViewController.didClickGo()
            
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(theHistoryitem as NSManagedObject)
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
    
    func configFavoritesToolbar() {
        segmentedControl.selectedSegmentIndex = 0
        
        let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSelf")
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "startAddingFavorites")
        var toolBarItems = [
            addButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            segmentedControlButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            cancelButton
        ]
        self.setToolbarItems(toolBarItems, animated: true)
    }
    
    func configHistorysToolbar() {
        segmentedControl.selectedSegmentIndex = 1
        
        let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "dismissSelf")
        var clearButton: UIBarButtonItem = UIBarButtonItem(title: "Clear", style: .Plain, target: self, action: "clearHistory")
        var toolBarItems = [
            clearButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            segmentedControlButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            cancelButton
        ]
        self.setToolbarItems(toolBarItems, animated: true)
    }
    
    func segmentedControlPressed(segCtrl: UISegmentedControl) {
        switch segCtrl.selectedSegmentIndex {
        case 0:
            self.tag = 2
            configFavoritesToolbar()
        case 1:
            self.tag = 3
            configHistorysToolbar()
        default: true
        }
        self.tableReload()
    }
    
    func startAddingFavorites() {
        println("startaddingfavorites")
        addNewFavoriteTableViewController = AddNewFavoriteItemTableViewController(style: .Grouped)
        let title: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].title
        let url: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].URL?.absoluteString
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
        
        let timeNow = NSDate()
        
        favoriteItem.setValue(addNewFavoriteTableViewController.usrTitle, forKey: "title")
        favoriteItem.setValue(addNewFavoriteTableViewController.usrURL, forKey: "url")
        favoriteItem.setValue(timeNow, forKey: "time")
        
        var error: NSError?
        if !managedContext.save(&error) {
            println("Could not save \\(error), \(error?.userInfo)")
        }
        
        //Favoriteitems.append(favoriteItem)
        
        addNewFavoriteTableViewController = AddNewFavoriteItemTableViewController()
        
        tableView.reloadData()
    }
    
    func clearHistory() {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        var mid: NSManagedObject!
        for mid in Historyitems {
            managedContext.deleteObject(mid as NSManagedObject)
        }
        Historyitems.removeAll(keepCapacity: false)
        
        tableReload()
        
        let topSitesFetchRequest = NSFetchRequest(entityName:"TopSites")
        var topSites = managedContext.executeFetchRequest(topSitesFetchRequest, error: nil) as [NSManagedObject]!
        if topSites.count > 0 {
            for theTopSite in topSites {
                managedContext.deleteObject(theTopSite)
            }
        }
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
