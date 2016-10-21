//
//  ViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 14/12/6.
//  Copyright (c) 2014年 Peter Zhu. All rights reserved.
//

import UIKit
import WebKit
import iAd
import QuartzCore
import CoreData
import Dispatch
//import AVFoundation  //for detecting the start of playing a video

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, ADBannerViewDelegate {
    
    
    var backgroundQueue: DispatchQueue = DispatchQueue(label: "com.zhukaihan.USB.background", attributes: []);
    
    //////////Variables
    var homewebpage: String!
    var defaultSearchEngine = UserDefaults.standard.string(forKey: "searchtype")
    var unclosedwebviews = [NSManagedObject]()
    var orientationchanged: Bool = false //true for landscape, false for portrait; for UIDeviceOrientationDidChangedNotification
    
    var currentWebView: Int = 0
    var totalWebView: Int = 0
    var weby: CGFloat = CGFloat(0)
    var showingAllWebViews: Bool = false
    var showAllWebViewsScrollView = UIScrollView()
    
    var panInit: Int = 0
    var panInitdir: Bool = false  //true for left and right, false for up or down
    var webViewCloseSwipe: [UIPanGestureRecognizer]! = []
    //var webViewCloseLongPress: [UILongPressGestureRecognizer!]! = []  //long press to sort webviews
    var webViewButtons: [UIButton?]! = [UIButton()]
    var webViewLabels: [UILabel?]! = [UILabel()]
    var webViews: [CustomWKWebView] = []  //first CustomWKWebView starts at webViews[0]
    var undoWebView: CustomWKWebView? = CustomWKWebView()
    var isLongPressed: Bool = false
    var backForwardFavoriteTableView: BackForwardTableViewController! = BackForwardTableViewController()
    
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
    var orientationlockbutton: UIButton!
    //var browsingHistoryButton: UIButton!
    
    var dashboard: UIScrollView! = UIScrollView()  //have a tag numbered 3
    var dashboardTitle: UILabel! = UILabel()
    var dashboardPageControl: UIPageControl! = UIPageControl()
    var superHugeRegretButton: UIButton = UIButton()  //for hiding the dashboard
    
    var toolBar: UIToolbar! = UIToolbar()
    var toolBarSwipe: UIPanGestureRecognizer! = UIPanGestureRecognizer()  //the UIPanGestureRecognizer for showing dashboard
    var showButton: UIButton! = UIButton()
    var textField: URLTextField!
    var childSuggestionsViewController: SuggestionsViewController!// = SuggestionsViewController()
    
    var progressBar: UIProgressView! = UIProgressView(progressViewStyle: .bar)
    
    var adbanner: ADBannerView! = ADBannerView()
    var isAdbannerEnoughSecondsYet: Bool = true
    
    let backgroundimage = UIImageView(image: UIImage(named: "icon.png")!)
    
    
    //////////Override funcs
    override func loadView() {
        super.loadView()
        
        self.view.backgroundColor = UIColor.darkGray
        backgroundimage.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        backgroundimage.layer.zPosition = 0
        //self.view.addSubview(backgroundimage)

        //toolBar configuration begin
        configtextField()
        textField.configrefreshImage()
        textField.delegate = self

        let backimg = UIImage(named: "backbutton.png")
        let backbutton = UIButton()
        backbutton.setBackgroundImage(backimg, for: UIControlState())
        backbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        backbutton.addTarget(self, action: #selector(ViewController.goBack), for: .touchUpInside)
        let backButtonLongPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.showGoBackList(_:)))
        backButtonLongPress.minimumPressDuration = 1
        backbutton.addGestureRecognizer(backButtonLongPress)
        backButton = UIBarButtonItem(customView: backbutton)
        backButton.isEnabled = false

        let forwardimg = UIImage(named: "forwardbutton.png")
        let forwardbutton = UIButton()
        forwardbutton.setBackgroundImage(forwardimg, for: UIControlState())
        forwardbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        forwardbutton.addTarget(self, action: #selector(ViewController.goForward), for: .touchUpInside)
        let forwardButtonLongPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.showGoForwardList(_:)))
        forwardButtonLongPress.minimumPressDuration = 1
        forwardbutton.addGestureRecognizer(forwardButtonLongPress)
        forwardButton = UIBarButtonItem(customView: forwardbutton)
        forwardButton.isEnabled = false

        textItem = UIBarButtonItem(customView: textField)
        let webViewSwitchimg = UIImage(named: "pages.png")
        let webViewSwitchbutton = UIButton()
        webViewSwitchbutton.setBackgroundImage(webViewSwitchimg, for: UIControlState())
        webViewSwitchbutton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        webViewSwitchbutton.addTarget(self, action: #selector(ViewController.showAllWebViews), for: .touchUpInside)
        webViewSwitch = UIBarButtonItem(customView: webViewSwitchbutton)
        webViewSwitch.isEnabled = true

        undoWebViewButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(ViewController.undoPreviousWebView))
        undoWebViewButton.isEnabled = false
        flexibleSpaceBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        toolBar.frame = CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44)
        configtoolbaritems()
        toolBar.backgroundColor = UIColor.lightGray
        self.view.addSubview(toolBar)

        toolBarSwipe.addTarget(self, action: #selector(ViewController.toolBarSwipeSwiping))
        toolBar.addGestureRecognizer(toolBarSwipe)
        //toolBar configuration end

        let oneForthViewWidth = view.frame.width / 4
        
        let fullscreenbuttonimg = UIImage(named: "fullscreen.png")
        fullscreenbutton = UIButton()
        fullscreenbutton.frame = CGRect(x: oneForthViewWidth * 1 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
        fullscreenbutton.setImage(fullscreenbuttonimg, for: UIControlState())
        fullscreenbutton.addTarget(self, action: #selector(ViewController.hidetoolbar), for: .touchUpInside)

        let homebuttonimg = UIImage(named: "home.png")
        homebutton = UIButton()
        homebutton.frame = CGRect(x: oneForthViewWidth * 2 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
        homebutton.setImage(homebuttonimg, for: UIControlState())
        homebutton.addTarget(self, action: #selector(ViewController.goHome), for: .touchUpInside)

        let sharebuttonimg = UIImage(named: "share.png")
        sharebutton = UIButton()
        sharebutton.frame = CGRect(x: oneForthViewWidth * 3 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
        sharebutton.setImage(sharebuttonimg, for: UIControlState())
        sharebutton.addTarget(self, action: #selector(ViewController.toShare), for: .touchUpInside)

        let openinsafaributtonimg = UIImage(named: "openinsafari.png")
        openinsafaributton = UIButton()
        openinsafaributton.frame = CGRect(x: oneForthViewWidth * 4 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
        openinsafaributton.setImage(openinsafaributtonimg, for: UIControlState())
        openinsafaributton.addTarget(self, action: #selector(ViewController.toOpenInSafari), for: .touchUpInside)

        let showfavoritebuttonimg = UIImage(named: "favorites.png")
        showfavoritebutton = UIButton()
        let showfavoritebuttonframewidthmid = view.frame.width / 4 * 1
        let showfavoritebuttonframewidthonemid = (view.frame.width / 4 - 59) / 2
        let showfavoritebuttonframewidthone = showfavoritebuttonframewidthmid - showfavoritebuttonframewidthonemid - 59
        let showfavoritebuttonframewidth = showfavoritebuttonframewidthone + view.frame.width
        showfavoritebutton.frame = CGRect(x: showfavoritebuttonframewidth, y: 55, width: 59, height: 59)
        showfavoritebutton.setImage(showfavoritebuttonimg, for: UIControlState())
        showfavoritebutton.addTarget(self, action: #selector(ViewController.showFavorites), for: .touchUpInside)

        let orientationlockbuttonimg = UIImage(named: "orientationlock_unlocked.png")
        orientationlockbutton = UIButton()
        let orientationlockbuttonframewidthmid = view.frame.width / 4 * 2
        let orientationlockbuttonframewidthonemid = (view.frame.width / 4 - 59) / 2
        let orientationlockbuttonframewidthone = orientationlockbuttonframewidthmid - orientationlockbuttonframewidthonemid - 59
        let orientationlockbuttonframewidth = orientationlockbuttonframewidthone + view.frame.width
        orientationlockbutton.frame = CGRect(x: orientationlockbuttonframewidth, y: 55, width: 59, height: 59)
        orientationlockbutton.setImage(orientationlockbuttonimg, for: UIControlState())
        orientationlockbutton.addTarget(self, action: #selector(ViewController.changeOrientationLock), for: .touchUpInside)
        orientationlockbutton.tintColor = UIColor.gray

        // //////////browsing history button config

        dashboard.tag = 3
        dashboard.delegate = self
        dashboard.frame = CGRect(x: 0, y: view.frame.height - 44 - 120, width: view.frame.width, height: 120)
        dashboard.contentSize = CGSize(width: view.frame.width * 2, height: 120)
        dashboard.isPagingEnabled = true
        dashboard.showsHorizontalScrollIndicator = false
        dashboard.showsVerticalScrollIndicator = false
        dashboard.backgroundColor = UIColor(white: 1, alpha: 0.9)
        dashboard.addSubview(fullscreenbutton)
        dashboard.addSubview(homebutton)
        dashboard.addSubview(sharebutton)
        dashboard.addSubview(openinsafaributton)
        dashboard.addSubview(showfavoritebutton)
        //dashboard.addSubview(orientationlockbutton)
        dashboardTitle.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 30)
        dashboardTitle.text = "  Dashboard"
        dashboardTitle.textColor = UIColor(white: 0.5, alpha: 1)
        dashboardTitle.font = UIFont(name: "Arial", size: 15)
        dashboardTitle.backgroundColor = UIColor(white: 0.825, alpha: 1)
        dashboard.addSubview(dashboardTitle)
        dashboardPageControl.frame = CGRect(x: 0, y: 35, width: view.frame.width, height: 10)
        dashboardPageControl.numberOfPages = 2
        dashboardPageControl.currentPage = 0
        dashboardPageControl.pageIndicatorTintColor = UIColor.lightGray
        dashboardPageControl.currentPageIndicatorTintColor = UIColor.darkGray
        dashboard.addSubview(dashboardPageControl)

        superHugeRegretButton.addTarget(self, action: #selector(ViewController.dismissDashboard), for: .touchUpInside)
        superHugeRegretButton.backgroundColor = UIColor.black
        superHugeRegretButton.alpha = 0.5
        
        showAllWebViewsScrollView.tag = 4
        showAllWebViewsScrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        showAllWebViewsScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height)
        //showAllWebViewsScrollView.panGestureRecognizer.delegate = self;
        showAllWebViewsScrollView.pinchGestureRecognizer?.isEnabled = false;
        showAllWebViewsScrollView.showsVerticalScrollIndicator = false;
        showAllWebViewsScrollView.showsHorizontalScrollIndicator = false;
        showAllWebViewsScrollView.alwaysBounceHorizontal = false;


        let showimg = UIImage(named: "showtoolbar.png")
        showButton.setBackgroundImage(showimg, for: UIControlState())
        showButton.frame = CGRect(x: view.frame.width - 30, y: view.frame.height - 30, width: 29, height: 29)
        showButton.addTarget(self, action: #selector(ViewController.showtoolbar), for: .touchDown)
        self.view.addSubview(showButton)

        
        progressBar.frame = CGRect(x: 0, y: view.frame.height - 47, width: view.frame.width, height: 3)
        self.view.addSubview(progressBar)


        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refersh")
        refreshControl.addTarget(self, action: #selector(ViewController.doRefresh), for: .valueChanged)


        checkhomeurl()


        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName:"UnclosedWebViews")
        try! unclosedwebviews = managedContext!.fetch(fetchRequest) 

        if unclosedwebviews.count != 0 {
            for i in 0...unclosedwebviews.count - 1 {
                webViews.insert(CustomWKWebView(), at: webViews.endIndex)
                webViews[i].navigationDelegate = self
                webViews[i].uiDelegate = self
                webViews[i].allowsBackForwardNavigationGestures = true
                webViews[i].scrollView.addSubview(refreshControl)

                let webview = unclosedwebviews[i]
                let urlstring = webview.value(forKey: "webviews") as! String?
                if (urlstring != nil) {
                    let url = URL(string: urlstring!)
                    let request = URLRequest(url: url!)
                    webViews[i].load(request)
                }

                webViews[i].frame = CGRect(x: 20, y: view.frame.height + 50, width: view.frame.width - 40, height: view.frame.height - 44)
                totalWebView += 1
            }
            showAllWebViews()

            for bas in unclosedwebviews {
                managedContext!.delete(bas as NSManagedObject)
            }
            unclosedwebviews.removeAll(keepingCapacity: false)
        } else {
            webViews.insert(CustomWKWebView(), at: webViews.endIndex)
            webViews[currentWebView].allowsBackForwardNavigationGestures = true
            webViews[currentWebView].navigationDelegate = self
            webViews[currentWebView].uiDelegate = self
            webViews[currentWebView].scrollView.addSubview(refreshControl)
            webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
            self.view.addSubview(webViews[currentWebView])
            totalWebView += 1

            textField.text = homewebpage
            didClickGo()
        }


        adbanner.delegate = self


        self.view.bringSubview(toFront: showButton)
        self.view.bringSubview(toFront: toolBar)
        self.view.bringSubview(toFront: progressBar)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        checkhomeurl()
        registerForNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if (UserDefaults.standard.bool(forKey: "HasLaunchedOnce")) {
          print("app already launched")
        } else {
            UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
            UserDefaults.standard.synchronize()
            print("This is the first launch ever")
            
            let demoViewController: DemoViewController = DemoViewController()
            demoViewController.demoParentViewController = self
            let DemoNavigationController = NavigationController(rootViewController: demoViewController)
            self.navigationController?.present(DemoNavigationController, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("View Will Disappear")

        URLCache.shared.removeAllCachedResponses()
        NotificationCenter.default.removeObserver(self)

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let entity =  NSEntityDescription.entity(forEntityName: "UnclosedWebViews", in: managedContext!)

        for bas in unclosedwebviews {
            managedContext!.delete(bas)
        }
        unclosedwebviews.removeAll(keepingCapacity: false)

        for i in 0...webViews.count - 1 {
            if (webViews[i].url?.absoluteString != nil) && (webViews[i].url?.absoluteString != homewebpage) {
                let webview = NSManagedObject(entity: entity!, insertInto:managedContext)

                webview.setValue(webViews[i].url?.absoluteString, forKey: "webviews")

                try! managedContext!.save()

                unclosedwebviews.append(webview)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        print(size)
        let transitToSize = size//CGSize(width: view.frame.width, height: view.frame.height)
        
        if ((UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && !orientationchanged) || (((UIDevice.current.orientation == .portrait) || UIDevice.current.userInterfaceIdiom == .pad) && orientationchanged)) {
            
            if !showingAllWebViews{
                if (toolBar.isHidden == false) {
                    webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height - 44)
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 47, width: transitToSize.width, height: 3)
                } else {
                    webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 3, width: transitToSize.width, height: 3)
                }
                
                if adbanner.window != nil {
                    if (adbanner.frame.origin.x == 0) && (adbanner.frame.origin.y == 0) && (!isAdbannerEnoughSecondsYet) {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 66)
                            webViews[currentWebView].frame = CGRect(x: 0, y: 66, width: transitToSize.width, height: transitToSize.height - 44 - 66) //44: toolbar height; 66: adbanner height
                        } else {
                            if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                                adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 50)
                                webViews[currentWebView].frame = CGRect(x: 0, y: 50, width: transitToSize.width, height: transitToSize.height - 44 - 50) //44: toolbar height; 50: adbanner height
                            } else {
                                adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 32)
                                webViews[currentWebView].frame = CGRect(x: 0, y: 32, width: transitToSize.width, height: transitToSize.height - 44 - 32) //44: toolbar height; 32: adbanner height
                            }
                        }
                    }
                }
            } else {
                if (toolBar.isHidden == false) {
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 47, width: transitToSize.width, height: 3)
                } else {
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 3, width: transitToSize.width, height: 3)
                }
                //prep for showAllWebViews()
                for i in 0...webViews.count - 1 {
                    webViewLabels[i]?.removeFromSuperview()
                    webViews[i].removeFromSuperview()
                    webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                    //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                    webViewButtons[i]?.removeFromSuperview()
                }
                
                self.view.bringSubview(toFront: showButton)
                self.view.bringSubview(toFront: toolBar)
                self.view.bringSubview(toFront: progressBar)
                
                webViewButtons = []
                webViewCloseSwipe = []
                //webViewCloseLongPress = []
                webViewLabels = []
                
                showAllWebViews(transitToSize)
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 66)
                } else {
                    if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.height {
                        adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 50)
                    } else {
                        adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 32)
                    }
                }
                self.view.bringSubview(toFront: toolBar)
            }
            
            //backgroundimage.frame = CGRectMake(abs(transitToSize.width - transitToSize.height) / 2, 0, sort(&[transitToSize.width,transitToSize.height]), transitToSize.width)
            
            toolBar.frame = CGRect(x: 0, y: transitToSize.height - 44, width: transitToSize.width, height: 44)
            if textField.isFirstResponder {
                textField.frame = CGRect(x: 0, y: 0, width: transitToSize.width - 100, height: 30)
            } else {
                textField.frame = CGRect(x: 0, y: 0, width: transitToSize.width - 150, height: 30)
            }
            showAllWebViewsScrollView.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
            showButton.frame = CGRect(x: transitToSize.width - 30, y: transitToSize.height - 30, width: 29, height: 29)
            superHugeRegretButton.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
            dashboard.frame = CGRect(x: 0, y: transitToSize.height - 44 - 120, width: transitToSize.width, height: 120)
            dashboard.contentSize = CGSize(width: transitToSize.width * 2,height: 120)
            dashboardTitle.frame = CGRect(x: dashboard.contentOffset.x, y: 0, width: transitToSize.width, height: 30)
            dashboardPageControl.frame = CGRect(x: dashboard.contentOffset.x, y: 35, width: transitToSize.width, height: 10)
            let oneForthViewWidth = transitToSize.width / 4
            fullscreenbutton.frame = CGRect(x: oneForthViewWidth * 1 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            homebutton.frame = CGRect(x: oneForthViewWidth * 2 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            sharebutton.frame = CGRect(x: oneForthViewWidth * 3 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            openinsafaributton.frame = CGRect(x: oneForthViewWidth * 4 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            let showfavoritebuttonframewidthmid = transitToSize.width / 4 * 1
            let showfavoritebuttonframewidthonemid = (transitToSize.width / 4 - 59) / 2
            let showfavoritebuttonframewidthone = showfavoritebuttonframewidthmid - showfavoritebuttonframewidthonemid - 59
            let showfavoritebuttonframewidth = showfavoritebuttonframewidthone + transitToSize.width
            showfavoritebutton.frame = CGRect(x: showfavoritebuttonframewidth, y: 55, width: 59, height: 59)
            let orientationlockbuttonframewidthmid = transitToSize.width / 4 * 2
            let orientationlockbuttonframewidthonemid = (transitToSize.width / 4 - 59) / 2
            let orientationlockbuttonframewidthone = orientationlockbuttonframewidthmid - orientationlockbuttonframewidthonemid - 59
            let orientationlockbuttonframewidth = orientationlockbuttonframewidthone + transitToSize.width
            orientationlockbutton.frame = CGRect(x: orientationlockbuttonframewidth, y: 55, width: 59, height: 59)
            
            if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
                orientationchanged = true
            } else {
                orientationchanged = false
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //////////Regular funcs
    func demo() {
        
        let demoAlert = UIAlertController(title: "First time use", message: "Take a look at an automated demo?", preferredStyle: .alert)
        demoAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(action: UIAlertAction) in
            self.view.isUserInteractionEnabled = false
            let touchImg: UIImage = UIImage(named: "touch.png")!
            let touchView = UIImageView(image: touchImg)
            
            DispatchQueue.global().async {
                sleep(1)
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: self.textField.frame.origin.x + 20, y: self.toolBar.frame.origin.y, width: 50, height: 50)
                    self.view.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    touchView.layer.transform = CATransform3DIdentity
                    touchView.removeFromSuperview()
                    self.textField.becomeFirstResponder()
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: self.childSuggestionsViewController.suggestionsTableView.frame.origin.x + 20, y: self.childSuggestionsViewController.suggestionsTableView.rectForRow(at: IndexPath(row: 0, section: 0)).origin.y, width: 50, height: 50)
                    self.view.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            touchView.layer.transform = CATransform3DIdentity
                            touchView.removeFromSuperview()
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    self.childSuggestionsViewController.tableView(self.childSuggestionsViewController.suggestionsTableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: 100, y: self.toolBar.frame.origin.y, width: 50, height: 50)
                    self.view.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                var transform = CATransform3DIdentity
                                transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                                self.view.bringSubview(toFront: touchView)
                                touchView.layer.transform = CATransform3DTranslate(transform, 0, -200, 0)
                                }, completion: {(animated: Bool) in
                                    touchView.layer.transform = CATransform3DIdentity
                                    touchView.removeFromSuperview()
                            })
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    self.displayDashboard()
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                    self.fullscreenbutton.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                                }, completion: {(animated: Bool) in
                                    touchView.layer.transform = CATransform3DIdentity
                                    touchView.removeFromSuperview()
                            })
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    self.hidetoolbar()
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: self.showButton.frame.origin.x - 5, y: self.showButton.frame.origin.y - 5, width: 50, height: 50)
                    self.view.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                                }, completion: {(animated: Bool) in
                                    touchView.layer.transform = CATransform3DIdentity
                                    touchView.removeFromSuperview()
                            })
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    self.showtoolbar()
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                    self.webViewSwitch.customView?.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                                }, completion: {(animated: Bool) in
                                    touchView.layer.transform = CATransform3DIdentity
                                    touchView.removeFromSuperview()
                            })
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    self.showAllWebViews()
                }
                sleep(2)
                
                DispatchQueue.main.sync {
                    touchView.frame = CGRect(x: self.view.frame.width / 3, y: 100, width: 50, height: 50)
                    self.view.addSubview(touchView)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    UIView.animate(withDuration: 0.5, animations: {
                        touchView.layer.transform = CATransform3DMakeScale(0.5, 0.5, 1)
                        }, completion: {(animated: Bool) in
                            UIView.animate(withDuration: 0.5, animations: {
                                var transform = CATransform3DIdentity
                                transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                                self.view.bringSubview(toFront: touchView)
                                touchView.layer.transform = transform
                            })
                    })
                }
                usleep(500000)
                DispatchQueue.main.sync {
                    var transform = CATransform3DIdentity
                    transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                    self.view.bringSubview(toFront: touchView)
                    UIView.animate(withDuration: 0.1, animations: {
                        touchView.layer.transform = CATransform3DTranslate(transform, 50, 0, 0)
                    })
                    
                    self.panningRightToCloseWebView(0, thenewx: 50)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    var transform = CATransform3DIdentity
                    transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                    self.view.bringSubview(toFront: touchView)
                    UIView.animate(withDuration: 0.1, animations: {
                        touchView.layer.transform = CATransform3DTranslate(transform, 100, 0, 0)
                    })
                    
                    self.panningRightToCloseWebView(0, thenewx: 100)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    var transform = CATransform3DIdentity
                    transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                    self.view.bringSubview(toFront: touchView)
                    UIView.animate(withDuration: 0.1, animations: {
                        touchView.layer.transform = CATransform3DTranslate(transform, 150, 0, 0)
                    })
                    
                    self.panningRightToCloseWebView(0, thenewx: 150)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    var transform = CATransform3DIdentity
                    transform = CATransform3DScale(transform, 0.5, 0.5, 1)
                    self.view.bringSubview(toFront: touchView)
                    UIView.animate(withDuration: 0.1, animations: {
                        touchView.layer.transform = CATransform3DTranslate(transform, 200, 0, 0)
                    })
                    
                    self.panningRightToCloseWebView(0, thenewx: 200)
                }
                usleep(100000)
                DispatchQueue.main.sync {
                    touchView.layer.transform = CATransform3DIdentity
                    touchView.removeFromSuperview()
                    
                    self.closeWebView(0)
                }
                sleep(2)
                DispatchQueue.main.sync {
                    self.view.isUserInteractionEnabled = true
                }
            }
        }))
        demoAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {(action: UIAlertAction) in
            
        }))
        self.present(demoAlert, animated: true, completion: nil)
    }
    
    func configtextField() {
        textField = URLTextField()
        textField.parentViewController = self
        textField.frame = CGRect(x: 0, y: 0, width: view.frame.width - 150, height: 30)
        textField.borderStyle = .roundedRect
        textField.addTarget(self, action: #selector(ViewController.didClickGo), for: .editingDidEndOnExit)
    }
    
    func configtoolbaritems() {
        toolBar.setItems([
            flexibleSpaceBarButtonItem,
            backButton,
            flexibleSpaceBarButtonItem,
            forwardButton,
            flexibleSpaceBarButtonItem,
            textItem,
            flexibleSpaceBarButtonItem,
            webViewSwitch
            ], animated: true)
    }
    
    func registerForNotifications() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillBeShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillBeHidden(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardDidHidden(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.orientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        if orientationlockbutton.tag == 1 {
            lockOrientation()
        } else {
            unlockOrientation()
        }
    }
    
    func checkGos() {
        if webViews[currentWebView].canGoBack {
            backButton.isEnabled = true
        } else {
            backButton.isEnabled = false
        }
        if webViews[currentWebView].canGoForward {
            forwardButton.isEnabled = true
        } else {
            forwardButton.isEnabled = false
        }
    }
    
    func lettextfieldtohost() {
        if (!textField.isFirstResponder && ((webViews[currentWebView].url?.absoluteString != nil)/* && ((webViews[currentWebView].URL?.absoluteString != "") && (webViews[currentWebView].canGoBack == false) && (webViews[currentWebView].canGoForward == false))*/)){
            //let theurl: String! = webViews[currentWebView].URL?.absoluteString.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
            let theurl: String! = webViews[currentWebView].url?.absoluteString.removingPercentEncoding
            let urlhost: String! = webViews[currentWebView].url?.host
            print("Finished navigating to url \(theurl)")
            if webViews[currentWebView].url?.host != nil{
                if ((theurl.hasPrefix("http://www.google.com/search?")) || (theurl.hasPrefix("https://www.google.com/search?"))) {
                    let urlstring = webViews[currentWebView].url?.query

                    let queryStringDictionary = NSMutableDictionary()
                    let urlComponents = urlstring?.components(separatedBy: "&")
                    let urlComponentsStrings: [String]! = urlComponents

                    for keyValuePair in urlComponentsStrings {
                        let pairComponents = keyValuePair.components(separatedBy: "=")
                        let key = pairComponents.first?.removingPercentEncoding
                        let value = pairComponents.last?.removingPercentEncoding

                        queryStringDictionary.setObject(value!, forKey: key! as NSCopying)
                    }

                    var str: String! = queryStringDictionary.value(forKey: "q") as! String
                    str = "🔍" + str
                    textField.text = str
                } else if ((theurl.hasPrefix("http://www.baidu.com/s?")) || (theurl.hasPrefix("https://www.baidu.com/s?"))) {
                    let urlstring = webViews[currentWebView].url?.query

                    let queryStringDictionary = NSMutableDictionary()
                    let urlComponents = urlstring?.components(separatedBy: "&")
                    let urlComponentsStrings: [String]! = urlComponents

                    for keyValuePair in urlComponentsStrings {
                        let pairComponents = keyValuePair.components(separatedBy: "=")
                        let key = pairComponents.first?.removingPercentEncoding
                        let value = pairComponents.last?.removingPercentEncoding

                        queryStringDictionary.setObject(value!, forKey: key! as NSCopying)
                    }

                    var str: String! = queryStringDictionary.value(forKey: "wd") as! String
                    str = "🔍" + str
                    textField.text = str
                } else if (urlhost?.hasPrefix("www.") == true) {
                    let strr = NSString(string: urlhost!)
                    let sttr = strr.substring(from: 4)
                    textField.text = sttr
                } else  {
                    textField.text = urlhost
                }
            } else {
                textField.text = ""
            }
            if (webViews[currentWebView].hasOnlySecureContent == true) {
                textField.text = "🔒" + textField.text!
            }
        } else if (!textField.isFirstResponder) && (textField.text != nil) {
            textField.text = "An Error has occurred."
        } else if (!textField.isFirstResponder) {
            textField.text = ""
        }
    }
    
    func checkhomeurl() {
        if  UserDefaults.standard.string(forKey: "homeurl") != nil {
            homewebpage = UserDefaults.standard.string(forKey: "homeurl")!
        } else {
            homewebpage = "zhukaihan.com"
        }
        if homewebpage.substring(from: homewebpage.index(before: homewebpage.endIndex)) != "/" {
            homewebpage = homewebpage + "/"
            UserDefaults.standard.setValue(homewebpage, forKey: "homeurl")
            UserDefaults.standard.synchronize()
        }
        if !homewebpage.hasPrefix("http://") {
            homewebpage = "http://" + homewebpage
            UserDefaults.standard.setValue(homewebpage, forKey: "homeurl")
            UserDefaults.standard.synchronize()
        }
    }
    
    func checkifdnsrsearch() {
        if webViews[currentWebView].url?.absoluteString.hasPrefix("http://www.dnsrsearch.com/index.php?origURL=") == true {
            webViews[currentWebView].stopLoading()
            let textfieldtext = webViews[currentWebView].url?.absoluteString
            var text = NSString(string: textfieldtext!)
            text = NSString(string: text.substring(from: 53))
            text = NSString(string: text.substring(to: text.length - 4))
            searchURL(String(text))
        }
    }
    
    /*override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    
    }*/
    
    func orientationDidChange(_ sender: Notification) {
        /*let transitToSize = CGSize(width: view.frame.width, height: view.frame.height)
        
        if ((UIDeviceOrientationIsLandscape(UIDevice.current.orientation) && !orientationchanged) || (((UIDevice.current.orientation == .portrait) || UIDevice.current.userInterfaceIdiom == .pad) && orientationchanged)) {

            if !showingAllWebViews{
                if (toolBar.isHidden == false) {
                    webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height - 44)
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 47, width: transitToSize.width, height: 3)
                } else {
                    webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 3, width: transitToSize.width, height: 3)
                }

                if adbanner.window != nil {
                    if (adbanner.frame.origin.x == 0) && (adbanner.frame.origin.y == 0) && (!isAdbannerEnoughSecondsYet) {
                        if UIDevice.current.userInterfaceIdiom == .pad {
                            adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 66)
                            webViews[currentWebView].frame = CGRect(x: 0, y: 66, width: transitToSize.width, height: transitToSize.height - 44 - 66) //44: toolbar height; 66: adbanner height
                        } else {
                            if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                                adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 50)
                                webViews[currentWebView].frame = CGRect(x: 0, y: 50, width: transitToSize.width, height: transitToSize.height - 44 - 50) //44: toolbar height; 50: adbanner height
                            } else {
                                adbanner.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: 32)
                                webViews[currentWebView].frame = CGRect(x: 0, y: 32, width: transitToSize.width, height: transitToSize.height - 44 - 32) //44: toolbar height; 32: adbanner height
                            }
                        }
                    }
                }
            } else {
                if (toolBar.isHidden == false) {
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 47, width: transitToSize.width, height: 3)
                } else {
                    progressBar.frame = CGRect(x: 0, y: transitToSize.height - 3, width: transitToSize.width, height: 3)
                }
                //prep for showAllWebViews()
                for i in 0...webViews.count - 1 {
                    webViewLabels[i]?.removeFromSuperview()
                    webViews[i].removeFromSuperview()
                    webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                    //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                    webViewButtons[i]?.removeFromSuperview()
                }
                
                self.view.bringSubview(toFront: showButton)
                self.view.bringSubview(toFront: toolBar)
                self.view.bringSubview(toFront: progressBar)
                
                webViewButtons = []
                webViewCloseSwipe = []
                //webViewCloseLongPress = []
                webViewLabels = []
                
                showAllWebViews()
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 66)
                } else {
                    if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.height {
                        adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 50)
                    } else {
                        adbanner.frame = CGRect(x: 0, y: 1, width: transitToSize.width, height: 32)
                    }
                }
                self.view.bringSubview(toFront: toolBar)
            }

            //backgroundimage.frame = CGRectMake(abs(transitToSize.width - transitToSize.height) / 2, 0, sort(&[transitToSize.width,transitToSize.height]), transitToSize.width)

            toolBar.frame = CGRect(x: 0, y: transitToSize.height - 44, width: transitToSize.width, height: 44)
            if textField.isFirstResponder {
                textField.frame = CGRect(x: 0, y: 0, width: transitToSize.width - 100, height: 30)
            } else {
                textField.frame = CGRect(x: 0, y: 0, width: transitToSize.width - 150, height: 30)
            }
            showAllWebViewsScrollView.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
            showButton.frame = CGRect(x: transitToSize.width - 30, y: transitToSize.height - 30, width: 29, height: 29)
            superHugeRegretButton.frame = CGRect(x: 0, y: 0, width: transitToSize.width, height: transitToSize.height)
            dashboard.frame = CGRect(x: 0, y: transitToSize.height - 44 - 120, width: transitToSize.width, height: 120)
            dashboard.contentSize = CGSize(width: transitToSize.width * 2,height: 120)
            dashboardTitle.frame = CGRect(x: dashboard.contentOffset.x, y: 0, width: transitToSize.width, height: 30)
            dashboardPageControl.frame = CGRect(x: dashboard.contentOffset.x, y: 35, width: transitToSize.width, height: 10)
            let oneForthViewWidth = transitToSize.width / 4
            fullscreenbutton.frame = CGRect(x: oneForthViewWidth * 1 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            homebutton.frame = CGRect(x: oneForthViewWidth * 2 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            sharebutton.frame = CGRect(x: oneForthViewWidth * 3 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            openinsafaributton.frame = CGRect(x: oneForthViewWidth * 4 - (oneForthViewWidth - 59) / 2 - 59, y: 55, width: 59, height: 59)
            let showfavoritebuttonframewidthmid = transitToSize.width / 4 * 1
            let showfavoritebuttonframewidthonemid = (transitToSize.width / 4 - 59) / 2
            let showfavoritebuttonframewidthone = showfavoritebuttonframewidthmid - showfavoritebuttonframewidthonemid - 59
            let showfavoritebuttonframewidth = showfavoritebuttonframewidthone + transitToSize.width
            showfavoritebutton.frame = CGRect(x: showfavoritebuttonframewidth, y: 55, width: 59, height: 59)
            let orientationlockbuttonframewidthmid = transitToSize.width / 4 * 2
            let orientationlockbuttonframewidthonemid = (transitToSize.width / 4 - 59) / 2
            let orientationlockbuttonframewidthone = orientationlockbuttonframewidthmid - orientationlockbuttonframewidthonemid - 59
            let orientationlockbuttonframewidth = orientationlockbuttonframewidthone + transitToSize.width
            orientationlockbutton.frame = CGRect(x: orientationlockbuttonframewidth, y: 55, width: 59, height: 59)

            if (UIDeviceOrientationIsLandscape(UIDevice.current.orientation)) {
                orientationchanged = true
            } else {
                orientationchanged = false
            }
        }*/
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        textField.configstopImage()
        checkifdnsrsearch()
        lettextfieldtohost()
        progressBar.setProgress(0.1, animated: false)
        backgroundQueue.async {
            self.refreshControl.attributedTitle = NSAttributedString(string: "Refreshing")
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { self.progressBar.alpha = 1 }, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation){
        progressBar.setProgress(Float(webViews[currentWebView].estimatedProgress) + 0.01, animated: true)
        textField.configstopImage()
        checkifdnsrsearch()
        lettextfieldtohost()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        checkGos()
        lettextfieldtohost()
        progressBar.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: {
            self.progressBar.alpha = 0
            }, completion: nil)
        textField.configrefreshImage()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.endRefreshing()

        backgroundQueue.async{

            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext

            if (self.webViews[self.currentWebView].url?.absoluteString != nil) {
                let historysFetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Historys")
                var historys: [NSManagedObject] = []
                try! historys = managedContext!.fetch(historysFetchRequest)
                if historys.count > 0 {
                    for theHistoryitem in historys {
                        if (theHistoryitem.value(forKey: "url") as! String) == (self.webViews[self.currentWebView].url?.absoluteString) {
                            managedContext!.delete(theHistoryitem)
                        }
                    }
                    try! historys = managedContext!.fetch(historysFetchRequest) 
                }

                let historysEntity =  NSEntityDescription.entity(forEntityName: "Historys", in: managedContext!)
                let websitevisit = NSManagedObject(entity: historysEntity!, insertInto:managedContext)
                websitevisit.setValue(self.webViews[self.currentWebView].title, forKey: "title")
                websitevisit.setValue(self.webViews[self.currentWebView].url?.absoluteString, forKey: "url")
                websitevisit.setValue(Date(), forKey: "time")

                historys.append(websitevisit)
            }

            if self.webViews[self.currentWebView].url?.host != nil {
                let topSitesFetchRequest = NSFetchRequest<NSManagedObject>(entityName:"TopSites")
                var topSites: [NSManagedObject] = []

                try! topSites = managedContext!.fetch(topSitesFetchRequest) 
                var hostNameNotFound = true
                if topSites.count > 0 {
                    for theTopSite in topSites {
                        if (theTopSite.value(forKey: "hostUrl") as! String) == (self.webViews[self.currentWebView].url?.host) {
                            let originalvisits = theTopSite.value(forKey: "visits") as! Float
                            theTopSite.setValue(originalvisits + 1, forKey: "visits")
                            hostNameNotFound = false
                            break
                        }
                    }
                }

                if hostNameNotFound {
                    let topSitesEntity =  NSEntityDescription.entity(forEntityName: "TopSites", in: managedContext!)
                    let theHostVisiting = NSManagedObject(entity: topSitesEntity!, insertInto:managedContext)
                    theHostVisiting.setValue(self.webViews[self.currentWebView].url?.host, forKey: "hostUrl")
                    theHostVisiting.setValue(1, forKey: "visits")

                    topSites.append(theHostVisiting)
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        /*if textField.text != nil {
        var requesturl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ultra_Simple_Browser_Internet_Error", ofType: "html")!)
        var request = NSURLRequest(URL: requesturl!)
        webView.loadRequest(request)
        }*/
        lettextfieldtohost()
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.endRefreshing()
        if !textField.isFirstResponder {
            textField.text = error.localizedDescription
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        /*if textField.text != nil {
        var requesturl = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("Ultra_Simple_Browser_Internet_Error", ofType: "html")!)
        var request = NSURLRequest(URL: requesturl!)
        webView.loadRequest(request)
        textField.text = error.localizedDescription
        }*/
        lettextfieldtohost()
        checkGos()
        progressBar.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: { self.progressBar.alpha = 0 }, completion: nil)
        textField.configrefreshImage()
        refreshControl.endRefreshing()
        if !textField.isFirstResponder {
            textField.text = error.localizedDescription
        }
    }
    
    @nonobjc func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame == nil {
            showtoolbar()
            openURLInNewWebView((navigationAction.request.url?.absoluteString)!)
            //NSTimer.scheduledTimerWithTimeInterval(1.5, target: self, selector: Selector("openURLInNewWebView:"), userInfo: navigationAction.request.URL?.absoluteString, repeats: false)
        }
        decisionHandler(.allow)
    }
    
    @nonobjc func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        print("response!!!: \(navigationResponse.response.mimeType)")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        print("\ncalled createwebview in new window")
        showtoolbar()
        openURLInNewWebView((navigationAction.request.url?.absoluteString)!)
        return nil//webViews[currentWebView]
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("alert one")
        let alert = UIAlertController(title: "Message from Web", message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in completionHandler()})
        alert.addAction(defaultAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("alert two")
        let alert = UIAlertController(title: "Message from Web", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {(action: UIAlertAction!) in completionHandler(true)})
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(action: UIAlertAction!) in completionHandler(false)})
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func keyboardWillBeShown(_ sender: Notification) {
        var keyboardSize: CGSize = CGSize(width: 0, height: 44)
        
        if let userInfo = sender.userInfo {
            if let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                keyboardSize = keyboardRect.size
                // ...
            } else {
                // no UIKeyboardFrameBeginUserInfoKey entry in userInfo
            }
        } else {
            // no userInfo dictionary in notification
        }
        

        if adbanner.isBannerLoaded {
            if UIDevice.current.userInterfaceIdiom == .pad {
                toolBar.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 44 - 66, width: view.frame.width, height: 44)
                adbanner.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 66, width: view.frame.width, height: 66)
            } else {
                if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                    toolBar.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 44 - 50, width: view.frame.width, height: 44)
                    adbanner.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 50, width: view.frame.width, height: 50)
                } else {
                    toolBar.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 44 - 32, width: view.frame.width, height: 44)
                    adbanner.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 32, width: view.frame.width, height: 32)
                }
            }
            webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
            if (adbanner.window == nil) && (isAdbannerEnoughSecondsYet) {
                self.view.addSubview(adbanner)
                Timer.scheduledTimer(timeInterval: 45, target: self, selector: #selector(ViewController.adbannerReachedEnoughSeconds(_:)), userInfo: nil, repeats: false)
                isAdbannerEnoughSecondsYet = false
            } else {
                self.view.bringSubview(toFront: adbanner)
            }
        } else {
            toolBar.frame = CGRect(x: 0, y: view.frame.height - keyboardSize.height - 44, width: view.frame.width, height: 44)
        }

        if childSuggestionsViewController?.view?.window != nil {  //just a question mark decides whether this app crash or not. It is the craziest thing ever happended to me.
            if adbanner.window != nil {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    childSuggestionsViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height - 44 - 66) //44: toolBar height; 66: adbanner height
                } else {
                    if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                        childSuggestionsViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height - 44 - 50) //44: toolBar height; 50: adbanner height
                    } else {
                        childSuggestionsViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height - 44 - 32) //44: toolBar height; 32: adbanner height
                    }
                }
            } else {
                childSuggestionsViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - keyboardSize.height - 44) //44:toolBar height
            }
            childSuggestionsViewController.viewFrameDidChange()
        }
    }
    
    func keyboardWillBeHidden(_ sender: Notification) {
        toolBar.frame = CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44)
        if adbanner.window != nil {
            if isAdbannerEnoughSecondsYet {
                adbanner.removeFromSuperview()
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    webViews[currentWebView].frame = CGRect(x: 0, y: 66, width: view.frame.width, height: view.frame.height - 44 - 66) //44: toolbar height; 66: adbanner height
                    adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 66)
                } else {
                    if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                        webViews[currentWebView].frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 44 - 50) //44: toolbar height; 50: adbanner height
                        adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
                    } else {
                        webViews[currentWebView].frame = CGRect(x: 0, y: 32, width: view.frame.width, height: view.frame.height - 44 - 32) //44: toolbar height; 32: adbanner height
                        adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 32)
                    }
                }
            }
        }
    }
    
    func keyboardDidHidden(_ sender: Notification) {
        if toolBar.frame.origin.y != view.frame.height - 44 {
            toolBar.frame = CGRect(x: 0, y: view.frame.height - 44, width: view.frame.width, height: 44)
        }
    }
    
    func adbannerReachedEnoughSeconds(_ timer: Timer) {
        print("timer fired\(timer)")

        isAdbannerEnoughSecondsYet = true
        if (adbanner.frame.origin.y == 0) && (!textField.isFirstResponder) {
            adbanner.removeFromSuperview()
            webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
        } else {
            //adbanner.removeFromSuperview()
        }
    }
    
    func bannerView(_ banner: ADBannerView!, didFailToReceiveAdWithError error: Error!) {
        print("failed to receive ad\n \(error)")
        if adbanner.window != nil {
            if adbanner.frame.origin.y == 0 {
                webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
            }
            adbanner.removeFromSuperview()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        //dismissDashboard()

        var cancelBarItem: UIBarButtonItem!

        cancelBarItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(ViewController.cancelInput))

        let toolBarItems: [UIBarButtonItem] = [
            textItem,
            flexibleSpaceBarButtonItem,
            cancelBarItem
        ]
        toolBar.setItems(toolBarItems, animated: true)
        toolBarSwipe.isEnabled = false

        textField.frame = CGRect(x: 0, y: 0, width: view.frame.width - 100, height: 30)

        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = false
        textField.text = webViews[currentWebView].url?.absoluteString.removingPercentEncoding//.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        textField.textAlignment = .left
        DispatchQueue.main.async(execute: {
            textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        })

        childSuggestionsViewController = SuggestionsViewController()
        self.addChildViewController(childSuggestionsViewController)
        childSuggestionsViewController.suggestionsParentViewController = self
        childSuggestionsViewController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 3000)
        self.view.addSubview(childSuggestionsViewController.view)
        childSuggestionsViewController.didMove(toParentViewController: self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.frame = CGRect(x: 0, y: 0, width: view.frame.width - 125, height: 30)
        configtoolbaritems()
        toolBarSwipe.isEnabled = true

        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.adjustsFontSizeToFitWidth = true
        textField.textAlignment = .center

        childSuggestionsViewController.willMove(toParentViewController: nil)
        childSuggestionsViewController.view.removeFromSuperview()
        childSuggestionsViewController.removeFromParentViewController()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        didClickGo()
        lettextfieldtohost()
        return false
    }
    
    func textFieldDidChanged() {
        if textField.isFirstResponder {
            let substring: String = textField.text!
            childSuggestionsViewController.searchAutocompleteEntriesWithSubstring(substring)
            childSuggestionsViewController.suggestionsTableView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.tag == 3 {
            let pageWidth: CGFloat = scrollView.frame.size.width
            let contentoffsetx: CGFloat = scrollView.contentOffset.x
            let fractionalPage = contentoffsetx / pageWidth
            let page: NSInteger = lroundf(Float(fractionalPage))
            dashboardPageControl.currentPage = page
            dashboardPageControl.frame = CGRect(x: contentoffsetx, y: 35, width: view.frame.width, height: 10)
            dashboardTitle.frame = CGRect(x: contentoffsetx, y: 0, width: view.frame.width, height: 30)
        } else {

        }

    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
        /*if (gestureRecognizer.tag == 4) || (otherGestureRecognizer.tag == 4) {
            return true
        } else {
            return false
        }*/
    }
    
    func didClickGo() {
        dismissDashboard()

        let oritext:String = textField.text!
        var text = oritext
        if text.hasPrefix("🔒") {
            let textmid: NSString = NSString(string: text)
            text = String(textmid.substring(from: 2))
        }
        if !URLHasInternetProtocalPrefix(text) {
            text = "http://" + text
        }
        if !URLIsValid(text) {
            searchURL(oritext)
        } else {
            loadURLRegularly(text)
        }
    }
    
    func openURLInNewWebView(_ url: String) {
        self.showAllWebViews()
        self.addNewWebView()
        loadURLRegularly(url)
    }
    
    func URLHasInternetProtocalPrefix(_ urlstring: String) -> Bool {
        return (urlstring.hasPrefix("http://") || urlstring.hasPrefix("https://") || urlstring.hasPrefix("ftp://") || urlstring.hasPrefix("ftps://"))
    }
    
    func URLIsValid(_ urlstring: String) -> Bool {
        let urlString: NSString = NSString(string: urlstring)
        let urlRegEx = "^((http|https|ftp|ftps)://)*(w{0,3}\\.)*([0-9a-zA-Z\\-_\\.!\\*'\\(\\);:@&=\\+\\$,/\\?%#\\[\\]]*)\\.([0-9a-zA-Z\\-_\\.!\\*'\\(\\);:@&=\\+\\$,/\\?%#\\[\\]]*)(/{0,1})([0-9a-zA-Z\\-_\\.!\\*'\\(\\);:@&=\\+\\$,/\\?%#\\[\\]]*)$"
        //0-9a-zA-Z\\-_\\.!\\*'\\(\\);:@&=\\+\\$,/\\?%#\\[\\]
        //-._~:/?#[]@!$&'()*+,;=502
        //"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        //"^(http|https|ftps)://([\\\\w-]+\\.)+[\\\\w-]+(/[\\\\w-./?%&=]*)?$"
        let predicate = NSPredicate(format:"SELF MATCHES %@", argumentArray:[urlRegEx])
//        let urlTest = NSPredicate.predicateWithSubstitutionVariables(predicate)
        let isValidURL: Bool = predicate.evaluate(with: urlString)

        return isValidURL
    }
    
    func loadURLRegularly(_ urlstring: String) {
        let url = URL(string: urlstring)
        let request = URLRequest(url: url!)
        webViews[currentWebView].load(request)
    }
    
    func searchURL(_ urlstring: String) {
        if (defaultSearchEngine == "1") {
            let text = "http://www.baidu.com/s?wd=" + urlstring.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
            loadURLRegularly(text)//.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        } else {
            let text = "http://www.google.com/search?q=" + urlstring.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlFragmentAllowed)!
            loadURLRegularly(text)//.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        }
    }
    
    func cancelInput() {
        textField.resignFirstResponder()
        lettextfieldtohost()
    }
    
    func goBack() {
        dismissDashboard()

        webViews[currentWebView].goBack()
    }
    
    func goForward() {
        dismissDashboard()

        webViews[currentWebView].goForward()
    }
    
    func showGoBackList(_ rec: UILongPressGestureRecognizer) {
        dismissDashboard()

        if rec.state == .began {
            backForwardFavoriteTableView = BackForwardTableViewController()
            backForwardFavoriteTableView.backForwardParentViewController = self
            backForwardFavoriteTableView.tag = 0

            let backForwardNavigationController = NavigationController(rootViewController: backForwardFavoriteTableView)
            self.navigationController?.present(backForwardNavigationController, animated: true, completion: nil)
        }
    }
    
    func showGoForwardList(_ rec: UILongPressGestureRecognizer) {
        dismissDashboard()

        if rec.state == .began {
            backForwardFavoriteTableView = BackForwardTableViewController()
            backForwardFavoriteTableView.backForwardParentViewController = self
            backForwardFavoriteTableView.tag = 1

            let backForwardNavigationController = NavigationController(rootViewController: backForwardFavoriteTableView)
            self.navigationController?.present(backForwardNavigationController, animated: true, completion: nil)
        }
    }
    
    func hideGoBackForwardFavoritesList() {
        UIView.animate(withDuration: 0.1, animations: {
            self.backForwardFavoriteTableView.dismissSelf()
            self.configtoolbaritems()
        })
    }
    
    func doRefresh() {
        dismissDashboard()

        webViews[currentWebView].reload()
    }
    
    func doStop() {
        dismissDashboard()

        webViews[currentWebView].stopLoading()
        checkGos()
        lettextfieldtohost()
        progressBar.setProgress(1.0, animated: true)
        UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: {
            self.progressBar.alpha = 0
            }, completion: nil)
        textField.configrefreshImage()
    }
    
    func toolBarSwipeSwiping() {
        switch toolBarSwipe.state {
        case .changed:
            if toolBarSwipe.translation(in: toolBar).y < -20 {
                displayDashboard()
            }
        default: true
        }
    }
    
    func displayDashboard() {
        dashboard.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: 120)
        self.view.addSubview(dashboard)
        superHugeRegretButton.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 44)
        UIView.animate(withDuration: 1, animations: {
            self.view.addSubview(self.superHugeRegretButton)
        })
        UIView.animate(withDuration: 0.2, animations: {
            self.view.bringSubview(toFront: self.dashboard)
            self.view.bringSubview(toFront: self.toolBar)
            self.dashboard.frame = CGRect(x: 0, y: self.view.frame.height - 44 - 120, width: self.view.frame.width, height: 120)
        })
    }
    
    func hidetoolbar() {
        webViews[currentWebView].frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        progressBar.frame = CGRect(x: 0, y: view.frame.height - 3, width: view.frame.width, height: 3)
        UIView.animate(withDuration: 0.2, animations: {
            self.toolBar.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 44)
        })
        toolBar.isHidden = true
        dismissDashboard()
    }
    
    func showtoolbar() {
        if (toolBar.isHidden == true) {
            toolBar.isHidden = false
            UIView.animate(withDuration: 0.2, animations: {
                self.toolBar.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44)
                self.webViews[self.currentWebView].frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44)
                self.progressBar.frame = CGRect(x: 0, y: self.view.frame.height - 47, width: self.view.frame.width, height: 3)
            })
        }
    }
    
    func dismissDashboard() {
        if (dashboard.window != nil) {
            view.bringSubview(toFront: self.toolBar)
            UIView.animate(withDuration: 0.3, animations: {
                self.dashboard.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 120)
            })
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                self.dashboard.removeFromSuperview()
                self.superHugeRegretButton.removeFromSuperview()
                print("removed from superview")
            })
        }
    }
    
    func toShare() {
        dismissDashboard()

        let myWebsite = webViews[currentWebView].viewPrintFormatter()
        let myWebsiteurl = webViews[currentWebView].url
        var objectsToShare: [AnyObject] = []

        if myWebsiteurl != nil {
            objectsToShare = [myWebsiteurl! as AnyObject, myWebsite]
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare as [AnyObject], applicationActivities: nil)

        self.present(activityVC, animated: true, completion: nil)
    }
    
    func toOpenInSafari() {
        dismissDashboard()

        var myWebsite = webViews[currentWebView].url
        if myWebsite == nil {
            myWebsite = URL(string: "")
        }

        UIApplication.shared.openURL(myWebsite!)
    }
    
    func goHome() {
        dismissDashboard()

        textField.text = homewebpage
        didClickGo()
    }
    
    func showFavorites() {
        dismissDashboard()
        backForwardFavoriteTableView = BackForwardTableViewController(style: .grouped)
        backForwardFavoriteTableView.backForwardParentViewController = self
        backForwardFavoriteTableView.tag = 2

        let backForwardNavigationController = NavigationController(rootViewController: backForwardFavoriteTableView)
        self.navigationController?.present(backForwardNavigationController, animated: true, completion: nil)
    }
    
    func showAllWebViews(_ size: CGSize = CGSize(width: 0, height: 0)) {
        var targetViewSize: CGSize {
            if (Int(size.width) == 0 && Int(size.height) == 0) {
                return view.frame.size
            } else {
                return size
            }
        }
        
        dismissDashboard()

        showingAllWebViews = true

        toolBarSwipe.isEnabled = false

        if adbanner.isBannerLoaded {
            adbanner.frame = CGRect(x: 0, y: 1, width: targetViewSize.width - 10, height: 66)
            self.view.addSubview(adbanner)
        }
        let addNewWebViewButton: UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(ViewController.addNewWebViewButtonPressed))
        let doneShowingAllWebViewsButton: UIBarButtonItem! = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(ViewController.doneShowingAllWebViews))
        let toolBarItems: [UIBarButtonItem] = [
            addNewWebViewButton,
            flexibleSpaceBarButtonItem,
            undoWebViewButton,
            flexibleSpaceBarButtonItem,
            doneShowingAllWebViewsButton
        ]
        toolBar.setItems(toolBarItems, animated: true)
        UIView.animate(withDuration: 0.5, animations: {
            self.toolBar.frame = CGRect(x: 0, y: targetViewSize.height + 44, width: targetViewSize.width, height: 44)
            self.progressBar.alpha = 0
        })

        webViewButtons = []
        webViewCloseSwipe = []
        //webViewCloseLongPress = []
        webViewLabels = []
        
        showAllWebViewsScrollView.frame = CGRect(x: 0, y: 0, width: targetViewSize.width, height: targetViewSize.height)
        self.view.addSubview(self.showAllWebViewsScrollView)
        
        for tryShowingWebView in 0...webViews.count - 1 {
            webViews[tryShowingWebView].removeFromSuperview()
            
            webViews[tryShowingWebView].frame = CGRect(x: 0, y: 0, width: targetViewSize.width, height: targetViewSize.height - 44)
            webViews[tryShowingWebView].layer.cornerRadius = 5.0
            webViews[tryShowingWebView].layer.shadowColor = UIColor.black.cgColor
            webViews[tryShowingWebView].layer.shadowRadius = 30.0
            webViews[tryShowingWebView].layer.shadowOffset = CGSize(width: 0.0, height: -20.0)
            webViews[tryShowingWebView].layer.shadowOpacity = 1
            //webViews[tryShowingWebView].scrollView.layer.cornerRadius = 5.0
            self.showAllWebViewsScrollView.addSubview(self.webViews[tryShowingWebView])
            //webViews[tryShowingWebView].allowsBackForwardNavigationGestures = false
            
            webViews[tryShowingWebView].layer.position = CGPoint(x: 20, y: CGFloat(200 * tryShowingWebView) + webViews[tryShowingWebView].layer.frame.height / 2)
            webViews[tryShowingWebView].layer.anchorPoint = CGPoint(x: 0, y: 0.5)
            var rotate: CATransform3D = CATransform3DIdentity
            rotate.m34 = CGFloat(1.0) / CGFloat(-1000.0)
            rotate = CATransform3DRotate(rotate, CGFloat(M_PI / 9), 0, 1, 0)
            rotate = CATransform3DScale(rotate, 0.9, 0.9, 0.9)
            UIView.animate(withDuration: 0.2, animations: {
                self.webViews[tryShowingWebView].layer.transform = rotate
            })
            webViews[tryShowingWebView].layer.zPosition = CGFloat(tryShowingWebView * 50)
            
            webViewLabels.insert(UILabel(), at: tryShowingWebView)
            webViewLabels[tryShowingWebView]?.frame = CGRect(x: 0, y: 0, width: targetViewSize.width, height: 20)
            if webViews[tryShowingWebView].title != nil {
                webViewLabels[tryShowingWebView]?.text = webViews[tryShowingWebView].title
            }
            webViewLabels[tryShowingWebView]?.backgroundColor = UIColor.darkGray
            webViewLabels[tryShowingWebView]?.textColor = UIColor.white
            webViewLabels[tryShowingWebView]?.textAlignment = .center
            webViewLabels[tryShowingWebView]?.layer.cornerRadius = 5.0
            webViews[tryShowingWebView].addSubview(webViewLabels[tryShowingWebView]!)

            webViewButtons.insert(UIButton(), at: tryShowingWebView)
            webViewButtons[tryShowingWebView]?.frame = CGRect(x: 0, y: 0, width: targetViewSize.width, height: targetViewSize.height)
            webViewButtons[tryShowingWebView]?.addTarget(self, action: #selector(ViewController.showWebView(_:)), for: .touchUpInside)
            webViewButtons[tryShowingWebView]?.tag = tryShowingWebView
            webViews[tryShowingWebView].addSubview(webViewButtons[tryShowingWebView]!)

            webViewCloseSwipe.insert(UIPanGestureRecognizer(), at: tryShowingWebView)
            webViewCloseSwipe[tryShowingWebView].delegate = self;
            webViewButtons[tryShowingWebView]?.addGestureRecognizer(webViewCloseSwipe[tryShowingWebView])
            webViewCloseSwipe[tryShowingWebView].addTarget(self, action: #selector(ViewController.closeWebViewPan(_:)))

            //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: tryShowingWebView)
            //webViewButtons[tryShowingWebView]?.addGestureRecognizer(webViewCloseLongPress[tryShowingWebView])
            //webViewCloseLongPress[tryShowingWebView].addTarget(self, action: <#Selector#>)

        }
        
        self.showAllWebViewsScrollView.contentSize = CGSize(width: targetViewSize.width, height: self.webViews[webViews.count - 1].frame.origin.y + targetViewSize.height)

        UIView.animate(withDuration: 0.5, animations: {
            self.toolBar.frame = CGRect(x: 0, y: targetViewSize.height - 44, width: targetViewSize.width, height: 44)
        })

        self.view.bringSubview(toFront: toolBar)
        self.view.bringSubview(toFront: adbanner)
    }
    
    func doneShowingAllWebViews() {
        if currentWebView < webViews.count - 1 && currentWebView > 0 {
            for i in 0...currentWebView - 1 {
                UIView.animate(withDuration: 0.75, animations: {
                    self.webViews[i].frame = CGRect(x: 0, y: 0 - self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height)
                }, completion: {(value: Bool) in
                    self.webViews[i].removeFromSuperview()
                })
                webViews[i].layer.zPosition = 0;
                webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                webViewButtons[i]?.removeFromSuperview()
                webViewLabels[i]?.removeFromSuperview()
            }
            webViews[currentWebView].layer.zPosition = 0;
            webViewButtons[currentWebView]?.removeGestureRecognizer(webViewCloseSwipe[currentWebView])
            self.webViews[currentWebView].removeFromSuperview()
            self.view.addSubview(webViews[currentWebView])
            //webViewButtons[currentWebView]?.removeGestureRecognizer(webViewCloseLongPress[currentWebView])
            webViewButtons[currentWebView]?.removeFromSuperview()
            webViewLabels[currentWebView]?.removeFromSuperview()
            for i in currentWebView + 1...webViews.count - 1 {
                UIView.animate(withDuration: 0.75, animations: {
                    self.webViews[i].frame = CGRect(x: 0, y: self.view.frame.height * 2, width: self.view.frame.width, height: self.view.frame.height)
                }, completion: {(value: Bool) in
                    self.webViews[i].removeFromSuperview()
                })
                webViews[i].layer.zPosition = 0;
                webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                webViewButtons[i]?.removeFromSuperview()
                webViewLabels[i]?.removeFromSuperview()
            }
        } else {
            for i in 0...webViews.count - 1 {
                webViews[i].layer.zPosition = 0;
                webViews[i].removeFromSuperview()
                webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                webViewButtons[i]?.removeFromSuperview()
                webViewLabels[i]?.removeFromSuperview()
            }
        }

        UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.webViews[self.currentWebView].layer.transform = CATransform3DIdentity
            self.webViews[self.currentWebView].frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - 44)
        }, completion: nil)
        self.view.addSubview(webViews[currentWebView])
        
        UIView.animate(withDuration: 0.5, animations: {
            self.toolBar.frame = CGRect(x: 0, y: self.view.frame.height + 44, width: self.view.frame.width, height: 44)
        })
        configtoolbaritems()
        UIView.animate(withDuration: 0.5, animations: {
            self.toolBar.frame = CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44)
        })
        toolBarSwipe.isEnabled = true
        checkGos()
        lettextfieldtohost()
        textField.configrefreshImage()
        refreshControl.endRefreshing()
        if webViews[currentWebView].isLoading {
            progressBar.setProgress(Float(webViews[currentWebView].estimatedProgress) + 0.01, animated: true)
            UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: {
                self.progressBar.alpha = 1
                }, completion: nil)
        } else {
            progressBar.setProgress(1.0, animated: true)
            UIView.animate(withDuration: 0.3, delay: 0.5, options: UIViewAnimationOptions(), animations: {
                self.progressBar.alpha = 0
                }, completion: nil)
        }

        self.view.bringSubview(toFront: showButton)
        self.view.bringSubview(toFront: toolBar)
        self.view.bringSubview(toFront: progressBar)

        webViewButtons = []
        webViewCloseSwipe = []
        //webViewCloseLongPress = []
        webViewLabels = []

        showingAllWebViews = false

        if isAdbannerEnoughSecondsYet {
            adbanner.removeFromSuperview()
        } else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 66)
                webViews[currentWebView].frame = CGRect(x: 0, y: 66, width: view.frame.width, height: view.frame.height - 44 - 66) //44: toolbar height; 66: adbanner height
            } else {
                if UIScreen.main.bounds.size.height > UIScreen.main.bounds.size.width {
                    adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
                    webViews[currentWebView].frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 44 - 50) //44: toolbar height; 50: adbanner height
                } else {
                    adbanner.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 32)
                    webViews[currentWebView].frame = CGRect(x: 0, y: 32, width: view.frame.width, height: view.frame.height - 44 - 32) //44: toolbar height; 32: adbanner height
                }
            }
        }
    }
    
    func changeOrientationLock() {
        if orientationlockbutton.tag == 0 {
            lockOrientation()
            let img = UIImage(named: "orientationlock_locked.png")
            orientationlockbutton.setImage(img, for: UIControlState())
        } else {
            unlockOrientation()
            let img = UIImage(named: "orientationlock_unlocked.png")
            orientationlockbutton.setImage(img, for: UIControlState())
        }
    }
    
    func lockOrientation() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        orientationlockbutton.tag = 1
        //self.shouldAutorotate = false
    }
    
    func unlockOrientation() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.orientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        orientationlockbutton.tag = 0
        //self.shouldAutorotate = true
    }
    
    func addNewWebViewButtonPressed() {
        addNewWebView()
        Timer.scheduledTimer(timeInterval: 1, target: textField, selector: #selector(UIResponder.becomeFirstResponder), userInfo: nil, repeats: false)
    }
    
    func addNewWebView() {
        webViews.insert(CustomWKWebView(), at: webViews.endIndex)
        currentWebView = webViews.endIndex - 1
        totalWebView += 1
        webViews[currentWebView].navigationDelegate = self
        webViews[currentWebView].uiDelegate = self
        webViews[currentWebView].allowsBackForwardNavigationGestures = true
        webViews[currentWebView].scrollView.addSubview(refreshControl)
        webViewButtons.insert(UIButton(), at: webViews.count - 1)
        webViewCloseSwipe.insert(UIPanGestureRecognizer(), at: webViews.count - 1)
        //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: webViews.count - 1)
        webViewLabels.insert(UILabel(), at: webViews.count - 1)

        webViews[currentWebView].frame = CGRect(x: 20, y: view.frame.height + 50, width: view.frame.width - 40, height: view.frame.height - 44)
        webViews[currentWebView].layer.cornerRadius = 5.0
        webViews[currentWebView].layer.shadowColor = UIColor.black.cgColor
        webViews[currentWebView].layer.shadowRadius = 5.0
        webViews[currentWebView].layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        webViews[currentWebView].layer.shadowOpacity = 1
        //webViews[currentWebView].scrollView.layer.cornerRadius = 5.0
        
        self.view.addSubview(webViews[currentWebView])
        self.view.bringSubview(toFront: toolBar)
        UIView.animate(withDuration: 0.75, animations: {
            self.webViews[self.currentWebView].frame = CGRect(x: 20, y: 0, width: self.view.frame.width - 40, height: self.view.frame.height - 44)
        }, completion: {(value: Bool) in
            self.doneShowingAllWebViews()
        })
    }
    
    func showWebView(_ sender: UIButton) {
        currentWebView = sender.tag
        doneShowingAllWebViews()
    }
    
    func undoPreviousWebView() {
        undoWebViewButton.isEnabled = false
        webViews.insert(undoWebView!, at: webViews.endIndex)
        currentWebView = webViews.endIndex - 1
        webViews[currentWebView].navigationDelegate = self
        webViews[currentWebView].uiDelegate = self
        webViews[currentWebView].allowsBackForwardNavigationGestures = true
        webViewButtons.insert(UIButton(), at: webViews.count - 1)
        webViewCloseSwipe.insert(UIPanGestureRecognizer(), at: webViews.count - 1)
        //webViewCloseLongPress.insert(UILongPressGestureRecognizer(), atIndex: webViews.count - 1)
        webViewLabels.insert(UILabel(), at: webViews.count - 1)
        webViews[currentWebView].frame = CGRect(x: 20, y: view.frame.height + 50, width: view.frame.width - 40, height: view.frame.height - 44)

        doneShowingAllWebViews()
        totalWebView += 1
    }
    
    func closeWebViewPan(_ rec: UIPanGestureRecognizer) {
        let y = rec.view?.tag
        let z = y!

        switch rec.state {
        case .began:
            if !isLongPressed {
                if rec.view != nil {
                }
                weby = CGFloat(webViews[0].frame.origin.y)
            } else {

            }
        case .changed:
            if !isLongPressed {
                if panInit < 3 {
                    panInit += 1
                } else if panInit == 3 {
                    if abs(rec.translation(in: self.view!).x) > abs(rec.translation(in: self.view!).y) {
                        panInitdir = true
                    } else {
                        panInitdir = false
                    }
                    panInit += 1
                } else if (rec.view != nil) && (panInitdir) && (panInit > 3) && (rec.translation(in: rec.view!).x > 0) {
                    showAllWebViewsScrollView.isScrollEnabled = false;
                    
                    let thenewx = rec.translation(in: self.view).x
                    
                    panningRightToCloseWebView(z, thenewx: thenewx)
                } else if (rec.view != nil) && (panInitdir) && (panInit > 3) && (rec.translation(in: self.view!).x < 0) {
                    /*
                    let transy = rec.translationInView(self.view!).y

                    if transy < -20 {
                    let content = webViews[z].scrollView
                    let contentoffset = content?.contentOffset
                    let contentx = contentoffset?.x
                    let contenty = contentoffset?.y
                    content?.setContentOffset(CGPointMake(contentx!, contenty! - 20), animated: true)
                    } else if transy > 20 {
                    let content = webViews[z].scrollView
                    let contentoffset = content?.contentOffset
                    let contentx = contentoffset?.x
                    let contenty = contentoffset?.y
                    content?.setContentOffset(CGPointMake(contentx!, contenty! + 20), animated: true)

                    }*/
                }/* else if (rec.view != nil) && (!panInitdir) {
                    if rec.translationInView(self.view).y < 0 {
                        let weboriginy = webViews[totalWebView - 1].frame.maxY
                        if weboriginy > view.frame.height {
                            for i in 0...webViews.count - 1 {
                                webViews[i].frame = CGRectMake(20, weby + 200 * CGFloat(i) + rec.translationInView(self.view!).y, view.frame.width - 40, view.frame.height)
                            }
                        }/* else  {
                        for i in 0...webViews.count - 1 {
                        webViews[i].frame = CGRectMake(20, weby + 200 * CGFloat(i) + rec.translationInView(self.view!).y + 200 / rec.translationInView(self.view!), view.frame.width - 40, view.frame.height)
                        }
                        }*/
                    } else if rec.translationInView(self.view).y > 0 {
                        if webViews[0].frame.origin.y < 0 {
                            for i in 0...webViews.count - 1 {
                                webViews[i].frame = CGRectMake(20, weby + 200 * CGFloat(i) + rec.translationInView(self.view!).y, view.frame.width - 40, view.frame.height)
                            }
                        }
                    }
                }*/
            } else {
                //change the order of the webViews with long press
                print("changing the order of the webViews with long press")
            }
        case .ended:
            if !isLongPressed {
                if (panInitdir) {  //end of closing a webView by moving right
                    if (Int(rec.translation(in: webViews[z]).x) > 200) {
                        closeWebView(z)
                    } else {  //did not moved right enough to close the webView
                        //let myframe = CGRectMake(20, weby + 200 * CGFloat(z), view.frame.width - 40, view.frame.height)
                        //webViews[z].frame = myframe
                        //webViews[z].layer.position = CGPointMake(20, 200 * CGFloat(z))
                        var newTransform: CATransform3D = CATransform3DIdentity
                        newTransform.m34 = CGFloat(1.0) / CGFloat(-1000.0)
                        newTransform = CATransform3DRotate(newTransform, CGFloat(M_PI / 9), 0, 1, 0)
                        newTransform = CATransform3DScale(newTransform, 0.9, 0.9, 0.9)
                        self.webViews[z].layer.transform = newTransform
                        webViews[z].alpha = 1
                    }
                    showAllWebViewsScrollView.isScrollEnabled = true;
                } else if (!panInitdir) {  //end of moving webViews up and down
                    /*weby = CGFloat(webViews[0].frame.origin.y)
                    //arrange webViews if there are space after the last and before the first webViews
                    if webViews[totalWebView - 1].frame.maxY < view.frame.height {
                        weby = weby + view.frame.height - webViews[totalWebView - 1].frame.maxY
                    } else if webViews[0].frame.origin.y > 0 {
                        weby = weby - webViews[0].frame.origin.y
                    }*/
                }
                panInit = 0
            } else {
                //change order of web views
                isLongPressed = false
                print("end of changing the order of the webViews with long press")
            }
        default: true
        }
    }
    
    func panningRightToCloseWebView(_ indexOfWebView: Int, thenewx: CGFloat) {
        let z = indexOfWebView
        
        var scale = abs(thenewx / 200) // for calculation of alpha and transformation scale
        if scale > 1 {
            scale = 1
        }
        webViews[z].alpha = 1 - scale
        
        var newTransform: CATransform3D = CATransform3DIdentity
        newTransform.m34 = CGFloat(1.0) / CGFloat(-1000.0)
        newTransform = CATransform3DRotate(newTransform, CGFloat(M_PI / 9) + scale / 3, 0, 1, 0)
        newTransform = CATransform3DScale(newTransform, 0.9, 0.9, 0.9)
        newTransform = CATransform3DTranslate(newTransform, thenewx * (5 * scale), 0, 0)//-thenewx / 4
        UIView.animate(withDuration: 0.1, animations: {
            self.webViews[z].layer.transform = newTransform
        })
    }
    
    func closeWebView(_ indexOfWebView: Int) {
        let z = indexOfWebView
        
        webViews[z].alpha = 1
        undoWebView = webViews[z]
        undoWebViewButton.isEnabled = true
        webViewLabels[z]?.removeFromSuperview()
        webViewLabels.remove(at: z)
        webViewButtons[z]?.removeFromSuperview()
        webViewButtons.remove(at: z)
        webViews[z].removeFromSuperview()
        webViews.remove(at: z)
        totalWebView -= 1
        currentWebView = webViews.endIndex - 1
        if totalWebView < 1 {  //no more webview
            weby = 0
            addNewWebViewButtonPressed()
        } else {
            //arrange webViews if there are space after the last and before the first webViews
            if webViews[totalWebView - 1].frame.maxY < view.frame.height {
                weby = weby + view.frame.height - webViews[totalWebView - 1].frame.maxY
            } else if webViews[0].frame.origin.y > 0 {
                weby = weby - webViews[0].frame.origin.y
            }
            //prep for showAllWebViews()
            for i in 0...webViews.count - 1 {
                webViewLabels[i]?.removeFromSuperview()
                webViews[i].removeFromSuperview()
                webViewButtons[i]?.removeGestureRecognizer(webViewCloseSwipe[i])
                //webViewButtons[i]?.removeGestureRecognizer(webViewCloseLongPress[i])
                webViewButtons[i]?.removeFromSuperview()
            }
            
            self.view.bringSubview(toFront: showButton)
            self.view.bringSubview(toFront: toolBar)
            self.view.bringSubview(toFront: progressBar)
            
            webViewButtons = []
            webViewCloseSwipe = []
            //webViewCloseLongPress = []
            webViewLabels = []
            
            showAllWebViews()
        }
    }
    
    func longPressed(_ press: UILongPressGestureRecognizer) {
        switch press.state {
        case .began:
            isLongPressed = true
        case .cancelled:
            isLongPressed = false
        case .ended:
            isLongPressed = false
        default: true
        }
    }
    
}
