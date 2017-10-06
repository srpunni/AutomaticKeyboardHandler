- **Library name**: AutomaticKeyboardHandler (iOS/Swift).                                                        

- **Description**: This library is used to handle keyboard and cursor movement automatically without writing a single line of the code. 

- **Installation**: You can integrate this library in your project using Cocoa Pods or directly by importing the files. 

 1.  Cocoa Pods :  ***pod 'AutomaticKeyboardHandler'***
 2. Direct : Download project from github and copy doneToolbar.xib and KAScrollView.swift in your project.
 
- **Usage**: It is very simple. You just need to assign KAScrollView class to your ScrollView in storyboard.  If you want to change space between keyboard and current first responder text field then use below code :
      1.  Import AutomaticKeyboardHandler
      2.    kaScrollView.topPadding =  100 (It can be anything from negative to positive values)
  
- **License**: AutomaticKeyboardHandler is available under the MIT license.
