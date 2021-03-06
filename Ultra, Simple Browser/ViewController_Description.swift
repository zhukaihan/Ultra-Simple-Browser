//
//  ViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 14/12/6.
//  Copyright (c) 2014年 Peter Zhu. All rights reserved.
//
//although it is created on 14/12/6, code starts generated on 14/11/2


import UIKit  //Foundation included in
import WebKit
import iAd
import QuartzCore
import CoreData

class ViewController: UIViewController, UIContentContainer, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate,  UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    
    //////////Variables
    var homewebpage : String!
    var statusbarpref = NSUserDefaults.standardUserDefaults().boolForKey("preferstatusbarhidden")
    var defaultSearchEngine = NSUserDefaults.standardUserDefaults().stringForKey("searchtype")
    var unclosedwebviews = [NSManagedObject]()
    var Favoriteitems = [NSManagedObject]()
    
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
    var backForwardFavoriteTableView: UITableView! = UITableView()
    //var autocompleteTableView: UITableView!
    
    var addNewFavoriteTableViewController: NewFavoriteItemTableViewController! = NewFavoriteItemTableViewController()
    
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
    var textField: UITextField! = UITextField()
    
    var progressBar: UIProgressView! = UIProgressView(progressViewStyle: .Bar)
    
    var adbanner: ADBannerView! = ADBannerView()
    
    
    
    //////////Override funcs
    ////config UI
    override func loadView() {
        super.loadView()
        
        if  NSUserDefaults.standardUserDefaults().stringForKey("homeurl") != nil {
            homewebpage = NSUserDefaults.standardUserDefaults().stringForKey("homeurl")!
        } else {
            homewebpage = "google.com"
        }
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        let backgroundimage = UIImageView(image: UIImage(named: "icon.png")!)
        backgroundimage.frame = CGRectMake(0, 0, view.frame.width, view.frame.width)
        self.view.addSubview(backgroundimage)
        
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
        
        configtextField()
        configrefreshImage()
        textField.delegate = self
        
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
        let framewidthone = view.frame.width / 4 * 1 - (view.frame.width / 4 - 59) / 2 - 59
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
        dashboardTitle.text = " Dashboard"
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
    }
    
    /*override func viewDidLoad() {
    super.viewDidLoad()
    
    }*/
    
    ////register for notifications, b/c removed notification after viewWillDisappear
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
        statusbarpref = NSUserDefaults.standardUserDefaults().boolForKey("preferstatusbarhidden")
        if !homewebpage.hasPrefix("http://") {
            homewebpage = "http://" + homewebpage
            NSUserDefaults.standardUserDefaults().setValue(homewebpage, forKey: "homeurl")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        if ((addNewFavoriteTableViewController.viewshowed) && (addNewFavoriteTableViewController.clickedDone)) {
            addFavorites()
        }
        
        registerForNotifications()
    }
    
    ////no idea what to do
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    ////full screen
    override func prefersStatusBarHidden() -> Bool {
        return statusbarpref
    }
    
    ////clear saved opened webviews in datamodeld and save new opening webviews, remove notifications
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
    ////configuring textfield seems a lot of work, seperated
    func configtextField() {
        textField.leftViewMode = .UnlessEditing
        textField.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
        textField.tintColor = UIColor.grayColor()
        textField.textAlignment = .Center
        textField.returnKeyType = .Go
        textField.placeholder = "Enter URL or Search"
        textField.adjustsFontSizeToFitWidth = true
        textField.clearButtonMode = .WhileEditing
        textField.keyboardType = .WebSearch
        textField.spellCheckingType = .No
        textField.autocapitalizationType = .None
        textField.autocorrectionType = .No
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: "didClickGo", forControlEvents: .EditingDidEndOnExit)
    }
    
    ////trun the leftview of textfield to refresh
    func configrefreshImage() {
        let refreshImage = UIImage(named: "refreshimage.png")!
        let refreshImageButton = UIButton.buttonWithType(.Custom) as UIButton
        refreshImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        refreshImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        refreshImageButton.setImage(refreshImage, forState: .Normal)
        refreshImageButton.addTarget(self, action: "doRefresh", forControlEvents: .TouchUpInside)
        textField.leftView = refreshImageButton
    }
    
    ////trun the leftview of textfield to stop
    func configstopImage() {
        let stopImage = UIImage(named: "stopimage.png")!
        let stopImageButton = UIButton.buttonWithType(.Custom) as UIButton
        stopImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        stopImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        stopImageButton.setImage(stopImage, forState: .Normal)
        stopImageButton.addTarget(self, action: "doStop", forControlEvents: .TouchUpInside)
        textField.leftView = stopImageButton
    }
    
    ////trun toolbar items into normal items
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
    
    ////register for notifications
    func registerForNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: "keyboardWillBeShown:", name: UIKeyboardWillShowNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardWillBeHidden:", name: UIKeyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "keyboardDidHidden:", name: UIKeyboardDidHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: "orientationDidChange:", name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    ////see if currentwebview can go back or forward
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
    
    ////trun the text in textfield to host of the url of the currentwebview
    func lettextfieldtohost() {
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
    }
    
    //chech if the url is redirected to dnsrsearch.com because the url user input does not exist
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
    
    ////change frames when orentation changed
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
                    webViewLabels[tryShowingWebView]?.frame = CGRectMake(0, 0, view.frame.width - 40, 20)
                }
                adbanner.frame = CGRectMake(5, 0, self.view.frame.width - 10, 50)
                self.view.bringSubviewToFront(toolBar)
            }
            
            if (backForwardFavoriteTableView.window != nil) {
                backForwardFavoriteTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
            }
            
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
            let framewidthone = view.frame.width / 4 * 1 - (view.frame.width / 4 - 59) / 2 - 59
            let framewidth = framewidthone + view.frame.width
            showfavoritebutton.frame = CGRectMake(framewidth, 55, 59, 59)
            
            if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
                orientationchanged = true
            } else {
                orientationchanged = false
            }
        }
    }
    
    ////do sth when a page start to load
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        configstopImage()
        checkifdnsrsearch()
        if !textField.isFirstResponder(){
            lettextfieldtohost()
        }
        progressBar.setProgress(0.1, animated: false)
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        UIView.animateWithDuration(0.3, delay: 0, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 1 }, nil)
    }
    
    ////do sth when loading a page
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation){
        progressBar.setProgress(Float(webViews[currentWebView]!.estimatedProgress) + 0.01, animated: true)
        configstopImage()
        checkifdnsrsearch()
        if !textField.isFirstResponder(){
            lettextfieldtohost()
        }
    }
    
    ////do sth when a page finish loading
    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        checkGos()
        if !textField.isFirstResponder(){
            lettextfieldtohost()
        }
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        configrefreshImage()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.endRefreshing()
    }
    
    ////do sth when page failed starting load
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        //let path = NSBundle.mainBundle().pathForResource("Error", ofType: "html", inDirectory: "SimpleBrowser")
        //var requesturl = NSURL(string: path!);
        //var request = NSURLRequest(URL: requesturl!);
        //webViews[currentWebView]!.loadRequest(request)
        //textField.text = "Error"
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        configrefreshImage()
        refreshControl.endRefreshing()
    }
    
    ////do sth when page failed loading
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        //let path = NSBundle.mainBundle().pathForResource("Error", ofType: "html")
        //var requestURL = NSURL(string: path!);
        //var request = NSURLRequest(URL: requestURL!);
        //webViews[currentWebView]!.loadRequest(request)
        //textField.text = "Error"
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animateWithDuration(0.3, delay: 0.5, options: .CurveEaseInOut, animations: { self.progressBar.alpha = 0 }, completion: nil)
        configrefreshImage()
        refreshControl.endRefreshing()
    }
    
    ////move the toolbar up when keyboard shown and add a advertisement banner to view
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
        println("\(keyboardSize.height)")
    }
    
    ////place toolbar back and remove advertisement banner frome view
    func keyboardWillBeHidden(sender: NSNotification) {
        toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        adbanner.removeFromSuperview()
    }
    
    ////if toolbar is not back in place, put it back
    func keyboardDidHidden(sender: NSNotification) {
        if toolBar.frame.origin.y != view.frame.height - 44 {
            toolBar.frame = CGRectMake(0, view.frame.height - 44, view.frame.width, 44)
        }
    }
    
    ////usr start search or input url, so change toolbar items to longer textfield and a cancel button
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
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
    
    ////config textField for user input
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = false
        textField.text = webViews[currentWebView]?.URL?.absoluteString?.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        textField.textAlignment = .Left
        textField.selectedTextRange = textField.textRangeFromPosition(textField.beginningOfDocument, toPosition: textField.endOfDocument)
    }
    
    //config textField for regular environment
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        textField.frame = CGRectMake(0, 0, view.frame.width - 125, 30)
        configtoolbaritems()
        edgeSwipe.enabled = true
        
        return true
    }
    
    //config textField for regular environment
    func textFieldDidEndEditing(textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .Center
    }
    
    //user clicked go in keyboard
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didClickGo()
        lettextfieldtohost()
        return false
    }
    /*
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    self.view.bringSubviewToFront(autocompleteTableView)
    self.view.bringSubviewToFront(toolBar)
    autocompleteTableView.hidden = false
    
    var substring: NSString = NSString(string: textField.text)
    substring = substring.stringByReplacingCharactersInRange(range, withString: string)
    self.searchAutocompleteEntriesWithSubstring(substring)
    return true
    }
    
    func searchAutocompleteEntriesWithSubstring(substring: NSString) {
    let pastUrls: [NSString] = ["google.com"]
    var autocompleteUrls: [NSString] = ["google.com"]
    autocompleteUrls.removeAll(keepCapacity: false)
    for curString: NSString in pastUrls {
    var substringRange: NSRange = curString.rangeOfString(substring)
    if (substringRange.location == 0) {
    autocompleteUrls.append(curString)
    }
    }
    
    autocompleteTableView.reloadData()
    }
    */
    
    //the amount of back items or forward items
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if backForwardFavoriteTableView.tag == 0 {
            let number = webViews[currentWebView]?.backForwardList.backList.count
            return number!
        } else if backForwardFavoriteTableView.tag == 1 {
            let number = webViews[currentWebView]?.backForwardList.forwardList.count
            return number!
        } else if backForwardFavoriteTableView.tag == 2 {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            let fetchRequest = NSFetchRequest(entityName:"Favorites")
            Favoriteitems = managedContext.executeFetchRequest(fetchRequest, error: nil) as [NSManagedObject]!
            let number = Favoriteitems.count - 1
            return number
        } else {
            return 0
        }
    }
    
    //display title of back or forward items
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("cellforrowatindexpath")
        let tableviewcell = UITableViewCell()
        //tableviewcell.textLabel?.text = webViews[currentWebView]?.backForwardList.backItem?.title
        if backForwardFavoriteTableView.tag == 0 {
            tableviewcell.textLabel?.text = webViews[currentWebView]?.backForwardList.itemAtIndex(0 - indexPath.row - 1)?.title
        } else if backForwardFavoriteTableView.tag == 1 {
            tableviewcell.textLabel?.text = webViews[currentWebView]?.backForwardList.itemAtIndex(indexPath.row + 1)?.title
        } else if backForwardFavoriteTableView.tag == 2 {
            if Favoriteitems.count != 0 {
                let theFavoriteitem = Favoriteitems[indexPath.row]
                let urlstring = theFavoriteitem.valueForKey("title") as String?
                tableviewcell.textLabel?.text = urlstring
            }
        }
        //return webViews[currentWebView]?.backForwardList.backList.first as UITableViewCell
        return tableviewcell
    }
    
    //go to the back of forward items
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        hideGoBackForwardFavoritesList()
        var thewknavitem = webViews[currentWebView]?.backForwardList.itemAtIndex(0)
        if backForwardFavoriteTableView.tag == 0 {
            thewknavitem = webViews[currentWebView]?.backForwardList.itemAtIndex(0 - indexPath.row - 1)
            webViews[currentWebView]?.goToBackForwardListItem(thewknavitem!)
        } else if backForwardFavoriteTableView.tag == 1 {
            thewknavitem = webViews[currentWebView]?.backForwardList.itemAtIndex(indexPath.row + 1)
            webViews[currentWebView]?.goToBackForwardListItem(thewknavitem!)
        } else if backForwardFavoriteTableView.tag == 2 {
            let theFavoriteitem = Favoriteitems[indexPath.row]
            let urlstring = theFavoriteitem.valueForKey("url") as String?
            textField.text = urlstring
            didClickGo()
        }
    }
    
    //if tableView is used for displaying favorites, it can edit, else, no.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if backForwardFavoriteTableView.tag == 2 {
            return true
        } else {
            return false
        }
    }
    
    //delete one favorite bookmark
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            let managedContext = appDelegate.managedObjectContext!
            managedContext.deleteObject(Favoriteitems[indexPath.row])
            //tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "tableReload", userInfo: nil, repeats: false)
        }
    }
    
    //always return 1
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    //the dashboard "fixed" position item
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat = scrollView.frame.size.width // you need to have a **iVar** with getter for scrollView
        var contentoffsetx: CGFloat = scrollView.contentOffset.x
        var fractionalPage = contentoffsetx / pageWidth
        var page: NSInteger = lroundf(Float(fractionalPage))
        dashboardPageControl.currentPage = page
        dashboardPageControl.frame = CGRectMake(contentoffsetx, 35, view.frame.width, 10)
        dashboardTitle.frame = CGRectMake(contentoffsetx, 0, view.frame.width, 30)
    }
    
    //to go to url or search
    func didClickGo() {
        dismissDashboard()
        
        var oritext:String = textField.text
        var text = oritext
        if text.hasPrefix("🔒") {
            let textmid: NSString = NSString(string: text)
            text = String(textmid.substringFromIndex(2))
        }
        if !(text.hasPrefix("http://")) && !(text.hasPrefix("https://")) {
            text = "http://" + text
        }
        if (text != webViews[currentWebView]?.URL?.absoluteString) {
            var url:NSURL? = NSURL(string:text)
            
            let urlString: NSString = NSString(string: text)
            let urlRegEx = "^((http|https|ftps)://)*(w{0,3}\\.)*([0-9a-zA-Z-_]*)\\.([0-9a-zA-Z]*)(/{0,1})([0-9a-zA-Z-./?%&=]*)$"
            //"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
            //"^(http|https|ftps)://([\\\\w-]+\\.)+[\\\\w-]+(/[\\\\w-./?%&=]*)?$"
            let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
            let urlTest = NSPredicate.predicateWithSubstitutionVariables(predicate)
            let isValidURL: Bool = predicate.evaluateWithObject(urlString)
            
            if !isValidURL {
                if (defaultSearchEngine == "0") {
                    text = "http://www.google.com/search?q=" + oritext
                } else if (defaultSearchEngine == "1") {
                    text = "http://www.baidu.com/s?wd=" + oritext
                }
                url = NSURL(string: text.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
            }
            var request = NSURLRequest(URL: url!)
            webViews[currentWebView]?.loadRequest(request)
        }
    }
    
    //cancel inputing url or search keywords
    func cancelInput() {
        textField.resignFirstResponder()
        lettextfieldtohost()
    }
    
    //to go back
    func goBack() {
        dismissDashboard()
        
        webViews[currentWebView]?.goBack()
    }
    
    //to go forward
    func goForward() {
        dismissDashboard()
        
        webViews[currentWebView]?.goForward()
    }
    
    //show go back list in table view
    func showGoBackList(rec: UILongPressGestureRecognizer) {
        dismissDashboard()
        
        if rec.state == .Began {
            backForwardFavoriteTableView = UITableView()
            backForwardFavoriteTableView.dataSource = self
            backForwardFavoriteTableView.delegate = self
            backForwardFavoriteTableView.frame = CGRectMake(0, view.frame.height, view.frame.width, view.frame.height - 44)
            backForwardFavoriteTableView.tag = 0
            
            UIView.beginAnimations("animateWebView", context: nil)
            UIView.setAnimationDuration(0.1)
            
            backForwardFavoriteTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
            //backForwardFavoriteTableView.style = .Plain
            self.view.addSubview(backForwardFavoriteTableView)
            
            let listLabel: UILabel = UILabel()
            listLabel.text = "History of this Tab"
            listLabel.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
            let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "hideGoBackForwardFavoritesList")
            var toolBarItems = [
                listLabelItem,
                flexibleSpaceBarButtonItem,
                cancelButton
            ]
            toolBar.setItems(toolBarItems, animated: true)
            self.view.bringSubviewToFront(toolBar)
            UIView.commitAnimations()
        }
    }
    
    //show go forward list in table view
    func showGoForwardList(rec: UILongPressGestureRecognizer) {
        dismissDashboard()
        
        if rec.state == .Began {
            backForwardFavoriteTableView = UITableView()
            backForwardFavoriteTableView.dataSource = self
            backForwardFavoriteTableView.delegate = self
            backForwardFavoriteTableView.frame = CGRectMake(0, view.frame.height, view.frame.width, view.frame.height - 44)
            backForwardFavoriteTableView.tag = 1
            
            UIView.beginAnimations("animateWebView", context: nil)
            UIView.setAnimationDuration(0.1)
            
            backForwardFavoriteTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
            //backForwardFavoriteTableView.style = .Plain
            self.view.addSubview(backForwardFavoriteTableView)
            
            let listLabel: UILabel = UILabel()
            listLabel.text = "History of this Tab"
            listLabel.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
            let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
            let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "hideGoBackForwardFavoritesList")
            var toolBarItems = [
                listLabelItem,
                flexibleSpaceBarButtonItem,
                cancelButton
            ]
            toolBar.setItems(toolBarItems, animated: true)
            self.view.bringSubviewToFront(toolBar)
            UIView.commitAnimations()
        }
    }
    
    //to hide table view
    func hideGoBackForwardFavoritesList() {
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.1)
        
        backForwardFavoriteTableView.removeFromSuperview()
        configtoolbaritems()
        
        UIView.commitAnimations()
    }
    
    //reload data in tableView after add or delet bookmarks in CoreData model
    func tableReload() {
        backForwardFavoriteTableView.reloadData()
    }
    
    //to start refresh
    func doRefresh() {
        dismissDashboard()
        
        webViews[currentWebView]?.reload()
    }
    
    //to stop refreshing
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
        configrefreshImage()
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
    
    //hide toolBar to fullscreen
    func hidetoolbar() {
        webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        progressBar.frame = CGRectMake(0, view.frame.height - 3, view.frame.width, 3)
        toolBar.hidden = true
        dismissDashboard()
    }
    
    //show toolBar to exit fullscreen
    func showtoolbar() {
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.2)
        webViews[currentWebView]?.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
        progressBar.frame = CGRectMake(0, view.frame.height - 47, view.frame.width, 3)
        toolBar.hidden = false
        UIView.commitAnimations()
    }
    
    //dismiss dashboard
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
    
    //toShare
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
    
    //toOpenInSafari
    func toOpenInSafari() {
        dismissDashboard()
        
        var myWebsite = webViews[currentWebView]?.URL
        if myWebsite == nil {
            myWebsite = NSURL(string: "")
        }
        
        UIApplication.sharedApplication().openURL(myWebsite!)
    }
    
    //go to home page
    func goHome() {
        dismissDashboard()
        
        textField.text = homewebpage
        didClickGo()
    }
    
    //show favorites bookmarks in tableView
    func showFavorites() {
        backForwardFavoriteTableView = UITableView()
        backForwardFavoriteTableView.dataSource = self
        backForwardFavoriteTableView.delegate = self
        backForwardFavoriteTableView.frame = CGRectMake(0, view.frame.height, view.frame.width, view.frame.height - 44)
        backForwardFavoriteTableView.tag = 2
        
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.1)
        
        backForwardFavoriteTableView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height - 44)
        //backForwardFavoriteTableView.style = .Plain
        self.view.addSubview(backForwardFavoriteTableView)
        
        let listLabel: UILabel = UILabel()
        listLabel.text = "Favorites"
        listLabel.frame = CGRectMake(0, 0, view.frame.width - 150, 30)
        let listLabelItem: UIBarButtonItem = UIBarButtonItem(customView: listLabel)
        let cancelButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "hideGoBackForwardFavoritesList")
        let addButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "startAddingFavorites")
        var toolBarItems = [
            addButton,
            flexibleSpaceBarButtonItem,
            listLabelItem,
            flexibleSpaceBarButtonItem,
            cancelButton
        ]
        toolBar.setItems(toolBarItems, animated: true)
        self.view.bringSubviewToFront(toolBar)
        UIView.commitAnimations()
    }
    
    //display NewFavoriteItemTableViewController for user to add a favorite bookmark
    func startAddingFavorites() {
        println("startaddingfavorites")
        addNewFavoriteTableViewController = NewFavoriteItemTableViewController(style: .Grouped)
        let title: String! = webViews[currentWebView]?.title
        let url: String! = webViews[currentWebView]?.URL?.absoluteString
        addNewFavoriteTableViewController.defaultTitle = title
        if url != nil {
            addNewFavoriteTableViewController.defaultURL = url
        }
        var addNewFavoriteNavigationController = UINavigationController(rootViewController: addNewFavoriteTableViewController)
        self.navigationController?.presentViewController(addNewFavoriteNavigationController, animated: true, completion: nil)
    }
    
    //add favorite to tableView and the CoreData model
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
        
        backForwardFavoriteTableView.reloadData()
    }
    
    //show all tabs so user can pick one
    func showAllWebViews() {
        dismissDashboard()
        
        showingAllWebViews = true
        
        edgeSwipe.enabled = false
        
        if adbanner.bannerLoaded {
            adbanner.frame = CGRectMake(5, 0, self.view.frame.width - 10, 50)
            self.view.addSubview(adbanner)
        }
        
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.5)
        
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
    
    //show current tab
    func doneShowingAllWebViews() {
        adbanner.removeFromSuperview()
        
        UIView.beginAnimations("animateWebView", context: nil)
        UIView.setAnimationDuration(0.5)
        
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
        configrefreshImage()
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
    
    //add a new tab
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
    
    //show the tab user selected
    func showWebView(sender: UIButton) {
        currentWebView = sender.tag
        doneShowingAllWebViews()
    }
    
    //to undo closed tab
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
    
    //to close a tab
    func closeWebView(rec: UIPanGestureRecognizer) {
        let y = rec.view?.tag
        let z = y!
        
        switch rec.state {
        case .Began:
            UIView.beginAnimations("animateWebView", context: nil)
            UIView.setAnimationDuration(0.1)
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
            UIView.commitAnimations()
        default: true
        }
    }
    
    //long press and drag to sort webviews, not used yet
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


//the controller for user to add a new favorite bookmark
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
    
    //config UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewshowed = true
        
        usrTitleTextField = UITextField(frame: CGRectMake(0, 0, view.frame.width, 44))
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
        
        usrURLTextField = UITextField(frame: CGRectMake(0, 0, view.frame.width, 44))
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
        self.navigationController?.navigationBar.backItem?.backBarButtonItem = cancelButton
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //two sections, one for title and URL, another for the done button
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    //the first section is for title and url, so it will be two rows; second is for done button, which is one row.
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    //first section first row is title, second row is url. second section is done button only
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
    
    //press done button to pass data
    func pressDone() {
        usrTitle = usrTitleTextField.text
        usrURL = usrURLTextField.text
        clickedDone = true
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //if user canceled adding new favorite bookmark
    func cancelAddFavorite(){
        clickedDone = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
