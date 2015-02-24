# Ultra-Simple-Browser
* It is a browser.
* Download at [App Store] [appstorelink]
* Code on [my github] [githublink]
* Website at ultrasimplebrowser.zhukaihan.com
* Everything is made by me, basicly. 
* All codes are in swift, in my opinion. 
* Ultra, Simple Browser is copyright 2014-2015 Kaihan Zhu. No copyleft yet. 
* You can download it and open it in Xcode. 

#Files
**First Level**

1. **Photoshop Images** are images made by Photoshop and in Photoshop format. All of images in PNG format are in Ultra, Simple Browser/PNG Images. 
2. **Settings.Bundle** is something let settings show up in Settings(of iOS), you can download it from App Store and have a taste of settings in Settings and have a sense what is it(I don't know why, but Xcode just created there. It is kind of (a word here is missing, you need to use your imagination to sense this word)).
3. **xcodeproj**. You know what is it.
4. **Ultra, Simple Browser** folder. It is the folder where every thing is. 
5. **Tests**. Never used it. It is not right for me. But it is not bothering me, so I let it be like that.

**Stuff in Ultra, Simple Browser**

* **Images.xcassets** Only contains icons. 
* **PNG Images** The images actually uses in app. 
* **Core Data model** It is what it is. 
* **ViewController.swift** It is the heart of the App. It is about 1300 lines long(Horrible code design. I know). It mostly interacts with UI. It is the one and the only one linked to the storyboard, although there is nothing in the storyboard
* **toolBarItems.swift** It only configs the backButton and the forwardButton. I just to want to make the code shorter. BUT, it is the most basic feature in a browser: go back and go forward. 
* **URLTextField.swift** It is the URL text field. It acts as a host title bar when it is not the first responser. 
* **SuggestionViewController.swift** It is a child view controller under ViewController. It give suggestions, such as the top 20 website that human beings visits, the favorites that user created,                   the websites that user visits over ten times, and histories user visited. 
* **BackForwardTableViewController.swift** The TableViewController that displays the backList and forwardList of the WKWebView, favorites and histories. 
* **AddNewFavoriteItemTableViewController.swift** The TableViewController that let user add new favorite item to Favorites
* **DemoViewController.swift** The ViewController just like it named(although every controller named by its functions). It guide user to use this browser at its first launch. 
* **NavigationController.swift** It is a key for autoRotate.
* **AppDelegate.swift** AppDelegate.swift. Do I need to say more?
* **AlertController.swift** Will be use for downloading videos. Downloading videos is one of the ideas in list. Just don't know how to detect videos in website.
* **CustomWKWebView.swift** It is a tryout for NSCoding. Ofcourse, failed. I try this out because NSKeyedArchiver and NSKeyedUnarchiver does not work for some god d**n reason. 
* **Info.plist** Just some orientation problem. Orientation is an big issue. Thank God, I fixed it (not in this plist). 
* **(html)** That was planned to use for some internet connection error handling. Ofcourse, failed again.
* **Description** Very, very, ultra, super, old file. It adds comments for ViewController. Haven't update it for a while. I will PROBABLY update it sometime. 

**That's pretty much it. Suggestions are always welcome. Criticizes are slightly not so welcome, but still welcome if the criticizes are useful (such as improve your code design!!!!!).**

[appstorelink]: http://itunes.apple.com/us/app/ultra-simple-browser/id952551914?mt=8
[githublink]: http://github.com/zhukaihan/Ultra-Simple-Browser
