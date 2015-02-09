//
//  ViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 14/12/6.
//  Copyright (c) 2014年 Peter Zhu. All rights reserved.
//
//  This is an "Emily Dickinson" style poetry.

import UIKit  //Foundation included in
import WebKit
import iAd
import QuartzCore
import CoreData

class ViewController: UIViewController, UIContentContainer, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    
//////////Variables
    var homewebpage : String!
    var defaultSearchEngine = NSUserDefaults.standardUserDefaults().stringForKey("searchtype")
    var unclosedwebviews = [NSManagedObject]()
    var orientationchanged: Bool = false //true for landscape, false for portrait
    
    var currentWebView: Int = 0
    var totalWebView: Int = 0
    var weby: CGFloat = CGFloat(0)
    var showingAllWebViews: Bool = false
    
    var panInit: Int = 0
    var panInitdir: Bool = false  //true for left and right, false for up or down
    var webViewCloseSwipe: [UIPanGestureRecognizer!]! = []
    //var webViewCloseLongPress: [UILongPressGestureRecognizer!]! = []  //long press to sort webviews
    var webViewButtons: [UIButton?]! = [UIButton()]
    var webViewLabels: [UILabel?]! = [UILabel()]
    var webViews: [WKWebView?]! = []  //first WKWebView starts at webViews[0]
    var undoWebView: WKWebView? = WKWebView()
    var isLongPressed: Bool = false
    var backForwardFavoriteTableView: BackForwardTableViewController! = BackForwardTableViewController()
    //var autocompleteTableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    var backButton: UIBarButtonItem!
    var forwardButton: UIBarButtonItem!
    var textItem: UIBarButtonItem!
    var webViewSwitch: UIBarButtonItem!
    var undoWebViewButton: UIBarButtonItem!
    var flexibleSpaceBarButtonItem: UIBarButtonItem!
    
    var fullscreenbutton: UIButton!
    var homebutton: UIButton!
    var sharebutton: UIButton!
    var openinsafaributton: UIButton!
    var showfavoritebutton: UIButton!
    
    var dashboard: UIScrollView! = UIScrollView()
    var dashboardTitle: UILabel! = UILabel()
    var dashboardPageControl: UIPageControl! = UIPageControl()
    var superHugeRegretButton: UIButton = UIButton()
    
    var toolBar: UIToolbar! = UIToolbar()
    var edgeSwipe: UIPanGestureRecognizer! = UIPanGestureRecognizer()
    var showButton: UIButton! = UIButton()
    var textField: URLTextField!
    var childSuggestionsViewController: SuggestionsViewController = SuggestionsViewController()
    
    var progressBar: UIProgressView! = UIProgressView(progressViewStyle: .Bar)
    
    var adbanner: ADBannerView! = ADBannerView()
    
    let backgroundimage = UIImageView(image: UIImage(named: "icon.png")!)
    
    
//////////Override funcs
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        backgroundimage.frame = CGRectMake(0, 0, view.frame.width, view.frame.width)
        self.view.addSubview(backgroundimage)
        
        configtextField()
        textField.configrefreshImage()
        textField.delegate = self
        
        let backimg = UIImage(named: "backbutton.png")
        let backbutton = UIButton()
        backbutton.setBackgroundImage(backimg, forState: .Normal)
        backbutton.frame = CGRectMake(0, 0, 30, 30)
        backbutton.addTarget(self, action: "goBack", forControlEvents: .TouchUpInside)
        let backButtonLongPress = UILongPressGestureRecognizer(target: self, action: "showGoBackList:")
        backButtonLongPress.minimumPressDuration = 1
        backbutton.addGestureRecognizer(backButtonLongPress)
        backButton = UIBarButtonItem(customView: backbutton)
        backButton.enabled = false
        let forwardimg = UIImage(named: "forwardbutton.png")
        let forwardbutton = UIButton()
        forwardbutton.setBackgroundImage(forwardimg, forState: .Normal)
        forwardbutton.frame = CGRectMake(0, 0, 30, 30)
        forwardbutton.addTarget(self, action: "goForward", forControlEvents: .TouchUpInside)
        let forwardButtonLongPress = UILongPressGestureRecognizer(target: self, action: "showGoForwardList:")
        forwardButtonLongPress.minimumPressDuration = 1
        forwardbutton.addGestureRecognizer(forwardButtonLongPress)
        forwardButton = UIBarButtonItem(customView: forwardbutton)
        forwardButton.enabled = false
        textItem = UIBarButtonItem(customView: textField)
        let webViewSwitchimg = UIImage(named: "pages.png")
        let webViewSwitchbutton = UIButton()
        webViewSwitchbutton.setBackgroundImage(webViewSwitchimg, forState: .Normal)
        webViewSwitchbutton.frame = CGRectMake(0, 0, 30, 30)
        webViewSwitchbutton.addTarget(self, action: "showAllWebViews", forControlEvents: .TouchUpInside)
        webViewSwitch = UIBarButtonItem(customView: webViewSwitchbutton)
        webViewSwitch.enabled = true
        undoWebViewButton = UIBarButtonItem(barButtonSystemItem: .Undo, target: self, action: "undoPreviousWebView")
        undoWebViewButton.enabled = false
        flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        
        toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        configtoolbaritems()
        toolBar.backgroundColor = UIColor.lightGrayColor()
        self.view.addSubview(toolBar)
        
        edgeSwipe.addTarget(self, action: "displayDashboard")
        toolBar.addGestureRecognizer(edgeSwipe)
        
        let fullscreenbuttonimg = UIImage(named: "fullscreen.png")
        fullscreenbutton = UIButton()
        fullscreenbutton.frame = CGRectMake(view.frame.width / 4 * 1 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
        fullscreenbutton.setImage(fullscreenbuttonimg, forState: .Normal)
        fullscreenbutton.addTarget(self, action: "hidetoolbar", forControlEvents: .TouchUpInside)
        
        let homebuttonimg = UIImage(named: "home.png")
        homebutton = UIButton()
        homebutton.frame = CGRectMake(view.frame.width / 4 * 2 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
        homebutton.setImage(homebuttonimg, forState: .Normal)
        homebutton.addTarget(self, action: "goHome", forControlEvents: .TouchUpInside)
        
        let sharebuttonimg = UIImage(named: "share.png")
        sharebutton = UIButton()
        sharebutton.frame = CGRectMake(view.frame.width / 4 * 3 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
        sharebutton.setImage(sharebuttonimg, forState: .Normal)
        sharebutton.addTarget(self, action: "toShare", forControlEvents: .TouchUpInside)
        
        let openinsafaributtonimg = UIImage(named: "openinsafari.png")
        openinsafaributton = UIButton()
        openinsafaributton.frame = CGRectMake(view.frame.width / 4 * 4 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
        openinsafaributton.setImage(openinsafaributtonimg, forState: .Normal)
        openinsafaributton.addTarget(self, action: "toOpenInSafari", forControlEvents: .TouchUpInside)
        
        let showfavoritebuttonimg = UIImage(named: "favorites.png")
        showfavoritebutton = UIButton()
        let framewidthmid = view.frame.width / 4 * 1
        let framewidthonemid = (view.frame.width / 4 - 59) / 2
        let framewidthone = framewidthmid - framewidthonemid - 59
        let framewidth = framewidthone + view.frame.width
        showfavoritebutton.frame = CGRectMake(framewidth, 55, 59, 59)
        showfavoritebutton.setImage(showfavoritebuttonimg, forState: .Normal)
        showfavoritebutton.addTarget(self, action: "showFavorites", forControlEvents: .TouchUpInside)
        
        dashboard.delegate = self
        dashboard.frame = CGRectMake(0, view.frame.height - 44 - 120, view.frame.width, 120)
        dashboard.contentSize = CGSizeMake(view.frame.width * 2, 120)
        dashboard.pagingEnabled = true
        dashboard.showsHorizontalScrollIndicator = false
        dashboard.showsVerticalScrollIndicator = false
        dashboard.backgroundColor = UIColor(white: 1, alpha: 0.9)
        dashboard.addSubview(fullscreenbutton)
        dashboard.addSubview(homebutton)
        dashboard.addSubview(sharebutton)
        dashboard.addSubview(openinsafaributton)
        dashboard.addSubview(showfavoritebutton)
        dashboardTitle.frame = CGRectMake(0, 0, view.frame.width, 30)
        dashboardTitle.text = "  Dashboard"
        dashboardTitle.textColor = UIColor(white: 0.5, alpha: 1)
        dashboardTitle.font = UIFont(name: "Arial", size: 15)
        dashboardTitle.backgroundColor = UIColor(white: 0.825, alpha: 1)
        dashboard.addSubview(dashboardTitle)
        dashboardPageControl.frame = CGRectMake(0, 35, view.frame.width, 10)
        dashboardPageControl.numberOfPages = 2
        dashboardPageControl.currentPage = 0
        dashboardPageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        dashboardPageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        dashboard.addSubview(dashboardPageControl)
        
        superHugeRegretButton.addTarget(self, action: "dismissDashboard", forControlEvents: .TouchUpInside)
        superHugeRegretButton.backgroundColor = UIColor.blackColor()
        superHugeRegretButton.alpha = 0.5
        
        let showimg = UIImage(named: "showtoolbar.png")
        showButton.setBackgroundImage(showimg, forState: .Normal)
        showButton.frame = CGRectMake(view.frame.width - 30, view.frame.height - 30, 29, 29)
        showButton.addTarget(self, action: "showtoolbar", forControlEvents: .TouchDown)
        self.view.addSubview(showButton)
        
        progressBar.frame = CGRectMake(0, view.frame.height - 47, view.frame.width, 3)
        self.view.addSubview(progressBar)
        
        /*autocompleteTableView = UITableView(frame: CGRectMake(0, 80, view.frame.width, view.frame.height), style: .Plain)
        //autocompleteTableView.delegate = self
        //autocompleteTableView.dataSource = self
        autocompleteTableView.scrollEnabled = true
        autocompleteTableView.hidden = true
        self.view.addSubview(autocompleteTableView)*/
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: "doRefresh", forControlEvents: .ValueChanged)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName:"UnclosedWebViews")
        unclosedwebviews = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
        if unclosedwebviews.count != 0 {
            for i in 0...unclosedwebviews.count - 1 {
                webViews.insert(WKWebView(), atIndex: webViews.endIndex)
                webViews[i]?.navigationDelegate = self
                webViews[i]?.allowsBackForwardNavigationGestures = true
                webViews[i]?.scrollView.addSubview(refreshControl)
                
                let webview = unclosedwebviews[i]
                let urlstring = webview.valueForKey("webviews") as String?
                if (urlstring != nil) {
                    let url = NSURL(string: urlstring!)
                    let request = NSURLRequest(URL: url!)
                    webViews[i]!.loadRequest(request)
                }
                
                webViews[i]?.frame = CGRectMake(10, view.frame.height + 50, view.frame.width - 20, view.frame.height - 44)
                totalWebView++
            }
            showAllWebViews()
            
            var bas: NSManagedObject!
            for bas in unclosedwebviews {
                managedContext.deleteObject(bas as NSManagedObject)
            }
            unclosedwebviews.removeAll(keepCapacity: false)
        } else {
            webViews.insert(WKWebView(), atIndex: webViews.endIndex)
            webViews[currentWebView]?.allowsBackForwardNavigationGestures = true
            webViews[currentWebView]?.navigationDelegate = self
            webViews[currentWebView]?.scrollView.addSubview(refreshControl)
            webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
            self.view.addSubview(webViews[currentWebView]!)
            totalWebView++
            
            textField.text = homewebpage
            didClickGo()
        }
        
        self.view.bringSubviewToFront(showButton)
        self.view.bringSubviewToFront(toolBar)
        self.view.bringSubviewToFront(progressBar)
        
        if (NSUserDefaults.standardUserDefaults().boolForKey("HasLaunchedOnce")) {
            println("app already launched")
        } else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasLaunchedOnce")
            NSUserDefaults.standardUserDefaults().synchronize()
            println("This is the first launch ever")
            var demoViewController: DemoViewController = DemoViewController()
            var DemoNavigationController = UINavigationController(rootViewController: demoViewController)
            self.navigationController?.presentViewController(DemoNavigationController, animated: false, completion: nil)
        }
    }
    
    /*override func viewDidLoad() {
    super.viewDidLoad()
    
    }*/
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if  NSUserDefaults.standardUserDefaults().stringForKey("homeurl") != nil {
            homewebpage = NSUserDefaults.standardUserDefaults().stringForKey("homeurl")!
        } else {
            homewebpage = "google.com"
        }
        if homewebpage.substringFromIndex(homewebpage.endIndex.predecessor()) != "/" {
            homewebpage = homewebpage + "/"
            NSUserDefaults.standardUserDefaults().setValue(homewebpage, forKey: "homeurl")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        if !homewebpage.hasPrefix("http://") {
            homewebpage = "http://" + homewebpage
            NSUserDefaults.standardUserDefaults().setValue(homewebpage, forKey: "homeurl")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        registerForNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSURLCache.sharedURLCache().removeAllCachedResponses()
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = appDelegate.managedObjectContext!
        let entity =  NSEntityDescription.entityForName("UnclosedWebViews", inManagedObjectContext: managedContext)
        
        var bas: NSManagedObject!
        for bas in unclosedwebviews
        {
            managedContext.deleteObject(bas as NSManagedObject)
        }
        unclosedwebviews.removeAll(keepCapacity: false)
        
        for i in 0...webViews.count - 1 {
            if (webViews[i]?.URL?.absoluteString != nil) && (webViews[i]?.URL?.absoluteString != homewebpage) {
                let webview = NSManagedObject(entity: entity!, insertIntoManagedObjectContext:managedContext)
                
                webview.setValue(webViews[i]?.URL?.absoluteString, forKey: "webviews")
                
                var error: NSError?
                if !managedContext.save(&error) {
                    println("Could not save \\(error), \(error?.userInfo)")
                }
                
                unclosedwebviews.append(webview)
            }
        }
    }
    
    
//////////Regular funcs
    func configtextField() {
        textField = URLTextField()
        textField.parentViewController = self
        textField.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
        textField.addTarget(self, action: "didClickGo", forControlEvents: .EditingDidEndOnExit)
    }
    
    func configtoolbaritems() {
        var toolBarItems = [
            flexibleSpaceBarButtonItem,
            backButton,
            flexibleSpaceBarButtonItem,
            forwardButton,
            flexibleSpaceBarButtonItem,
            textItem,
            flexibleSpaceBarButtonItem,
            webViewSwitch
        ]
        
        toolBar.setItems(toolBarItems, animated: true)
    }
    
    func registerForNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidHidden:", name: UIKeyboardDidHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "orientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    func checkGos() {
        if webViews[currentWebView]!.canGoBack {
            backButton.enabled = true
        } else {
            backButton.enabled = false
        }
        if webViews[currentWebView]!.canGoForward {
            forwardButton.enabled = true
        } else {
            forwardButton.enabled = false
        }
    }
    
    func lettextfieldtohost() {
        if (!textField.isFirstResponder() && ((webViews[currentWebView]?.URL?.absoluteString != nil)/* && ((webViews[currentWebView]?.URL?.absoluteString != "") && (webViews[currentWebView]?.canGoBack == false) && (webViews[currentWebView]?.canGoForward == false))*/)){
            let theurl: String! = webViews[currentWebView]?.URL?.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let urlhost: String! = webViews[currentWebView]?.URL?.host
            println("Finished navigating to url \(urlhost)")
            if webViews[currentWebView]?.URL?.host != nil{
                if ((((theurl.hasPrefix("http://www.google.com/search?q=")) || (theurl.hasPrefix("https://www.google.com/search?q=")))) && (theurl.hasSuffix("gws_rd=ssl"))) {
                    var str: String! = webViews[currentWebView]?.URL?.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    let strstartindex = str.startIndex
                    str = str?.substringFromIndex(advance(strstartindex, 32))
                    let strendindex = str.endIndex
                    str = str?.substringToIndex(advance(strendindex, -11))
                    str = "🔍" + str
                    textField.text = str
                } else if (((theurl.hasPrefix("http://www.baidu.com/s?wd=")) || (theurl.hasPrefix("https://www.baidu.com/s?wd="))) && (!(theurl.hasSuffix("&cl=3")) && !(theurl.hasSuffix("&cl=2")))) {
                    var str: String! = webViews[currentWebView]?.URL?.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                    let strstartindex = str.startIndex
                    str = str?.substringFromIndex(advance(strstartindex, 26))
                    str = "🔍" + str
                    textField.text = str
                } else if (urlhost?.hasPrefix("www.") == true) {
                    let strr = NSString(string: urlhost!)
                    let sttr = strr.substringFromIndex(4)
                    textField.text = sttr
                } else  {
                    textField.text = urlhost
                }
            } else {
                textField.text = ""
            }
            if (webViews[currentWebView]?.hasOnlySecureContent == true) {
                textField.text = "🔒" + textField.text
            }
        } else if (!textField.isFirstResponder()) {
            textField.text = "An Error has occurred."
        }
    }
    
    func checkifdnsrsearch() {
        if webViews[currentWebView]?.URL?.absoluteString?.hasPrefix("http://www.dnsrsearch.com/index.php?origURL=") == true {
            webViews[currentWebView]?.stopLoading()
            let textfieldtext = webViews[currentWebView]?.URL?.absoluteString
            var text = NSString(string: textfieldtext!)
            text = text.substringFromIndex(53)
            text = text.substringToIndex(text.length - 4)
            if (defaultSearchEngine == "0") {
                text = "http://www.google.com/search?q=" + text
            } else if (defaultSearchEngine == "1") {
                text = "http://www.baidu.com/s?wd=" + text
            }
            let url = NSURL(string: text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            var request = NSURLRequest(URL: url!)
            webViews[currentWebView]?.loadRequest(request)
        }
    }
    
    func orientationDidChange(sender: NSNotification) {
        if ((UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) && !orientationchanged) || (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) && orientationchanged)) {
            if !showingAllWebViews{
                if (toolBar.hidden == false) {
                    webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
                    progressBar.frame = CGRectMake(0, view.frame.height - 47, view.frame.width, 3)
                } else {
                    webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
                    progressBar.frame = CGRectMake(0, view.frame.height - 3, view.frame.width, 3)
                }
            } else {
                if (toolBar.hidden == false) {
                    progressBar.frame = CGRectMake(0, view.frame.height - 47, view.frame.width, 3)
                } else {
                    progressBar.frame = CGRectMake(0, view.frame.height - 3, view.frame.width, 3)
                }
                for tryShowingWebView in 0...webViews.count - 1 {
                    webViews[tryShowingWebView]?.frame = CGRectMake(20, CGFloat(200 * tryShowingWebView) + weby, view.frame.width - 40, view.frame.height - 10)
                    webViewButtons[tryShowingWebView]?.frame = CGRectMake(0, 0, view.frame.width - 40, view.frame.height)
                    webViewLabels[tryShowingWebView]?.frame = CGRectMake(0, 0, view.frame.width - 40, 20)
                }
                adbanner.frame = CGRectMake(5, 0, self.view.frame.width - 10, 50)
                self.view.bringSubviewToFront(toolBar)
            }
            
            //backgroundimage.frame = CGRectMake(abs(view.frame.width - view.frame.height) / 2, 0, sort(&[view.frame.width,view.frame.height]), view.frame.width)
            
            toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
            textField.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            showButton.frame = CGRectMake(view.frame.width - 30, view.frame.height - 30, 29, 29)
            superHugeRegretButton.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
            dashboard.frame = CGRectMake(0, view.frame.height - 44 - 120, view.frame.width, 120)
            dashboard.contentSize = CGSizeMake(view.frame.width * 2,120)
            dashboardTitle.frame = CGRectMake(dashboard.contentOffset.x, 0, view.frame.width, 30)
            dashboardPageControl.frame = CGRectMake(dashboard.contentOffset.x, 35, view.frame.width, 10)
            fullscreenbutton.frame = CGRectMake(view.frame.width / 4 * 1 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
            homebutton.frame = CGRectMake(view.frame.width / 4 * 2 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
            sharebutton.frame = CGRectMake(view.frame.width / 4 * 3 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
            openinsafaributton.frame = CGRectMake(view.frame.width / 4 * 4 - (view.frame.width / 4 - 59) / 2 - 59, 55, 59, 59)
            let framewidthmid = view.frame.width / 4 * 1
            let framewidthonemid = (view.frame.width / 4 - 59) / 2
            let framewidthone = framewidthmid - framewidthonemid - 59
            let framewidth = framewidthone + view.frame.width
            showfavoritebutton.frame = CGRectMake(framewidth, 55, 59, 59)
            
            if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
                orientationchanged = true
            } else {
                orientationchanged = false
            }
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        textField.configstopImage()
        checkifdnsrsearch()
        lettextfieldtohost()
        progressBar.setProgress(0.1, animated: false)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 1 }, nil)
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation){
        progressBar.setProgress(Float(webViews[currentWebView]!.estimatedProgress) + 0.01, animated: true)
        textField.configstopImage()
        checkifdnsrsearch()
        lettextfieldtohost()
    }
    
    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        checkGos()
        lettextfieldtohost()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.endRefreshing()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        /*if textField.text != nil {
            var requesturl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ultra_Simple_Browser_Internet_Error", ofType: "html")!)
            var request = NSURLRequest(URL: requesturl!)
            webView.loadRequest(request)
            textField.text = error.localizedDescription
        }*/
        lettextfieldtohost()
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.endRefreshing()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        /*if textField.text != nil {
            var requesturl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ultra_Simple_Browser_Internet_Error", ofType: "html")!)
            var request = NSURLRequest(URL: requesturl!)
            webView.loadRequest(request)
            textField.text = error.localizedDescription
        }*/
        lettextfieldtohost()
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.endRefreshing()
    }
    
    func keyboardWillBeShown(sender: NSNotification) {
        println("keyboardWillBeShown")
        let info: NSDictionary = sender.userInfo!
        let value: AnyObject? = info.objectForKey(UIKeyboardFrameEndUserInfoKey)
        let keyboardSize: CGSize! = value?.CGRectValue().size
        
        if adbanner.bannerLoaded {
            toolBar.frame = CGRectMake(0, view.frame.height - keyboardSize.height - 94, view.frame.width, 44)
            adbanner.frame = CGRectMake(0, view.frame.height - keyboardSize.height - 50, view.frame.width, 50)
            self.view.addSubview(adbanner)
        } else {
            toolBar.frame = CGRectMake(0, view.frame.height - keyboardSize.height - 44, view.frame.width, 44)
        }
        if childSuggestionsViewController.view.window != nil {
            childSuggestionsViewController.view.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - keyboardSize.height - 44)
            childSuggestionsViewController.suggestionsTableView.frame = childSuggestionsViewController.view.frame
        }
    }
    
    func keyboardWillBeHidden(sender: NSNotification) {
        toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        adbanner.removeFromSuperview()
    }
    
    func keyboardDidHidden(sender: NSNotification) {
        if toolBar.frame.origin.y != view.frame.height - 44 {
            toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        }
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        //dismissDashboard()
        
        var cancelBarItem: UIBarButtonItem!
        
        cancelBarItem = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "cancelInput")
        
        var toolBarItems = [
            textItem,
            flexibleSpaceBarButtonItem,
            cancelBarItem
        ]
        toolBar.setItems(toolBarItems, animated: true)
        edgeSwipe.enabled = false
        
        textField.frame = CGRectMake(0, 0, view.frame.width - 100, 30)
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = false
        textField.text = webViews[currentWebView]?.URL?.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        textField.textAlignment = .Left
        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
        
        childSuggestionsViewController = SuggestionsViewController()
        self.addChildViewController(childSuggestionsViewController)
        childSuggestionsViewController.suggestionsParentViewController = self
        childSuggestionsViewController.view.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        self.view.addSubview(childSuggestionsViewController.view)
        childSuggestionsViewController.didMoveToParentViewController(self)
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.frame = CGRectMake(0, 0, view.frame.width - 125, 30)
        configtoolbaritems()
        edgeSwipe.enabled = true
        
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .Center
        
        childSuggestionsViewController.willMoveToParentViewController(nil)
        childSuggestionsViewController.view.removeFromSuperview()
        childSuggestionsViewController.removeFromParentViewController()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didClickGo()
        lettextfieldtohost()
        return false
    }
    
    func textFieldDidChanged() {
        var substring: String = textField.text
        //substring = substring.stringByReplacingCharactersInRange(range, withString: string)
        childSuggestionsViewController.searchAutocompleteEntriesWithSubstring(substring)
        childSuggestionsViewController.suggestionsTableView.reloadData()
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat = scrollView.frame.size.width
        var contentoffsetx: CGFloat = scrollView.contentOffset.x
        var fractionalPage = contentoffsetx / pageWidth
        var page: NSInteger = lroundf(Float(fractionalPage))
        dashboardPageControl.currentPage = page
        dashboardPageControl.frame = CGRectMake(contentoffsetx, 35, view.frame.width, 10)
        dashboardTitle.frame = CGRectMake(contentoffsetx, 0, view.frame.width, 30)
    }
    
    func didClickGo() {
        dismissDashboard()
        
        var oritext:String = textField.text
        var text = oritext
        if text.hasPrefix("🔒") {
            let textmid: NSString = NSString(string: text)
            text = String(textmid.substringFromIndex(2))
        }
        if !URLHasInternetProtocalPrefix(text) {
            text = "http://" + text
        }
        if (text != webViews[currentWebView]?.URL?.absoluteString) {
            if !URLIsValid(text) {
                searchURL(oritext)
            } else {
                loadURLRegularly(text)
            }
        }
    }
    
    func URLHasInternetProtocalPrefix(urlstring: String) -> Bool {
        return (urlstring.hasPrefix("http://") || urlstring.hasPrefix("https://") || urlstring.hasPrefix("ftp://") || urlstring.hasPrefix("ftps://"))
    }
    
    func URLIsValid(urlstring: String) -> Bool {
        let urlString: NSString = NSString(string: urlstring)
        let urlRegEx = "^((http|https|ftp|ftps)://)*(w{0,3}\\.)*([0-9a-zA-Z-_]*)\\.([0-9a-zA-Z]*)(/{0,1})([0-9a-zA-Z-_./?%&=:\\s]*)$"
        //"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        //"^(http|https|ftps)://([\\\\w-]+\\.)+[\\\\w-]+(/[\\\\w-./?%&=]*)?$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
        let urlTest = NSPredicate.predicateWithSubstitutionVariables(predicate)
        let isValidURL: Bool = predicate.evaluateWithObject(urlString)
        
        return isValidURL
    }
    
    func loadURLRegularly(urlstring: String) {
        println("\(urlstring)")
        let url = NSURL(string: urlstring)
        println("\(url)")
        let request = NSURLRequest(URL: url!)
        webViews[currentWebView]?.loadRequest(request)
    }
    
    func searchURL(urlstring: String) {
        if (defaultSearchEngine == "1") {
            let text = "http://www.baidu.com/s?wd=" + urlstring
            loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        } else {
            let text = "http://www.google.com/search?q=" + urlstring
            loadURLRegularly(text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        }
    }
    
    func cancelInput() {
        textField.resignFirstResponder()
        lettextfieldtohost()
    }
    
    func goBack() {
        dismissDashboard()
        
        webViews[currentWebView]?.goBack()
    }
    
    func goForward() {
        dismissDashboard()
        
        webViews[currentWebView]?.goForward()
    }
    
    func showGoBackList(rec: UILongPressGestureRecognizer) {
        dismissDashboard()
        
        if rec.state == .Began {
            backForwardFavoriteTableView = BackForwardTableViewController()
            backForwardFavoriteTableView.backForwardParentViewController = self
            backForwardFavoriteTableView.tag = 0
            
            var backForwardNavigationController = UINavigationController(rootViewController: backForwardFavoriteTableView)
            self.navigationController?.presentViewController(backForwardNavigationController, animated: true, completion: nil)
        }
    }
    
    func showGoForwardList(rec: UILongPressGestureRecognizer) {
        dismissDashboard()
        
        if rec.state == .Began {
            backForwardFavoriteTableView = BackForwardTableViewController()
            backForwardFavoriteTableView.backForwardParentViewController = self
            backForwardFavoriteTableView.tag = 1
            
            var backForwardNavigationController = UINavigationController(rootViewController: backForwardFavoriteTableView)
            self.navigationController?.presentViewController(backForwardNavigationController, animated: true, completion: nil)
        }
    }
    
    func hideGoBackForwardFavoritesList() {
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.1)
        
        backForwardFavoriteTableView.dismissSelf()
        configtoolbaritems()
        
        UIView.commitAnimations()
    }
    
    func doRefresh() {
        dismissDashboard()
        
        webViews[currentWebView]?.reload()
    }
    
    func doStop() {
        dismissDashboard()
        
        webViews[currentWebView]?.stopLoading()
        if (webViews[currentWebView]!.URL != nil) {
            textField.text = String(contentsOfURL: webViews[currentWebView]!.URL!)
        }
        checkGos()
        lettextfieldtohost()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: {
            self.progressBar.alpha = 0
        }, completion: nil)
        textField.configrefreshImage()
    }
    
    func displayDashboard() {
        switch edgeSwipe.state {
        case .Changed:
            if edgeSwipe.translationInView(toolBar).y < -20 {
                dashboard.frame = CGRectMake(0, view.frame.height, view.frame.width, 120)
                self.view.addSubview(dashboard)
                superHugeRegretButton.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
                UIView.beginAnimations("animateWebView", context: nil)
                UIView.setAnimationDuration(1)
                self.view.addSubview(superHugeRegretButton)
                UIView.setAnimationDuration(0.2)
                self.view.bringSubviewToFront(dashboard)
                self.view.bringSubviewToFront(toolBar)
                dashboard.frame = CGRectMake(0, view.frame.height - 44 - 120, view.frame.width, 120)
                UIView.commitAnimations()
            }
        default: true
        }
    }
    
    func hidetoolbar() {
        webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        progressBar.frame = CGRectMake(0, view.frame.height - 3, view.frame.width, 3)
        toolBar.hidden = true
        dismissDashboard()
    }
    
    func showtoolbar() {
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.2)
        webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
        progressBar.frame = CGRectMake(0, view.frame.height - 47, view.frame.width, 3)
        toolBar.hidden = false
        UIView.commitAnimations()
    }
    
    func dismissDashboard() {
        if (dashboard.window != nil) {
            UIView.beginAnimations("animateWebView", context: nil)
            UIView.setAnimationDuration(0.5)
            superHugeRegretButton.removeFromSuperview()
            self.view.bringSubviewToFront(toolBar)
            dashboard.frame = CGRectMake(0, view.frame.height, view.frame.width, 120)
            UIView.commitAnimations()
            dashboard.removeFromSuperview()
        }
    }
    
    func toShare() {
        dismissDashboard()
        
        let myWebsite = webViews[currentWebView]?.viewPrintFormatter()
        let myWebsiteurl = webViews[currentWebView]?.URL
        var objectsToShare = []
        
        if myWebsiteurl != nil {
            objectsToShare = [myWebsiteurl!, myWebsite!]
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        self.presentViewController(activityVC, animated: true, completion: nil)
    }
    
    func toOpenInSafari() {
        dismissDashboard()
        
        var myWebsite = webViews[currentWebView]?.URL
        if myWebsite == nil {
            myWebsite = NSURL(string: "")
        }
        
        UIApplication.sharedApplication().openURL(myWebsite!)
    }
    
    func goHome() {
        dismissDashboard()
        
        textField.text = homewebpage
        didClickGo()
    }
    
    func showFavorites() {
        dismissDashboard()
        backForwardFavoriteTableView = BackForwardTableViewController(style: .Grouped)
        backForwardFavoriteTableView.backForwardParentViewController = self
        backForwardFavoriteTableView.tag = 2
        
        var backForwardNavigationController = UINavigationController(rootViewController: backForwardFavoriteTableView)
        self.navigationController?.presentViewController(backForwardNavigationController, animated: true, completion: nil)
    }
    
    func showAllWebViews() {
        dismissDashboard()
        
        showingAllWebViews = true
        
        edgeSwipe.enabled = false
        
        if adbanner.bannerLoaded {
            adbanner.frame = CGRectMake(5, 0, self.view.frame.width - 10, 50)
            self.view.addSubview(adbanner)
        }
        
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.2)
        
        var addNewWebViewButton: UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewWebView")
        var doneShowingAllWebViewsButton: UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "doneShowingAllWebViews")
        
        toolBar.frame = CGRectMake(0, view.frame.height + 10, view.frame.width, 44)
        var toolBarItems = [
            addNewWebViewButton,
            flexibleSpaceBarButtonItem,
            undoWebViewButton,
            flexibleSpaceBarButtonItem,
            doneShowingAllWebViewsButton
        ]
        
        toolBar.setItems(toolBarItems, animated: true)
        
        webViewButtons = []
        webViewCloseSwipe = []
        //webViewCloseLongPress = []
        webViewLabels = []
        
        for tryShowingWebView in 0...webViews.count - 1 {
            webViews[tryShowingWebView]?.frame = CGRectMake(20, CGFloat(200 * tryShowingWebView) + weby, view.frame.width - 40, view.frame.height - 10)
            webViews[tryShowingWebView]?.layer.cornerRadius = 5.0
            webViews[tryShowingWebView]?.layer.shadowColor = UIColor.blackColor().CGColor
            webViews[tryShowingWebView]?.layer.shadowRadius = 5.0
            webViews[tryShowingWebView]?.layer.shadowOffset = CGSizeMake(3.0, 3.0)
            webViews[tryShowingWebView]?.layer.shadowOpacity = 1
            webViews[tryShowingWebView]?.scrollView.layer.cornerRadius = 5.0
            //webViews[tryShowingWebView]?.allowsBackForwardNavigationGestures = false
            //let rotate: CATransform3D = CATransform3DMakeRotation(M_PI/6, 0, 1, 0)
            //webViews[tryShowingWebView]?.scrollView.layer.transform = CATransform3DPerspect(rotate, CGPointMake(0, 0), 200);
            self.view.addSubview(webViews[tryShowingWebView]!)
            
            webViewLabels.insert(UILabel(), atIndex: tryShowingWebView)
            webViewLabels[tryShowingWebView]?.frame = CGRectMake(0, 0, view.frame.width - 40, 20)
            if webViews[tryShowingWebView]?.title != nil {
                webViewLabels[tryShowingWebView]?.text = webViews[tryShowingWebView]?.title
            }
            webViewLabels[tryShowingWebView]?.backgroundColor = UIColor.darkGrayColor()
            webViewLabels[tryShowingWebView]?.textColor = UIColor.whiteColor()
            webViewLabels[tryShowingWebView]?.textAlignment = .Center
            webViewLabels[tryShowingWebView]?.layer.cornerRadius = 5.0
            webViews[tryShowingWebView]?.addSubview(webViewLabels[tryShowingWebView]!)
            
            webViewButtons.insert(UIButton(), atIndex: tryShowingWebView)
            webViewButtons[tryShowingWebView]?.frame = CGRectMake(0, 0, view.frame.width - 40, view.frame.height)
            webViewButtons[tryShowingWebView]?.addTarget(self, action: "showWebView:", forControlEvents: .TouchUpInside)
            webViewButtons[tryShowingWebView]?.tag = tryShowingWebView
            webViews[tryShowingWebView]?.addSubview(webViewButtons[tryShowingWebView]!)
            
            webViewCloseSwipe.insert(UIPanGestureRecognizer(), atIndex: tryShowingWebView)
            webViewButtons[tryShowingWebView]?.addGestureRecognizer(webViewCloseSwipe[tryShowingWebView])
            webViewCloseSwipe[tryShowingWebView].addTarget(self, action: "closeWebView:")
            
            //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: tryShowingWebView)
            //webViewButtons[tryShowingWebView]?.addGestureRecognizer(webViewCloseLongPress[tryShowingWebView])
            //webViewCloseLongPress[tryShowingWebView].addTarget(self, action: <#Selector#>)
        }
        
        toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        self.view.bringSubviewToFront(toolBar)
        
        UIView.commitAnimations()
    }
    
    func doneShowingAllWebViews() {
        adbanner.removeFromSuperview()
        
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.2)
        
        for i in 0...webViews.count - 1 {
            webViews[i]?.removeFromSuperview()
            webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
            //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
            webViewButtons[i]?.removeFromSuperview()
            webViewLabels[i]?.removeFromSuperview()
        }
        webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
        self.view.addSubview(webViews[currentWebView]!)
        
        configtoolbaritems()
        edgeSwipe.enabled = true
        checkGos()
        lettextfieldtohost()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.endRefreshing()
        
        UIView.commitAnimations()
        
        self.view.bringSubviewToFront(showButton)
        self.view.bringSubviewToFront(toolBar)
        self.view.bringSubviewToFront(progressBar)
        
        webViewButtons = []
        webViewCloseSwipe = []
        //webViewCloseLongPress = []
        webViewLabels = []
        
        showingAllWebViews = false
    }
    
    func addNewWebView() {
        webViews.insert(WKWebView(), atIndex: webViews.endIndex)
        currentWebView = webViews.endIndex - 1
        webViews[currentWebView]?.navigationDelegate = self
        webViews[currentWebView]?.allowsBackForwardNavigationGestures = true
        webViews[currentWebView]?.scrollView.addSubview(refreshControl)
        webViewButtons.insert(UIButton(), atIndex: webViews.count - 1)
        webViewCloseSwipe.insert(UIPanGestureRecognizer(), atIndex: webViews.count - 1)
        //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: webViews.count - 1)
        webViewLabels.insert(UILabel(), atIndex: webViews.count - 1)
        UIView.commitAnimations()
        webViews[currentWebView]?.frame = CGRectMake(10, view.frame.height + 50, view.frame.width - 20, view.frame.height - 44)
        webViews[currentWebView]?.layer.cornerRadius = 5.0
        webViews[currentWebView]?.layer.shadowColor = UIColor.blackColor().CGColor
        webViews[currentWebView]?.layer.shadowRadius = 5.0
        webViews[currentWebView]?.layer.shadowOffset = CGSizeMake(3.0, 3.0)
        webViews[currentWebView]?.layer.shadowOpacity = 1
        webViews[currentWebView]?.scrollView.layer.cornerRadius = 5.0
        
        doneShowingAllWebViews()
        
        textField.becomeFirstResponder()
        
        totalWebView++
    }
    
    func showWebView(sender: UIButton) {
        currentWebView = sender.tag
        doneShowingAllWebViews()
    }
    
    func undoPreviousWebView() {
        undoWebViewButton.enabled = false
        webViews.insert(undoWebView, atIndex: webViews.endIndex)
        currentWebView = webViews.endIndex - 1
        webViews[currentWebView]?.navigationDelegate = self
        webViews[currentWebView]?.allowsBackForwardNavigationGestures = true
        webViewButtons.insert(UIButton(), atIndex: webViews.count - 1)
        webViewCloseSwipe.insert(UIPanGestureRecognizer(), atIndex: webViews.count - 1)
        //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: webViews.count - 1)
        webViewLabels.insert(UILabel(), atIndex: webViews.count - 1)
        webViews[currentWebView]?.frame = CGRectMake(10, view.frame.height + 50, view.frame.width - 20, view.frame.height - 44)
        
        doneShowingAllWebViews()
        totalWebView++
    }
    
    func closeWebView(rec: UIPanGestureRecognizer) {
        let y = rec.view?.tag
        let z = y!
        
        switch rec.state {
        case .Began:
            if !isLongPressed {
                if rec.view != nil {
                }
                let webby = webViews[0]?.frame
                let webbby = webby?.origin
                let webbbby = webby?.origin.y
                weby = CGFloat(webbbby!)
            } else {
                
            }
        case .Changed:
            if !isLongPressed {
                if panInit < 5 {
                    panInit++
                } else if panInit == 5 {
                    if abs(rec.translationInView(self.view!).x) > abs(rec.translationInView(self.view!).y) {
                        panInitdir = true
                    } else {
                        panInitdir = false
                    }
                    panInit++
                } else if (rec.view != nil) && (panInitdir) && (panInit > 5) && (rec.translationInView(rec.view!).x > 0) {
                    let originx = 5
                    let originy = webViews[z]?.frame.origin.y
                    let newx = rec.translationInView(self.view).x
                    let originw = webViews[z]?.frame.width
                    let originh = webViews[z]?.frame.height
                    let myframe = CGRectMake(5 + newx, originy!, originw!, originh!)
                    webViews[z]?.frame = myframe
                    let alpha = newx / 200
                    if (alpha > 1) || (alpha < -1) {
                    } else if alpha > 0 {
                        webViews[z]?.alpha = 1 - alpha
                    } else {
                        webViews[z]?.alpha = 1 - (0 - alpha)
                    }
                } else if (rec.view != nil) && (panInitdir) && (panInit > 5) && (rec.translationInView(self.view!).x < 0) {
                    /*
                    let transy = rec.translationInView(self.view!).y
                    
                    if transy < -20 {
                    let content = webViews[z]?.scrollView
                    let contentoffset = content?.contentOffset
                    let contentx = contentoffset?.x
                    let contenty = contentoffset?.y
                    content?.setContentOffset(CGPointMake(contentx!, contenty! - 20), animated: true)
                    } else if transy > 20 {
                    let content = webViews[z]?.scrollView
                    let contentoffset = content?.contentOffset
                    let contentx = contentoffset?.x
                    let contenty = contentoffset?.y
                    content?.setContentOffset(CGPointMake(contentx!, contenty! + 20), animated: true)
                    
                    }*/
                } else if (rec.view != nil) && (!panInitdir) {
                    if rec.translationInView(self.view).y < 0 {
                        let weboriginy = webViews[totalWebView - 1]?.frame.maxY
                        if weboriginy! > view.frame.height {
                            for i in 0...webViews.count - 1 {
                                webViews[i]?.frame = CGRectMake(20, weby + 200 * CGFloat(i) + rec.translationInView(self.view!).y, view.frame.width - 40, view.frame.height)
                            }
                        }
                    } else if rec.translationInView(self.view).y > 0 {
                        if webViews[0]?.frame.origin.y < 0 {
                            for i in 0...webViews.count - 1 {
                                webViews[i]?.frame = CGRectMake(20, weby + 200 * CGFloat(i) + rec.translationInView(self.view!).y, view.frame.width - 40, view.frame.height)
                            }
                        }
                    }
                }
            } else {
                //change the order of the webViews with long press
                println("changing the order of the webViews with long press")
            }
        case .Ended:
            if !isLongPressed {
                if (panInitdir) {
                    if (Int(rec.translationInView(webViews[z]!).x) > 150) {
                        webViews[z]?.alpha = 1
                        undoWebView = webViews[z]
                        undoWebViewButton.enabled = true
                        webViewLabels[z]?.removeFromSuperview()
                        webViewLabels.removeAtIndex(z)
                        webViewButtons[z]?.removeFromSuperview()
                        webViewButtons.removeAtIndex(z)
                        webViews[z]?.removeFromSuperview()
                        webViews.removeAtIndex(z)
                        totalWebView--
                        currentWebView = webViews.endIndex - 1
                        if totalWebView < 1 {
                            addNewWebView()
                        } else {
                            for i in 0...webViews.count - 1 {
                                webViewLabels[i]?.removeFromSuperview()
                                webViews[i]?.removeFromSuperview()
                                webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                                //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                                webViewButtons[i]?.removeFromSuperview()
                            }
                            
                            self.view.bringSubviewToFront(showButton)
                            self.view.bringSubviewToFront(toolBar)
                            self.view.bringSubviewToFront(progressBar)
                            
                            webViewButtons = []
                            webViewCloseSwipe = []
                            //webViewCloseLongPress = []
                            webViewLabels = []
                            
                            showAllWebViews()
                        }
                    } else {
                        let myframe = CGRectMake(20, weby + 200 * CGFloat(z), view.frame.width - 40, view.frame.height)
                        webViews[z]?.frame = myframe
                        webViews[z]?.alpha = 1
                    }
                } else if (!panInitdir) {
                    let webby = webViews[0]?.frame
                    let webbby = webby?.origin
                    let webbbby = webby?.origin.y
                    weby = CGFloat(webbbby!)
                }
                panInit = 0
            } else {
                //change order of web views
                println("end of changing the order of the webViews with long press")
            }
        default: true
        }
    }
    
    func longPressed(press: UILongPressGestureRecognizer) {
        switch press.state {
        case .Began:
            isLongPressed = true
        case .Cancelled:
            isLongPressed = false
        case .Ended:
            isLongPressed = false
        default: true
        }
    }
    
}