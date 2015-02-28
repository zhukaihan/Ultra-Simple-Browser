//
//  toolBarItems.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/1/22.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class backNavigationButton: UIButton {
    override func drawRect(rect: CGRect) {
        let backimg = UIImage(named: "backbutton.png")
        self.setBackgroundImage(backimg, forState: .Normal)
        self.frame = CGRectMake(0, 0, 30, 30)
        self.addTarget(self, action: "goBack", forControlEvents: .TouchUpInside)
        let backButtonLongPress = UILongPressGestureRecognizer(target: self, action: "showGoBackList:")
        backButtonLongPress.minimumPressDuration = 1
        self.addGestureRecognizer(backButtonLongPress)
    }
}

class forwardNavigationButton: UIButton {
    override func drawRect(rect: CGRect) {
        let forwardimg = UIImage(named: "forwardbutton.png")
        let forwardbutton = UIButton()
        forwardbutton.setBackgroundImage(forwardimg, forState: .Normal)
        forwardbutton.frame = CGRectMake(0, 0, 30, 30)
        forwardbutton.addTarget(self, action: "goForward", forControlEvents: .TouchUpInside)
        let forwardButtonLongPress = UILongPressGestureRecognizer(target: self, action: "showGoForwardList:")
        forwardButtonLongPress.minimumPressDuration = 1
        forwardbutton.addGestureRecognizer(forwardButtonLongPress)
    }
}

/*
textItem = UIBarButtonItem(customView: textField)
let webViewSwitchimg = UIImage(named: "pages.png")
let webViewSwitchbutton = UIButton()
webViewSwitchbutton.setBackgroundImage(webViewSwitchimg, forState: .Normal)
webViewSwitchbutton.frame = CGRectMake(0, 0, 30, 30)
webViewSwitchbutton.addTarget(self, action: "showAllWebViews", forControlEvents: .TouchUpInside)
webViewSwitch = UIBarButtonItem(customView: webViewSwitchbutton)
webViewSwitch.enabled = true*/