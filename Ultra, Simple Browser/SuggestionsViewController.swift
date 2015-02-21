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
    var Historyitems: [NSManagedObject] = []
    var TopSitesitems: [NSManagedObject] = []
    var listOfSuggestionsTitle: [String!] = ["Google", "Facebook", "YouTube", "Yahoo", "Baidu", "Amazon", "Wikipedia", "Taobao", "Twitter", "Tencent QQ", "Windows Live", "Linkedln", "Sina", "Tmall", "Sina Weibo", "Blogspot", "eBay", "Yandex"]
    var listOfSuggestionsURL: [String!] = ["google.com", "facebook.com", "youtube.com", "yahoo.com", "baidu.com", "amazon.com", "wikipedia.org", "taobao.com", "twitter.com", "qq.com", "live.com", "linkedln.com", "sina.com.cn", "tmall.com", "weibo.com", "blogspot.com", "ebay.com", "yandex.ru"]
    var initListOfSuggestionsTitle: [String!] = []
    var initListOfSuggestionsURL: [String!] = []
    ////////parser var was here
    //var textFieldWidget: UIToolbar! = UIToolbar()
    var parser: NSXMLParser! = NSXMLParser()
    //var qrcodescanner: UIButton! = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.9
        
        initListOfSuggestionsTitle = listOfSuggestionsTitle
        initListOfSuggestionsURL = listOfSuggestionsURL
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        
        let fetchFavoritesRequest = NSFetchRequest(entityName:"Favorites")
        Favoriteitems = managedContext.executeFetchRequest(fetchFavoritesRequest, error: nil) as [NSManagedObject]!
        if Favoriteitems.count > 0 {
            for i in 0...Favoriteitems.count - 1 {
                let theFavoriteitem = Favoriteitems[i]
                let titlestring = theFavoriteitem.valueForKey("title") as String?
                initListOfSuggestionsTitle.append(titlestring)
                let urlstring = theFavoriteitem.valueForKey("url") as String?
                initListOfSuggestionsURL.append(urlstring)
            }
        }
        
        let topSitesFetchRequest = NSFetchRequest(entityName:"TopSites")
        TopSitesitems = managedContext.executeFetchRequest(topSitesFetchRequest, error: nil) as [NSManagedObject]!
        if TopSitesitems.count > 0 {
            for theTopSite in TopSitesitems {
                if theTopSite.valueForKey("visits") as Float > 10 {
                    let theFavoriteitem = theTopSite
                    let titlestring = theTopSite.valueForKey("hostUrl") as String?
                    initListOfSuggestionsTitle.append(titlestring)
                    initListOfSuggestionsURL.append("Top Sites")
                }
            }
        }
        
        let fetchHistorysRequest = NSFetchRequest(entityName:"Historys")
        Historyitems = managedContext.executeFetchRequest(fetchHistorysRequest, error: nil) as [NSManagedObject]!
        if Historyitems.count > 0 {
            for i in 0...Historyitems.count - 1 {
                let theHistoryitem = Historyitems[i]
                let titlestring = theHistoryitem.valueForKey("title") as String?
                initListOfSuggestionsTitle.append(titlestring)
                let urlstring = theHistoryitem.valueForKey("url") as String?
                initListOfSuggestionsURL.append(urlstring)
            }
        }
        
        listOfSuggestionsTitle = initListOfSuggestionsTitle
        listOfSuggestionsURL = initListOfSuggestionsURL
        
        suggestionsTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 3000)
        suggestionsTableView.alpha = 1
        suggestionsTableView.delegate = self
        suggestionsTableView.dataSource = self
        
        self.view.addSubview(suggestionsTableView)
        
        //textFieldWidget.frame = CGRectMake(0, view.frame.height - 30, view.frame.width, 30)
        //qrcodescanner.setTitle("QR", forState: .Normal)
        
        //self.view.addSubview(textFieldWidget)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewFrameDidChange() {
        suggestionsTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height/* - 30*/)
        //textFieldWidget.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 30)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSuggestionsTitle.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell = UITableViewCell(style: .Subtitle, reuseIdentifier: nil)
        if tableView.numberOfRowsInSection(0) != 0 {
            cell.textLabel?.text = listOfSuggestionsTitle[indexPath.row]
            cell.detailTextLabel?.text = listOfSuggestionsURL[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var text = listOfSuggestionsURL[indexPath.row]
        
        if text == "Search Engine Suggestion" {
            suggestionsParentViewController.searchURL(listOfSuggestionsTitle[indexPath.row])
        } else if text == "Top Sites" {
            text = listOfSuggestionsTitle[indexPath.row]
            if text.hasPrefix("🔒") {
                let textmid: NSString = NSString(string: text)
                text = String(textmid.substringFromIndex(2))
            }
            if !suggestionsParentViewController.URLHasInternetProtocalPrefix(text) {
                text = "http://" + text
            }
            suggestionsParentViewController.loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        } else {
            if text.hasPrefix("🔒") {
                let textmid: NSString = NSString(string: text)
                text = String(textmid.substringFromIndex(2))
            }
            if !suggestionsParentViewController.URLHasInternetProtocalPrefix(text) {
                text = "http://" + text
            }
            suggestionsParentViewController.loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        }
        suggestionsParentViewController.textField.resignFirstResponder()
    }
    
    func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [NSObject : AnyObject]) {
        if elementName == "suggestion" {
            listOfSuggestionsTitle.append(attributeDict.values.first as String)
            listOfSuggestionsURL.append("Search Engine Suggestion")
        }
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: String) {
        if substring != "" {
            let subString = String(substring).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            listOfSuggestionsTitle.removeAll(keepCapacity: false)
            listOfSuggestionsURL.removeAll(keepCapacity: false)
            if initListOfSuggestionsTitle.count > 0 {
                let uppsubstring = String(subString).uppercaseString
                for i in 0...initListOfSuggestionsURL.count - 1 {
                    if (initListOfSuggestionsTitle[i].uppercaseString.rangeOfString(uppsubstring) != nil) || (initListOfSuggestionsURL[i].uppercaseString.rangeOfString(uppsubstring) != nil)   {
                        listOfSuggestionsTitle.append(initListOfSuggestionsTitle[i])
                        listOfSuggestionsURL.append(initListOfSuggestionsURL[i])
                    }
                }
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                var defaultSearchEngine = NSUserDefaults.standardUserDefaults().stringForKey("searchtype")
                if defaultSearchEngine == "1" {
                    var url = NSURL(string: "http://unionsug.baidu.com/su?wd=" + subString)
                    var sugurlrequest = NSURLRequest(URL: url!)
                    var myresponse = NSURLConnection.sendSynchronousRequest(sugurlrequest, returningResponse: nil, error: nil)
                    
                    var encode:NSStringEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                    
                    var jsonString = NSString(data: myresponse!, encoding: encode)
                    jsonString = jsonString?.substringFromIndex((jsonString?.rangeOfString("[").location)!)
                    jsonString = jsonString?.substringToIndex((jsonString?.length)! - 3)
                    
                    var jsonData = jsonString?.dataUsingEncoding(NSUTF8StringEncoding)
                    var sugDic: NSArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: .MutableContainers, error: nil) as NSArray
                    
                    for i in 0...sugDic.count - 1 {
                        let string: String = String(sugDic[i] as NSString)
                        self.listOfSuggestionsTitle.append(string.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding))
                        self.listOfSuggestionsURL.append("Search Engine Suggestion")
                    }
                } else  {
                    var url: String = "http://google.com/complete/search?output=toolbar&q=" + subString
                    let parserurl = NSURL(string: url)
                    self.parser = NSXMLParser(contentsOfURL: parserurl)
                    self.parser.delegate = self
                    self.parser.parse()
                }
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
    
}
