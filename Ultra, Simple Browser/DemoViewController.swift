//
//  DemoViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/3.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController, UIScrollViewDelegate {

    var demoParentViewController: ViewController!
    
    var scrollView: UIScrollView = UIScrollView()
    var pageControl: UIPageControl = UIPageControl()
    var finishButton: UIButton = UIButton()
    var firstTimeToPageZero: Bool = true
    var firstTimeToPageOne: Bool = true
    var firstTimeToPageTwo: Bool = true
    var firstTimeToPageThree: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        self.view.backgroundColor = UIColor.darkGray
        
        finishButton.frame = CGRect(x: 10, y: 10, width: 100, height: 35)
        finishButton.layer.cornerRadius = 10
        finishButton.backgroundColor = UIColor.gray
        finishButton.setTitle("close", for: UIControlState())
        finishButton.setTitleColor(UIColor.white, for: UIControlState())
        finishButton.addTarget(self, action: #selector(DemoViewController.finishDemo), for: .touchUpInside)
        
        pageControl.frame = CGRect(x: 0, y: view.frame.height - 35, width: view.frame.width, height: 10)
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.currentPageIndicatorTintColor = UIColor.darkGray
        
        let firstImageView = UIImageView(image: UIImage(named: "DemoImage0.png"))
        firstImageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        firstImageView.contentMode = .scaleAspectFit
        
        let secondImageView = UIImageView(image: UIImage(named: "DemoImage1.png"))
        secondImageView.frame = CGRect(x: view.frame.width, y: 0, width: view.frame.width, height: view.frame.height)
        secondImageView.contentMode = .scaleAspectFit
        
        let thirdImageView = UIImageView(image: UIImage(named: "DemoImage2.png"))
        thirdImageView.frame = CGRect(x: view.frame.width * 2, y: 0, width: view.frame.width, height: view.frame.height)
        thirdImageView.contentMode = .scaleAspectFit
        
        let fourthImageView = UIImageView(image: UIImage(named: "DemoImage3.png"))
        fourthImageView.frame = CGRect(x: view.frame.width * 3, y: 0, width: view.frame.width, height: view.frame.height)
        fourthImageView.contentMode = .scaleAspectFit
        
        let fifthImageView = UIImageView(image: UIImage(named: "DemoImage4.png"))
        fifthImageView.frame = CGRect(x: view.frame.width * 4, y: 0, width: view.frame.width, height: view.frame.height)
        fifthImageView.contentMode = .scaleAspectFit
        
        let backgroundImg = UIImageView(image: UIImage(named: "icon_background.png"))
        backgroundImg.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        backgroundImg.contentMode = .scaleAspectFill
        self.view.addSubview(backgroundImg)
        
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.isMultipleTouchEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * 5, height: view.frame.height - 1)
        scrollView.delegate = self
        scrollView.addSubview(firstImageView)
        scrollView.addSubview(secondImageView)
        scrollView.addSubview(thirdImageView)
        scrollView.addSubview(fourthImageView)
        scrollView.addSubview(fifthImageView)
        scrollView.addSubview(pageControl)
        self.view.addSubview(scrollView)
        
        self.view.addSubview(finishButton)
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
/*
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth: CGFloat = scrollView.frame.size.width
        let contentoffsetx: CGFloat = scrollView.contentOffset.x
        let fractionalPage = contentoffsetx / pageWidth
        let page: NSInteger = lroundf(Float(fractionalPage))
        pageControl.currentPage = page
        pageControl.frame = CGRect(x: contentoffsetx, y: view.frame.height - 35, width: view.frame.width, height: 10)
        if ((page == 0) && (firstTimeToPageZero)) {
            
        }
        if ((page == 1) && (firstTimeToPageOne)) {
            
        }
        if ((page == 2) && (firstTimeToPageTwo)) {
            
        }
        if ((page == 3) && (firstTimeToPageThree)) {
            
        }
    }
    
    func finishDemo() {
        self.dismiss(animated: true, completion: {
            self.demoParentViewController.demo()
        })
    }
    
}
