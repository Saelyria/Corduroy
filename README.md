# Corduroy

[![Version](https://img.shields.io/cocoapods/v/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)
[![License](https://img.shields.io/cocoapods/l/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)
[![Platform](https://img.shields.io/cocoapods/p/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)

*Note that Corduroy is currently under active development, so docs and examples here may change as the API becomes more defined.*

Corduroy is a navigation framework for iOS with a rich feature set that makes navigation more dependable, testable, and simply more powerful. This feature set includes:
- Graceful and type-safe handling of dependency injection between screens of your app
- Separation of view controllers from navigation logic to allow them greater reusability
- Simple navigation preconditions that can run asynchronous tasks or launch intermediary view controllers before continuing on a route
- 'App state' objects passed in during navigation for more testable, functional-style state management (coming soon!)
- Navigation via URLs for better deep linking (coming soon!)
- RxSwift support (coming soon!)

MVC is great, but it's too easy to let your view controllers become behaviour dumps that know too much about their place in your application. Corduroy helps you tame your view controllers by moving all of their navigation logic to *coordinators* - objects smarter than your view controllers that handle translating app state for them and that know what to show when. This keeps your view controllers just that - controllers that layout, animate, and bind data to your views, making them more resuable and more defined.

But don't take my word for it - check out [some of these great articles](https://will.townsend.io/2016/an-ios-coordinator-pattern) all about the ['Coordinator' design pattern.](http://khanlou.com/2015/10/coordinators-redux/)

## All right, coordinators are great. But how does Corduroy work?

The bread and butter of Corduroy are the `Navigator` (an object that handles navigation and precondition evaluation), the `Coordinator` (a navigation item that handles navigation logic for a view controller) and the `CoordinatorManageable` (your view controller). Here's a pretty simple example of a coordinator:

```swift
class MyCoordinator: Coordinator {
    var currentViewController: UIViewController?
    var navigator: Navigator!

    // The coordinator's start method is called when it is navigated to. It is passed a 'navigation context' object,
    // which has properties like the previous coordinator and the presentation method, among other things.
    func start(with context: Navigator.NavigationContext) {
        let previousVC = context.fromCoordinator?.currentViewController
        let profileVC = ProfileViewController()
        profileVC.coordinator = self
        previousVC?.present(profileVC, animated: true, completion: nil)
        self.currentViewController = profileVC
    }
    
    // Coordinators effectively act as navigation delegates to their view controllers - here, the profile VC knows that
    // its continue button navigates somewhere, but we let the coordinator decide where.
    func profileVCDidPressContinue() {
        // To navigate, we just tell the navigator which coordinator type to go to and by what method.
        self.navigator.go(to: MyOtherCoordinator.self, by: .modallyPresenting)
    }
}
```

The files of Corduroy are also well-documented and this repo includes an example application with step-by-step comments explaining what's going on.

## Installation

Corduroy (will be) available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Corduroy'
```

## Author

Aaron Bosnjak (aaron.bosnjak707@gmail.com)

## License

Coordinator is available under the MIT license. See the LICENSE file for more info.
