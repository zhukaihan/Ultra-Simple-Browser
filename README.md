#How does README in Github works? It is so strange.
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

1. Photoshop Images are images made by Photoshop and in Photoshop format. All of images in PNG format are in Ultra, Simple Browser/PNG Images. 
2. Settings.Bundle is something let settings show up in Settings(of iOS), you can download it from App Store and have a taste of settings in Settings and have a sense what is it(I don't know why, but Xcode just created there. It is kind of (a word here is missing, you need to use your imagination to sense this word)).
3. The xcodeproj. You know what is it.
4. The Ultra, Simple Browser folder. It is the folder where every thing is. 
5. The Tests. Never used it. It is not right for me. But it is not bothering me, so I let it be like that.

**Stuff in Ultra, Simple Browser**

1. Images.xcassets. Only contains icons. 
2. PNG Images. The images actually uses in app. 
3. the Core Data model. It is what it is. 
4. let's talk about swift files from the most important to the least important. 
5. First, ViewController.swift. It is the heart of the App. It is about 1300 lines long(Horrible code design. I know). It mostly interacts with UI. It is the one and the only one linked to the storyboard, although there is nothing in the storyboard
6. Second, let's say, toolBarItems.swift. It only configs the backButton and the forwardButton. I just to want to make the code shorter. BUT, it is the most basic feature in a browser: go back and go forward. 
7. Third, URLTextField.swift. It is the URL text field. It acts as a host title bar when it is not the first responser. 
8. Fourth, here we go, SuggestionViewController.swift(Although I think SuggestionViewController is more important, I put it at the fourth). It is a child view controller under ViewController. It give suggestions, such as the top 20 website that human beings visits, the favorites that user created,                   the websites that user visits over ten times, and histories user visited. 
9. Fifth, BackForwardTableViewController.swift. The TableViewController that displays the backList and forwardList of the WKWebView, favorites and histories. 
10. Sixth, AddNewFavoriteItemTableViewController.swift. The TableViewController that let user add new favorite item to Favorites
11. Seventh, DemoViewController.swift. The ViewController just like it named(although every controller named by its functions). It guide user to use this browser at its first launch. 
12. Eightth(Eighth?), 

[appstorelink]: http://itunes.apple.com/us/app/ultra-simple-browser/id952551914?mt=8
[githublink]: http://github.com/zhukaihan/Ultra-Simple-Browser
