//
//  DemoViewController.swift
//  Ultra, Simple Browser
//
//  Created by Peter Zhu on 15/2/3.
//  Copyright (c) 2015年 Peter Zhu. All rights reserved.
//

import UIKit

class DemoViewController: UIViewController, UIScrollViewDelegate {

    var scrollView: UIScrollView = UIScrollView()
    var pageControl: UIPageControl = UIPageControl()
    var finishButton: UIButton = UIButton()
    var firstTimeToPageZero: Bool = true
    var firstTimeToPageOne: Bool = true
    var firstTimeToPageTwo: Bool = true
    var firstTimeToPageThree: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        self.view.backgroundColor = UIColor.darkGrayColor()
        
        finishButton.frame = CGRectMake(10, 10, 100, 35)
        finishButton.backgroundColor = UIColor.grayColor()
        finishButton.setTitle("close", forState: .Normal)
        finishButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        finishButton.addTarget(self, action: "finishDemo", forControlEvents: .TouchUpInside)
        
        pageControl.frame = CGRectMake(0, view.frame.height - 35, view.frame.width, 10)
        pageControl.numberOfPages = 5
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        
        var firstImageView = UIImageView(image: UIImage(named: "DemoImage0.png"))
        firstImageView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        firstImageView.contentMode = .ScaleAspectFit
        firstImageView.backgroundColor = UIColor(red: 0.3254, green: 0.7960, blue: 0.9921, alpha: 0.6)
        
        var secondImageView = UIImageView(image: UIImage(named: "DemoImage1.png"))
        secondImageView.frame = CGRectMake(view.frame.width, 0, view.frame.width, view.frame.height)
        secondImageView.contentMode = .ScaleAspectFit
        
        var thirdImageView = UIImageView(image: UIImage(named: "DemoImage2.png"))
        thirdImageView.frame = CGRectMake(view.frame.width * 2, 0, view.frame.width, view.frame.height)
        thirdImageView.contentMode = .ScaleAspectFit
        
        var fourthImageView = UIImageView(image: UIImage(named: "DemoImage3.png"))
        fourthImageView.frame = CGRectMake(view.frame.width * 3, 0, view.frame.width, view.frame.height)
        fourthImageView.contentMode = .ScaleAspectFit
        
        var fifthImageView = UIImageView(image: UIImage(named: "DemoImage4.png"))
        fifthImageView.frame = CGRectMake(view.frame.width * 4, 0, view.frame.width, view.frame.height)
        fifthImageView.contentMode = .ScaleAspectFit
        
        scrollView.pagingEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.multipleTouchEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        scrollView.contentSize = CGSizeMake(view.frame.width * 5, view.frame.height - 1)
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
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat = scrollView.frame.size.width
        var contentoffsetx: CGFloat = scrollView.contentOffset.x
        var fractionalPage = contentoffsetx / pageWidth
        var page: NSInteger = lroundf(Float(fractionalPage))
        pageControl.currentPage = page
        pageControl.frame = CGRectMake(contentoffsetx, view.frame.height - 35, view.frame.width, 10)
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
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
