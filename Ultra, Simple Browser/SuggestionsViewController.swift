//
//  SuggestionsViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/9.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit
import CoreData
import Dispatch

class SuggestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate {
    
    var suggestionsTableView: UITableView = UITableView()
    var suggestionsParentViewController: ViewController!
    var Favoriteitems: [NSManagedObject] = []
    var listOfSuggestionsTitle: [String!] = ["Google", "Facebook", "YouTube", "Yahoo", "Baidu", "Amazon", "Wikipedia", "Taobao", "Twitter", "Tencent QQ", "Windows Live", "Linkedln", "Sina", "Tmall", "Sina Weibo", "Blogspot", "eBay", "Yandex"]
    var listOfSuggestionsURL: [String!] = ["google.com", "facebook.com", "youtube.com", "yahoo.com", "baidu.com", "amazon.com", "wikipedia.org", "taobao.com", "twitter.com", "qq.com", "live.com", "linkedln.com", "sina.com.cn", "tmall.com", "weibo.com", "blogspot.com", "ebay.com", "yandex.ru"]
    var initListOfSuggestionsTitle: [String!] = []
    var initListOfSuggestionsURL: [String!] = []
    var parser: NSXMLParser! = NSXMLParser()
    
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
        
        parser.delegate = self
        
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
        cell.detailTextLabel?.text = listOfSuggestionsURL[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var text = listOfSuggestionsURL[indexPath.row]
        if text.hasPrefix("🔒") {
            let textmid: NSString = NSString(string: text)
            text = String(textmid.substringFromIndex(2))
        }
        if !suggestionsParentViewController.URLHasInternetProtocalPrefix(text) {
            text = "http://" + text
        }
        suggestionsParentViewController.loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        suggestionsParentViewController.textField.resignFirstResponder()
    }
    
    func parser(parser: NSXMLParser!, didStartElement elementName: String!, namespaceURI: String!, qualifiedName qName: String!, attributes attributeDict: [NSObject : AnyObject]!) {
        if elementName == "suggestion" {
            listOfSuggestionsTitle.append(attributeDict.values.first as String)
            listOfSuggestionsURL.append("http://google.com/search?q=\(attributeDict.values.first as String)")
        }
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
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                let url: String = "http://google.com/complete/search?output=toolbar&q=" + substring
                let parserurl = NSURL(string: url.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
                self.parser = NSXMLParser(contentsOfURL: parserurl)
                self.parser.delegate = self
                self.parser.parse()
                dispatch_async(dispatch_get_main_queue(), {
                    UIView.beginAnimations("animateWebView", context: nil)
                    UIView.setAnimationDuration(0.2)
                    self.suggestionsTableView.reloadData()
                    UIView.commitAnimations()
                })
            })
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
