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
        pageControl.numberOfPages = 3
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = UIColor.lightGrayColor()
        pageControl.currentPageIndicatorTintColor = UIColor.darkGrayColor()
        
        var firstImageView = UIImageView(image: UIImage(named: "img1.png"))
        firstImageView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        firstImageView.contentMode = .ScaleAspectFit
        firstImageView.backgroundColor = UIColor(red: 0.3254, green: 0.7960, blue: 0.9921, alpha: 0.5)
        
        var secondImageView = UIImageView(image: UIImage(named: "img2.png"))
        secondImageView.frame = CGRectMake(view.frame.width, 0, view.frame.width, view.frame.height)
        secondImageView.contentMode = .ScaleAspectFit
        
        var thirdImageView = UIImageView(image: UIImage(named: "img3.png"))
        thirdImageView.frame = CGRectMake(view.frame.width * 2, 0, view.frame.width, view.frame.height)
        thirdImageView.contentMode = .ScaleAspectFit
        
        scrollView.pagingEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.alwaysBounceVertical = false
        scrollView.multipleTouchEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.frame = CGRectMake(0, 0, view.frame.width, view.frame.height)
        scrollView.contentSize = CGSizeMake(view.frame.width * 3, view.frame.height - 1)
        scrollView.delegate = self
        scrollView.addSubview(firstImageView)
        scrollView.addSubview(secondImageView)
        scrollView.addSubview(thirdImageView)
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
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        var pageWidth: CGFloat = scrollView.frame.size.width
        var contentoffsetx: CGFloat = scrollView.contentOffset.x
        var fractionalPage = contentoffsetx / pageWidth
        var page: NSInteger = lroundf(Float(fractionalPage))
        pageControl.currentPage = page
        pageControl.frame = CGRectMake(contentoffsetx, view.frame.height - 35, view.frame.width, 10)
    }
    
    func finishDemo() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
