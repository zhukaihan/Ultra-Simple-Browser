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
    
    override func drawRect(rect: CGRect) {
        println("WKWebView drawRect called")
        var controller: WKUserContentController = WKUserContentController()
        controller.addScriptMessageHandler(self, name: "myHandler")
        self.configuration.userContentController = controller
    }
    
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        println("Javascript Evaluation Requested.")
        self.evaluateJavaScript(message.body as String, completionHandler: {(value: (AnyObject!, NSError!)) in
            println("good")
        })
    }
    
}
