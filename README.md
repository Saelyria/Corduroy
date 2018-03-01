# Corduroy

[![Version](https://img.shields.io/cocoapods/v/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)
[![License](https://img.shields.io/cocoapods/l/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)
[![Platform](https://img.shields.io/cocoapods/p/Coordinator.svg?style=flat)](http://cocoapods.org/pods/Corduroy)

*Note that Corduroy is currently under active development, so docs and examples here may change as the API becomes more defined.*

Corduroy is a navigation framework for iOS with a rich feature set that makes navigation more dependable, more testable, and simply more powerful. This feature set includes:
- Graceful and type-safe handling of dependency injection between screens of your app
- Separation of view controllers from navigation logic to allow them greater reusability
- Scalable to fit the complexity of different parts of your application - Corduroy won't force you into complex, over-engineered solutions where it's not required
- Can be easily adapted to fit MVP or VIPER architectures
- Simple navigation preconditions that can run asynchronous tasks or launch intermediary view controllers before continuing navigation
- Navigation via URLs for better deep linking (under development!)
- 'App state' objects passed in during navigation for more testable, functional-style state management (coming soon!)
- RxSwift support (coming soon!)

MVC is great, but it's too easy to let your view controllers become behaviour dumps that know too much about their place in your application. Corduroy helps you tame your view controllers by moving all of their navigation logic to *coordinators* - objects smarter than your view controllers that handle translating app state for them and that know what to show when. This keeps your view controllers just that - controllers that layout, animate, and bind data to your views, making them more resuable and more defined.

But don't take my word for it - check out [some of these great articles](https://will.townsend.io/2016/an-ios-coordinator-pattern) all about the ['Coordinator' design pattern.](http://khanlou.com/2015/10/coordinators-redux/)

## The basics: All right, coordinators are great. But what does Corduroy do?

The bread and butter of Corduroy are the `Navigator` (an object that handles navigation and precondition evaluation), the `Coordinator` (a navigation item that handles navigation logic for a view controller) and the `CoordinatorManageable` (your view controller). The biggest shift to starting with Corduroy is that the things you navigate to and from are not view controllers; instead, you navigate to and from *coordinators* - I explain the reasons for this in the 'advantages' section. Navigation is done with a simple call to a `Navigator`, passing in the type of the next coordinator you want to navigate to:

```swift
navigator.go(to: MyCoordinator.self, by: .modallyPresenting)
```

The navigator will then handle the creation of a new coordinator of the type you pass in and call a couple methods on the created coordinator. Here's a pretty simple example of what that coordinator can look like:

```swift
class MyCoordinator: Coordinator {
    var currentViewController: UIViewController?
    var navigator: Navigator!

    // The coordinator's start method is called when it is navigated to. It is passed a 'navigation context' object,
    // which has properties like the previous coordinator and the presentation method, among other things.
    func start(with context: Navigator.NavigationContext) {
        let previousVC = context.fromCoordinator?.currentViewController
        let myVC = MyViewController()
        myVC.coordinator = self
        UIViewController.present(myVC, asDescribedBy: context)
        self.currentViewController = myVC
    }
    
    // Coordinators effectively act as navigation delegates to their view controllers - here, the profile VC knows that
    // its buttons navigate somewhere, but we let its coordinator decide where.
    func myVCDidPressButton() {
        self.navigator.go(to: MyOtherCoordinator.self, by: .modallyPresenting)
    }
    
    func myVCDidPressOtherButton() {
        self.navigator.go(to: MyOtherOtherCoordinator.self, by: .pushing)
    }
}
```

The view controller that `MyCoordinator` manages then simply needs to conform to `CoordinatorManageable`, where it declares a compatible coordinator type (or a protocol that a coordinator that wants to manage it needs to conform to) so they can talk to each other.

**"But"**, you say, **"that's an awful lot of bloat! I have to manage coordinators *and* view controllers now?"** Not if you think it'll overcomplicate a super simple view. There are a lot of advantages to splitting up your navigation logic and view logic, but if it's just a teeny little view that's pretty coupled to its navigation logic, you can also declare your view controller to be `SelfCoordinating` so Corduroy treats it like any other coordinator when it's basically just a plan old view controller.

## Passing data: That looks too simple. How do I pass stuff around to the views I'm navigating to?

Glad you asked, as that's one of the most powerful features of Corduroy. With how view controller initialization has been commandeered by UIKit (do I *really* have to implement `init?(coder:)`?), dependency injection for view controllers often turns into public variables you just have to know to set whenever you navigate to a given view controller. This gets especially nasty when you're working with initializing from storyboards. Corduroy solves dependencies by having `Coordinator`s declare a `SetupModel` [associated type](https://www.natashatherobot.com/swift-what-are-protocols-with-associated-types/). If a coordinator has a `SetupModel` declared, it's impossible to navigate to it with a navigator without supplying an object of that type in the `go(to:)` call.

Here's what a coordinator with dependencies could look like:

```swift
struct MyModel {
    let string: String
    let number: Int
}

class MyCoordinator: Coordinator {
    typealias SetupModel = MyModel

    // when we explicitly declare a SetupModel type, we need to provide a create method, where we'll be passed in the model that
    // the navigator was given to navigate to this coordinator.
    static func create(with model: SetupModel, navigator: Navigator) -> MyCoordinator {
        let coordinator = MyCoordinator()
        // configure the coordinator with the model, set to a variable, etc
        return coordinator
    }
}

// now, this is how we navigate to `MyCoordinator` (and the compiler will enforce it!)
let model = MyModel(string: "abc", number: 123)
navigator.go(to: MyCoordinator.self, by: .modallyPresenting, with: model)
```

The idea is that anything your coordinator and/or its managed view need should be in its `SetupModel` type. This ensures that your coordinators always get what they need and become pretty self-documenting - useful especially when working with larger teams. However, there are often more optional 'configuration' properties we'd like to expose to consumers on our coordinators and their views. To faciliate this, a navigator's `go(to:)` method actually returns the created coordinator object if there's anything else you want to do with it.

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
