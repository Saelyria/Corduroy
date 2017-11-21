# Corduroy

[![CI Status](http://img.shields.io/travis/Saelyria/Coordinator.svg?style=flat)](https://travis-ci.org/Saelyria/Coordinator)
[![Version](https://img.shields.io/cocoapods/v/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Coordinator)
[![License](https://img.shields.io/cocoapods/l/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Coordinator)
[![Platform](https://img.shields.io/cocoapods/p/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Coordinator)

Corduroy is a simple framework that adds coordinators to iOS's MVC paradigm. 

MVC is great, but it's too easy to let your view controllers become behaviour dumps that know too much about their place in your application. Corduroy helps you tame your view controllers by moving all of their navigation logic to *coordinators* - objects smarter than your view controllers that handle translating app state for them and that know what to show when. This keeps your view controllers just that - controllers that layout, animate, and bind data to your views, making them more resuable and more defined.

But don't take my word for it - check out [some of these great articles](https://will.townsend.io/2016/an-ios-coordinator-pattern) all about the ['Coordinator' design pattern.](http://khanlou.com/2015/10/coordinators-redux/)

## All right, coordinators are great. But what does Corduroy do?

At its core, Corduroy is a handful of protocols that help you define the relationships between your view controllers and your new coordinators and more easily communicate how they should set each other up. A big focus is put on cleaner dependency injection inspired by functional programming, namely through declaration of 'setup contexts' - an associated type that all coordinators and view controllers declare as the type of object that will contain all dependencies they need to be instantiated with.

But that's enough technical talk - let's see it in action!

The bread and butter is the `NavigationCoordinator` (your coordinator) and the `NavigationCoordinatorManageable` (your view controller). The main thing a `NavigationCoordinator` needs is a `start` method, where it's passed in a 'setup context' (of a type that it defines itself) and a view controller to start from. A `NavigationCoordinatorManageable` needs a static `create` factory method, where it's similarly passed in a 'setup context' of a type it defines and a coordinator (also of a type it defines). Here's a pretty simplified example of a coordinator that, based on a passed-in tuple, navigates to different view controllers:

```swift
class MyCoordinator: NavigationCoordinator {   
    typealias SetupContextType = (isSignedIn: Bool, username: String?)

    func start(with context: SetupContextType, from fromVC: UIViewController) {
        if context.isSignedIn, let username = context.username {
            let profileVC = ProfileViewController.create(with: username, coordinator: self)
            fromVC.present(profileVC, animated: true, completion: nil)
        } else {
            let signInVC = SignInViewController.create(with: EmptyContext(), coordinator: self)
            fromVC.present(signInVC, animated: true, completion: nil)
        }
    }
}
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

Coordinator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Coordinator'
```

## Author

Aaron Bosnjak (aaron.bosnjak707@gmail.com)

## License

Coordinator is available under the MIT license. See the LICENSE file for more info.
