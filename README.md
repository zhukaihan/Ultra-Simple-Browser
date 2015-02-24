#How does README in Github works? It is so strange.
# Ultra-Simple-Browser
It is a browser.
Download at https://itunes.apple.com/us/app/ultra-simple-browser/id952551914?mt=8
Code on github.com/zhukaihan/Ultra-Simple-Browser
Website at ultrasimplebrowser.zhukaihan.com
So, let's get started:

1. everything is made by me, basicly. 
2. all codes are in swift, in my opinion. 
3. copyright me. No copyleft yet. 
4. you can download it and open it in Xcode. 
5. let's talk about the folders and files. 

#Files
**First Level**

1. Photoshop Images are images made by Photoshop and in Photoshop format. All of images in PNG format are in Ultra, Simple Browser/PNG Images. 
2. Settings.Bundle is something let settings show up in Settings(of iOS), you can download it from App Store and have a taste of settings in Settings and have a sense what is it(I don't know why, but Xcode just created there. It is kind of (a word here is missing, you need to use your imagination to sense this word)).
3. the xcodeproj. You know what is it.
4. the Ultra, Simple Browser folder. It is the folder where every thing is. 
        First, Images.xcassets. Only contains icons. 
        Second, PNG Images. The images actually uses in app. 
        Third, the Core Data model. It is what it is. 
        Fourth, let's talk about swift files from the most important to the least important. 
            First, ViewController.swift. It is the heart of the App. It is about 1300 lines long(Horrible code design. I know). It mostly interacts with UI. It is the one and the only one linked to the storyboard, although there is nothing in the storyboard
            Second, let's say, toolBarItems.swift. It only configs the backButton and the forwardButton. I just to want to make the code shorter. BUT, it is the most basic feature in a browser: go back and go forward. 
            Third, URLTextField.swift. It is the URL text field. It acts as a host title bar when it is not the first responser. 
            Fourth, here we go, SuggestionViewController.swift(Although I think SuggestionViewController is more important, I put it at the fourth). It is a child view controller under ViewController. It give suggestions, such as the top 20 website that human beings visits, the favorites that user created,                   the websites that user visits over ten times, and histories user visited. 
            Fifth, BackForwardTableViewController.swift. The TableViewController that displays the backList and                      forwardList of the WKWebView, favorites and histories. 
            Sixth, AddNewFavoriteItemTableViewController.swift. The TableViewController that let user add new                        favorite item to Favorites
            Seventh, DemoViewController.swift. The ViewController just like it named(although every controller named                 by its functions). It guide user to use this browser at its first launch. 
            Eightth(Eighth?), 
    Fifth, the Tests. Never used it. It is not right for me. But it is not bothering me, so I let it be like that.
