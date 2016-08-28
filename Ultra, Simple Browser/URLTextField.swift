//
//  URLTextField.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/1/22.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class URLTextField: UITextField, XMLParserDelegate {
    
    var parentViewController: ViewController!
    
    // override drawRect to perform custom drawing.
    override func draw(_ rect: CGRect) {
        self.leftViewMode = .unlessEditing
        self.tintColor = UIColor.gray
        self.textAlignment = .center
        self.returnKeyType = .go
        self.placeholder = "Enter URL or Search"
        self.adjustsFontSizeToFitWidth = true
        self.clearButtonMode = .whileEditing
        self.keyboardType = .webSearch
        self.spellCheckingType = .no
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.enablesReturnKeyAutomatically = true
        self.font = UIFont(name: "Arial", size: 17)
        self.addTarget(self, action: #selector(URLTextField.textFieldDidChanged), for: .editingChanged)
    }
    func configrefreshImage() {
        let refreshImage = UIImage(named: "refreshimage.png")!
        let refreshImageButton = UIButton(type: .custom)
        refreshImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        refreshImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        refreshImageButton.setImage(refreshImage, for: UIControlState())
        refreshImageButton.addTarget(self, action: #selector(URLTextField.doRefresh), for: .touchUpInside)
        self.leftView = refreshImageButton
    }
    
    func doRefresh() {
        parentViewController.doRefresh()
    }
    
    func configstopImage() {
        let stopImage = UIImage(named: "stopimage.png")!
        let stopImageButton = UIButton(type: .custom)
        stopImageButton.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        stopImageButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 3)
        stopImageButton.setImage(stopImage, for: UIControlState())
        stopImageButton.addTarget(self, action: #selector(URLTextField.doStop), for: .touchUpInside)
        self.leftView = stopImageButton
    }
    
    func doStop() {
        parentViewController.doStop()
    }
    
    func textFieldDidChanged() {
        parentViewController.textFieldDidChanged()
    }
    
}
