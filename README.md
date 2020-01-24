# UAWalkthrough

[![CI Status](http://img.shields.io/travis/marhas/UAWalkthrough.svg?style=flat)](https://travis-ci.org/marhas/UAWalkthrough)
[![Version](https://img.shields.io/cocoapods/v/UAWalkthrough.svg?style=flat)](http://cocoapods.org/pods/UAWalkthrough)
[![License](https://img.shields.io/cocoapods/l/UAWalkthrough.svg?style=flat)](http://cocoapods.org/pods/UAWalkthrough)
[![Platform](https://img.shields.io/cocoapods/p/UAWalkthrough.svg?style=flat)](http://cocoapods.org/pods/UAWalkthrough)

Quickly onboard users to your app by highlighting important UI elements and describe them using text bubbles. 
Highly customizable and super easy to implement in your own project.

## Features
- Supports "speech bubble" type dialogs that point at the UI element you want to explain and "standalone bubbles" that can be used e.g. to present some feature that doesn't have any specific UI element tied to it.
- Option to shade the background and highlight the element you want to talk about.
- Very customizable UI with two styles built in; white speech bubbles with shadow or blue speech bubbles without shadow.
- Option to have the onboarding tutorial automatically progress with a specified delay or require a tap on the background.
- Built-it functionality to show the onboarding only once per user with option to override.
- Use a delegate method to trigger custom actions on walkthrough completion.
- Very easy to implement in your app and unintrusive design.

## Preview

![Not pretty but gives you an idea](https://raw.githubusercontent.com/marhas/UAWalkthrough/master/UAWalkthrough_demo.gif)


## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

UAWalkthrough is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UAWalkthrough'
```

## Usage

All you need to do to create an onboarding experience in your app is to add an extension to your UIViewController where you describe the UIView's that you want to tell the user about, like this:
```swift
extension MyViewController: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        return [
            StandaloneItem(text: .plainText("This is a walkthrough of The App"),
            HighlightedItem(highlightedArea: actionButton1, textLocation: .below, content: .plainText("This button makes the app go BOOM.")),
            HighlightedItem(highlightedArea: slider, textLocation: .above, content: .plainText("Here's a slider for you.")),
            StandaloneItem(centerOffset: CGPoint(x: 0, y: -120), content: .plainText("That marks the end of the onboarding. Have fun!")),
        ]
    }
}
```

Then, insert this line where you want to start the onboarding:
```swift
startWalkthrough()
```

You can customize the appearance by passing in a ```WalkthroughSettings``` and style it by passing in a ```TextBubbleStyle```.
For more advanced examples, check out the example app!


## Author

Marcel Hasselaar, marcel@hasselaar.nu

## License

UAWalkthrough is available under the MIT license. See the LICENSE file for more info.
