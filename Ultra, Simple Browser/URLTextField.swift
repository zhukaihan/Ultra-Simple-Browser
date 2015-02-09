//
//  URLTextField.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/1/22.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class URLTextField: UITextField {
    
    var parentViewController: ViewController!
    
    // override drawRect to perform custom drawing.
    override func drawRect(rect: CGRect) {
        self.leftViewMode = .UnlessEditing
        self.tintColor = UIColor.grayColor()
        self.textAlignment = .Center
        self.returnKeyType = .Go
        self.placeholder = "Enter URL or Search"
        self.adjustsFontSizeToFitWidth = true
        self.clearButtonMode = .WhileEditing
        self.keyboardType = .WebSearch
        self.spellCheckingType = .No
        self.autocapitalizationType = .None
        self.autocorrectionType = .No
        self.enablesReturnKeyAutomatically = true
        self.font = UIFont(name: "Arial", size: 17)
        self.addTarget(self, action: "textFieldDidChanged", forControlEvents: .EditingChanged)
    }
    
    func configrefreshImage() {
        let refreshImage = UIImage(named: "refreshimage.png")!
        let refreshImageButton = UIButton.buttonWithType(.Custom) as UIButton
        refreshImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        refreshImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        refreshImageButton.setImage(refreshImage, forState: .Normal)
        refreshImageButton.addTarget(self, action: "doRefresh", forControlEvents: .TouchUpInside)
        self.leftView = refreshImageButton
    }
    
    func doRefresh() {
        parentViewController.doRefresh()
    }
    
    func configstopImage() {
        let stopImage = UIImage(named: "stopimage.png")!
        let stopImageButton = UIButton.buttonWithType(.Custom) as UIButton
        stopImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        stopImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        stopImageButton.setImage(stopImage, forState: .Normal)
        stopImageButton.addTarget(self, action: "doStop", forControlEvents: .TouchUpInside)
        self.leftView = stopImageButton
    }
    
    func doStop() {
        parentViewController.doStop()
    }
    
    func textFieldDidChanged() {
        parentViewController.textFieldDidChanged()
    }
    
}
