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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SuggestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var suggestionsRetreiveQueue: DispatchQueue = DispatchQueue(label: "com.zhukaihan.suggestionsRetreive", attributes: []);
    
    var suggestionsTableView: UITableView = UITableView()
    var suggestionsParentViewController: ViewController!
    var Favoriteitems: [NSManagedObject] = []
    var Historyitems: [NSManagedObject] = []
    var TopSitesitems: [NSManagedObject] = []
    var listOfSuggestionsTitle: [String?] = ["Google", "Facebook", "YouTube", "Yahoo", "Baidu", "Amazon", "Wikipedia", "Taobao", "Twitter", "Tencent QQ", "Windows Live", "Linkedln", "Sina", "Tmall", "Sina Weibo", "Blogspot", "eBay"]
    var listOfSuggestionsURL: [String?] = ["google.com", "facebook.com", "youtube.com", "yahoo.com", "baidu.com", "amazon.com", "wikipedia.org", "taobao.com", "twitter.com", "qq.com", "live.com", "linkedln.com", "sina.com.cn", "tmall.com", "weibo.com", "blogspot.com", "ebay.com"]
    var initListOfSuggestionsTitle: [String?] = []
    var initListOfSuggestionsURL: [String?] = []
    //var textFieldWidget: UIToolbar! = UIToolbar()
    //var qrcodescanner: UIButton! = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.alpha = 0.9
        
        initListOfSuggestionsTitle = listOfSuggestionsTitle
        initListOfSuggestionsURL = listOfSuggestionsURL
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        
        let topSitesFetchRequest = NSFetchRequest<NSManagedObject>(entityName:"TopSites")
        try! TopSitesitems = managedContext!.fetch(topSitesFetchRequest)
        if TopSitesitems.count > 0 {
            for theTopSite in TopSitesitems {
                if theTopSite.value(forKey: "visits") as! Float > 5 {
                    //let theFavoriteitem = theTopSite
                    let titlestring = theTopSite.value(forKey: "hostUrl") as! String?
                    initListOfSuggestionsTitle.append(titlestring)
                    initListOfSuggestionsURL.append("Top Sites")
                }
            }
        }
        
        let fetchFavoritesRequest = NSFetchRequest<NSManagedObject>(entityName:"Favorites")
        try! Favoriteitems = managedContext!.fetch(fetchFavoritesRequest)
        if Favoriteitems.count > 0 {
            for i in 0...Favoriteitems.count - 1 {
                let theFavoriteitem = Favoriteitems[i]
                let titlestring = theFavoriteitem.value(forKey: "title") as! String?
                initListOfSuggestionsTitle.append(titlestring)
                let urlstring = theFavoriteitem.value(forKey: "url") as! String?
                initListOfSuggestionsURL.append(urlstring)
            }
        }
        
        let fetchHistorysRequest = NSFetchRequest<NSManagedObject>(entityName:"Historys")
        try! Historyitems = managedContext!.fetch(fetchHistorysRequest)
        if Historyitems.count > 0 {
            for i in 0...Historyitems.count - 1 {
                let theHistoryitem = Historyitems[i]
                let titlestring = theHistoryitem.value(forKey: "title") as! String?
                initListOfSuggestionsTitle.append(titlestring)
                let urlstring = theHistoryitem.value(forKey: "url") as! String?
                initListOfSuggestionsURL.append(urlstring)
            }
        }
        
        listOfSuggestionsTitle = initListOfSuggestionsTitle
        listOfSuggestionsURL = initListOfSuggestionsURL
        
        suggestionsTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
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
        suggestionsTableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height/* - 30*/)
        //textFieldWidget.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 30)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfSuggestionsTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        if tableView.numberOfRows(inSection: 0) != 0 {
            cell.textLabel?.text = listOfSuggestionsTitle[(indexPath as NSIndexPath).row]
            cell.detailTextLabel?.text = listOfSuggestionsURL[(indexPath as NSIndexPath).row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var text = listOfSuggestionsURL[(indexPath as NSIndexPath).row]
        
        if text == "Search Engine Suggestion" {
            suggestionsParentViewController.searchURL(listOfSuggestionsTitle[(indexPath as NSIndexPath).row]!)
        } else if text == "Top Sites" {
            text = listOfSuggestionsTitle[(indexPath as NSIndexPath).row]
            if (text?.hasPrefix("🔒"))! {
                let textmid: NSString = NSString(string: text!)
                text = String(textmid.substring(from: 2))
            }
            if !suggestionsParentViewController.URLHasInternetProtocalPrefix(text!) {
                text = "http://" + text!
            }
            //suggestionsParentViewController.loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            suggestionsParentViewController.loadURLRegularly((text?.removingPercentEncoding!)!)
        } else {
            if (text?.hasPrefix("🔒"))! {
                let textmid: NSString = NSString(string: text!)
                text = String(textmid.substring(from: 2))
            }
            if !suggestionsParentViewController.URLHasInternetProtocalPrefix(text!) {
                text = "http://" + text!
            }
            //suggestionsParentViewController.loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            suggestionsParentViewController.loadURLRegularly((text?.removingPercentEncoding!)!)
        }
        suggestionsParentViewController.textField.resignFirstResponder()
    }
    
    func searchAutocompleteEntriesWithSubstring(_ substring: String) {
        if (substring != "") {
            //let subString = String(substring).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let subString = String(substring).removingPercentEncoding!
            listOfSuggestionsTitle.removeAll(keepingCapacity: false)
            listOfSuggestionsURL.removeAll(keepingCapacity: false)
            if initListOfSuggestionsTitle.count > 0 {
                let uppsubstring = String(subString).uppercased(with: NSLocale.current)
                for i in 0...initListOfSuggestionsURL.count - 1 {
                    let tryUppercase = initListOfSuggestionsTitle[i]?.uppercased(with: NSLocale.current).range(of: uppsubstring)
                    if (tryUppercase != nil) ||
                        (initListOfSuggestionsURL[i]?.uppercased(with: NSLocale.current).range(of: uppsubstring) != nil)   {
                        listOfSuggestionsTitle.append(initListOfSuggestionsTitle[i])
                        listOfSuggestionsURL.append(initListOfSuggestionsURL[i])
                    }
                }
            }
            if !suggestionsParentViewController.URLIsValid(subString) {
                suggestionsRetreiveQueue.async(execute: { // dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                    let defaultSearchEngine = UserDefaults.standard.string(forKey: "searchtype")
                    if defaultSearchEngine == "1" {
                        let urlstring: String = "http://unionsug.baidu.com/su?wd=" + subString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
                        let url = URL(string: urlstring)!
                        let sugurlrequest = URLRequest(url: url)
                        
                        var myresponse: Data?
                        do {
                            try myresponse = NSURLConnection.sendSynchronousRequest(sugurlrequest, returning: nil)
                        } catch {
                            print("error getting sug")
                            myresponse = nil
                        }
                        
                        let encode: CUnsignedLong = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                        var jsonString: NSString?
                        if (myresponse != nil) {
                            jsonString = NSString(data: myresponse!, encoding: encode)
                        } else {
                            jsonString = nil
                        }
                        
                        if (jsonString != nil) && ((String(jsonString!).range(of: "<!DOCTYPE html>")) == nil) {
                            jsonString = NSString(string: (jsonString?.substring(from: (jsonString?.range(of: "[").location)!))!)
                            jsonString = NSString(string: (jsonString?.substring(to: (jsonString?.length)! - 3))!)
                            
                            let jsonData = jsonString?.data(using: String.Encoding.utf8.rawValue)
                            if (jsonData != nil) && (jsonString?.length > 2) {
                                do {
                                    var sugDic: NSArray = NSArray()
                                    try sugDic = JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as! NSArray
                                    
                                    if sugDic.count > 0 {
                                        for i in 0...sugDic.count - 1 {
                                            let string: String = String(sugDic[i] as! NSString)
                                            self.listOfSuggestionsTitle.append(string.removingPercentEncoding)
                                            self.listOfSuggestionsURL.append("Search Engine Suggestion")
                                        }
                                    }
                                } catch {
                                }
                            }
                        }
                    } else {
                        let urlstring: String = "http://google.com/complete/search?output=firefox&q=" + subString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
                        print(urlstring)
                        let url: URL = URL(string: urlstring)!
                        let sugurlrequest: URLRequest = URLRequest(url: url)
                        
                        var myresponse: Data?
                        do {
                            try myresponse = NSURLConnection.sendSynchronousRequest(sugurlrequest, returning: nil)
                        } catch {
                            print("error getting sug")
                            myresponse = nil
                        }
                        
                        var jsonString: NSString?
                        if (myresponse != nil) {
                            jsonString = NSString(data: myresponse!, encoding: String.Encoding.utf8.rawValue)
                        } else {
                            jsonString = nil
                        }
                        
                        if (jsonString != nil) && ((String(jsonString!).range(of: "<!DOCTYPE html>")) == nil) {
                            jsonString = NSString(string: (jsonString?.substring(from: (jsonString?.range(of: ",[").location)! + 1))!)
                            jsonString = NSString(string: (jsonString?.substring(to: (jsonString?.length)! - 1))!)
                            
                            let jsonData = jsonString?.data(using: String.Encoding.utf8.rawValue)
                            if (jsonData != nil) && (jsonString?.length > 2) {
                                do {
                                    var sugDic: NSArray = NSArray()
                                    try sugDic = JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers) as! NSArray
                                    
                                    if sugDic.count > 0 {
                                        for i in 0...sugDic.count - 1 {
                                            let string: String = String(sugDic[i] as! NSString)
                                            self.listOfSuggestionsTitle.append(string.removingPercentEncoding)
                                            //self.listOfSuggestionsTitle.append(string.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding))
                                            self.listOfSuggestionsURL.append("Search Engine Suggestion")
                                        }
                                    }
                                } catch {
                                }
                                
                            }
                        }
                    }
                    DispatchQueue.main.async(execute: {
                        //animation for reloadData was 0.2 seconds. but it didn't work. ofcourse it didn't.
                        self.suggestionsTableView.reloadData()
                    })
                })
            }
        } else {
            listOfSuggestionsTitle = initListOfSuggestionsTitle
            listOfSuggestionsURL = initListOfSuggestionsURL
        }
        suggestionsTableView.reloadData()
    }
    
}
