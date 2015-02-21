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
    
    override func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(self, forKey: "customWKWebView")
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
