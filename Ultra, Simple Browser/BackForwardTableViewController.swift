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
        
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = false
        
        addNewFavoriteTableViewController.addNewFavoriteItemParentViewController = self
        
        let listLabel: UILabel = UILabel()
        if (self.tag != 2) && (self.tag != 3) {
            listLabel.text = "History of this Tab"
            listLabel.frame = CGRect(x: 0, y: 0, width: view.frame.width - 150, height: 30)
            let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
            let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(BackForwardTableViewController.dismissSelf))
            let toolBarItems: [UIBarButtonItem] = [
                listLabelItem,
                self.backForwardParentViewController.flexibleSpaceBarButtonItem,
                cancelButton
            ]
            self.setToolbarItems(toolBarItems, animated: true)
        } else {
            segmentedControl.insertSegment(withTitle: "Favorites", at: 0, animated: true)
            segmentedControl.insertSegment(withTitle: "Historys", at: 1, animated: true)
            segmentedControl.frame = CGRect(x: 0, y: 0, width: view.frame.width - 150, height: 30)
            segmentedControl.addTarget(self, action: #selector(BackForwardTableViewController.segmentedControlPressed(_:)), for: .valueChanged)
            segmentedControlButton = UIBarButtonItem(customView: segmentedControl)
            configFavoritesToolbar()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    /*override func shouldAutorotate() -> Bool {
        return false
    }*/
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        
        if self.tag == 0 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.backList.count
            return number
        } else if self.tag == 1 {
            let number = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.forwardList.count
            return number
        } else if self.tag == 2 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Favorites")
            let sortDescriptor = NSSortDescriptor(key: "time", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            try! Favoriteitems = managedContext!.fetch(fetchRequest) 
            let number = Favoriteitems.count
            return number
        } else if self.tag == 3 {
            print("to History Row")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Historys")
            let sortDescriptor = NSSortDescriptor(key: "time", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            try! Historyitems = managedContext!.fetch(fetchRequest) 
            let number = Historyitems.count
            print(number)
            return number
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableviewcell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        if self.tag == 0 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.item(at: 0 - (indexPath as NSIndexPath).row - 1)?.title
            tableviewcell.detailTextLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.item(at: 0 - (indexPath as NSIndexPath).row - 1)?.url.absoluteString
        } else if self.tag == 1 {
            tableviewcell.textLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.item(at: (indexPath as NSIndexPath).row + 1)?.title
            tableviewcell.detailTextLabel?.text = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].backForwardList.item(at: (indexPath as NSIndexPath).row + 1)?.url.absoluteString
        } else if self.tag == 2 {
            if Favoriteitems.count != 0 {
                let theFavoriteitem = Favoriteitems[(indexPath as NSIndexPath).row]
                let titlestring = theFavoriteitem.value(forKey: "title") as! String?
                tableviewcell.textLabel?.text = titlestring
                let urlstring = theFavoriteitem.value(forKey: "url") as! String?
                tableviewcell.detailTextLabel?.text = urlstring
            }
        } else if self.tag == 3 {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yy/MM/dd hh:mm"
            if Historyitems.count != 0 {
                let theHistoryitem = Historyitems[(indexPath as NSIndexPath).row]
                let titlestring = theHistoryitem.value(forKey: "title") as! String?
                tableviewcell.textLabel?.text = titlestring!
                let datestring = dateFormatter.string(from: theHistoryitem.value(forKey: "time") as! Date)
                let urlstring = theHistoryitem.value(forKey: "url") as! String?
                tableviewcell.detailTextLabel?.text = datestring + " | " + urlstring!
            }
        }
        
        return tableviewcell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismissSelf()
        var thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.item(at: 0)
        if self.tag == 0 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.item(at: 0 - (indexPath as NSIndexPath).row - 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].go(to: thewknavitem!)
        } else if self.tag == 1 {
            thewknavitem = backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].backForwardList.item(at: (indexPath as NSIndexPath).row + 1)
            backForwardParentViewController.webViews[backForwardParentViewController.currentWebView].go(to: thewknavitem!)
        } else if self.tag == 2 {
            let theFavoriteitem = Favoriteitems[(indexPath as NSIndexPath).row]
            let urlstring = theFavoriteitem.value(forKey: "url") as! String?
            self.backForwardParentViewController.textField.text = urlstring
            self.backForwardParentViewController.didClickGo()
        } else if self.tag == 3 {
            let theHistoryitem = Historyitems[(indexPath as NSIndexPath).row]
            let urlstring = theHistoryitem.value(forKey: "url") as! String?
            self.backForwardParentViewController.textField.text = urlstring
            self.backForwardParentViewController.didClickGo()
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext!.delete(theHistoryitem)
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if self.tag == 2 {
            return true
        } else {
            return false
        }
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext
            managedContext!.delete(Favoriteitems[(indexPath as NSIndexPath).row])
            Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(BackForwardTableViewController.tableReload), userInfo: nil, repeats: false)
        } else if editingStyle == .insert {
        }
    }
    
    func dismissSelf() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configFavoritesToolbar() {
        segmentedControl.selectedSegmentIndex = 0
        
        let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BackForwardTableViewController.dismissSelf))
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(BackForwardTableViewController.startAddingFavorites))
        let toolBarItems: [UIBarButtonItem] = [
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
        
        let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BackForwardTableViewController.dismissSelf))
        let clearButton: UIBarButtonItem = UIBarButtonItem(title: "Clear", style: .plain, target: self, action: #selector(BackForwardTableViewController.clearHistory))
        let toolBarItems: [UIBarButtonItem] = [
            clearButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            segmentedControlButton,
            self.backForwardParentViewController.flexibleSpaceBarButtonItem,
            cancelButton
        ]
        self.setToolbarItems(toolBarItems, animated: true)
    }
    
    func segmentedControlPressed(_ segCtrl: UISegmentedControl) {
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
        print("startaddingfavorites")
        addNewFavoriteTableViewController = AddNewFavoriteItemTableViewController(style: .grouped)
        let title: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].title
        let url: String! = self.backForwardParentViewController.webViews[self.backForwardParentViewController.currentWebView].url?.absoluteString
        addNewFavoriteTableViewController.defaultTitle = title
        if url != nil {
            addNewFavoriteTableViewController.defaultURL = url
        }
        let addNewFavoriteNavigationController = UINavigationController(rootViewController: addNewFavoriteTableViewController)
        self.navigationController?.present(addNewFavoriteNavigationController, animated: true, completion: nil)
    }
    
    func addFavorites() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"Favorites")
        //let Favoriteitems = managedContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
        //let entity =  NSEntityDescription.entityForName("Favorites", inManagedObjectContext: managedContext)
        
        let favoriteItem = NSEntityDescription.insertNewObject(forEntityName: "Favorites", into: managedContext!) as NSManagedObject
        
        let timeNow = Date()
        
        favoriteItem.setValue(addNewFavoriteTableViewController.usrTitle, forKey: "title")
        favoriteItem.setValue(addNewFavoriteTableViewController.usrURL, forKey: "url")
        favoriteItem.setValue(timeNow, forKey: "time")
        
        //var error: NSError?
        try! managedContext!.save()
        
        //Favoriteitems.append(favoriteItem)
        
        addNewFavoriteTableViewController = AddNewFavoriteItemTableViewController()
        
        tableView.reloadData()
    }
    
    func clearHistory() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        for mid in Historyitems {
            managedContext!.delete(mid)
        }
        Historyitems.removeAll(keepingCapacity: false)
        
        tableReload()
        let topSitesFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "TopSites")
        var topSites = [NSManagedObject]()
        try! topSites = managedContext!.fetch(topSitesFetchRequest) 
        if topSites.count > 0 {
            for theTopSite in topSites {
                managedContext!.delete(theTopSite)
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
