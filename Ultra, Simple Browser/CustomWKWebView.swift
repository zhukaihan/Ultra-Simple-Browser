//
//  CustomeWKWebView.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/17.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit
import WebKit

class CustomWKWebView: WKWebView {
    
    var WebViewParentViewContoller: ViewController!
    
    override func encode(with aCoder: NSCoder) {
        aCoder.encode(self, forKey: "customWKWebView")
    }
    
    override func draw(_ rect: CGRect) {
        print("WKWebView drawRect called")
    }
}
