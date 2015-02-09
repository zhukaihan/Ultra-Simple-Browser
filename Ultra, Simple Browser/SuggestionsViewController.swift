//
//  SuggestionsViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/9.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit
import CoreData

class SuggestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var suggestionsTableView: UITableView = UITableView()
    var suggestionsParentViewController: ViewController!
    var Favoriteitems: [NSManagedObject] = []
    var listOfSuggestionsTitle: [String!] = ["Google", "Facebook", "YouTube", "Yahoo", "Baidu", "Amazon", "Wikipedia", "Taobao", "Twitter", "Tencent QQ", "Windows Live", "Linkedln", "Sina", "Tmall", "Sina Weibo", "Blogspot", "eBay", "Yandex"]
    var listOfSuggestionsURL: [String!] = ["google.com", "facebook.com", "youtube.com", "yahoo.com", "baidu.com", "amazon.com", "wikipedia.org", "taobao.com", "twitter.com", "qq.com", "live.com", "linkedln.com", "sina.com.cn", "tmall.com", "weibo.com", "blogspot.com", "ebay.com", "yandex.ru"]
    var initListOfSuggestionsTitle: [String!] = []
    var initListOfSuggestionsURL: [String!] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.9
        
        initListOfSuggestionsTitle = listOfSuggestionsTitle
        initListOfSuggestionsURL = listOfSuggestionsURL
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"Favorites")
        Favoriteitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
        if Favoriteitems.count > 0 {
            for i in 0...Favoriteitems.count - 1 {
                let theFavoriteitem = Favoriteitems[i]
                let titlestring = theFavoriteitem.valueForKey("title") as String?
                initListOfSuggestionsTitle.append(titlestring)
                let urlstring = theFavoriteitem.valueForKey("url") as String?
                initListOfSuggestionsURL.append(urlstring)
            }
            listOfSuggestionsTitle = initListOfSuggestionsTitle
            listOfSuggestionsURL = initListOfSuggestionsURL
        }
        
        suggestionsTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        suggestionsTableView.alpha = 1
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        
        self.view.addSubview(suggestionsTableView)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("\(listOfSuggestionsTitle.count)")
        return listOfSuggestionsTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell()
        cell.textLabel?.text = listOfSuggestionsTitle[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        suggestionsParentViewController.textField.text = listOfSuggestionsURL[indexPath.row]
        suggestionsParentViewController.textFieldShouldReturn(suggestionsParentViewController.textField)
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        if substring != "" {
            listOfSuggestionsTitle.removeAll(keepCapacity: false)
            listOfSuggestionsURL.removeAll(keepCapacity: false)
            if initListOfSuggestionsTitle.count > 0 {
                for i in 0...initListOfSuggestionsURL.count - 1 {
                    if (initListOfSuggestionsTitle[i].lowercaseString.rangeOfString(substring.lowercaseString) != nil) || (initListOfSuggestionsURL[i].lowercaseString.rangeOfString(substring.lowercaseString) != nil)   {
                        listOfSuggestionsTitle.append(initListOfSuggestionsTitle[i])
                        listOfSuggestionsURL.append(initListOfSuggestionsURL[i])
                    }
                }
            }
        } else {
            listOfSuggestionsTitle = initListOfSuggestionsTitle
            listOfSuggestionsURL = initListOfSuggestionsURL
        }
        suggestionsTableView.reloadData()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
