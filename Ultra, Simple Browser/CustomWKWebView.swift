//
//  CustomeWKWebView.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/17.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit
import WebKit

class CustomWKWebView: WKWebView, WKScriptMessageHandler {
    
    var WebViewParentViewContoller: ViewController!
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self, forKey: "customWKWebView")
    }
    
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        var controller: WKUserContentController = WKUserContentController()
        controller.addScriptMessageHandler(self, name: "myHandler")
        self.configuration.userContentController = controller
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        self.evaluateJavaScript(message.body as String, completionHandler: {(value: (AnyObject!, NSError!)) in
            println("good")
        })
    }
    
}
