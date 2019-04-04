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

MVC is great, but it's too easy to let your view controllers become behaviour dumps that know too much about their place in your application. Corduroy helps you tame your view controllers by moving all of their navigation logic to *coordinators* - objects smarter than your view controllers that handle translating app state for them and that know what to show when. This keeps your view controllers just that - controllers that layout, animate, and bind data to your views, making them more resuable and more defined.

But don't take my word for it - check out [some of these great articles](https://will.townsend.io/2016/an-ios-coordinator-pattern) all about the ['Coordinator' design pattern.](http://khanlou.com/2015/10/coordinators-redux/)

## The basics: All right, coordinators look cool. But what does Corduroy do?

The bread and butter of Corduroy are the `Navigator` (an object that handles navigation and precondition evaluation), the `Coordinator` (a navigation item that handles navigation logic for a view controller) and the `CoordinatorManageable` (your view controller). The biggest shift to starting with Corduroy is that the things you navigate to and from are not view controllers; instead, you navigate to and from *coordinators*. Navigation is done with a simple call to a `Navigator`, passing in the type of the next coordinator you want to navigate to and how you want to present it:

```swift
navigator.go(to: MyCoordinator.self, by: .modallyPresenting)
```

The navigator will then handle the creation of a new coordinator of the type you pass in and call a couple methods on the created coordinator. Coordinators are pretty simple objects themselves - there are a handlful of lifecycle methods to implement, then you're good to go. Here's a pretty simple example of what that coordinator can look like:

```swift
class MyCoordinator: Coordinator {
    var navigator: Navigator!
    
    // coordinators are created with a factory 'create(with:navigator:)' method. A default implementation is
    // provided that creates the coordinator and sets its 'navigator', but can be implemented yourself.

    // The coordinator's 'start' method is called when it is navigated to. It is passed a
    // 'navigation context' object, which has properties like the previous coordinator and the presentation
    // method, among other things.
    func start(with context: NavigationContext) {
        let myVC = MyViewController()
        myVC.coordinator = self
        self.present(myVC, asDescribedBy: context)
    }
    
    // Coordinators effectively act as navigation delegates to their view controllers - these methods would be
    // called by this coordinator's view controller.
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

Glad you asked, as that's one of the most powerful features of Corduroy. With how view controller initialization has been commandeered by UIKit (do I *really* have to implement `init?(coder:)`?), dependency injection for view controllers often turns into public variables you just have to know to set whenever you navigate to a given view controller. This gets especially nasty when you're working with initializing from storyboards. Corduroy solves dependencies by having `Coordinator`s declare a `SetupModel` [associated type](https://www.natashatherobot.com/swift-what-are-protocols-with-associated-types/). If a coordinator has a `SetupModel` declared, it's impossible to navigate to it with a navigator without supplying an object of that type in the navigator's `go(to:)` call.

Here's what a coordinator with dependencies could look like:

```swift
struct MyModel {
    let string: String
    let number: Int
}

class MyCoordinator: Coordinator {
    typealias SetupModel = MyModel

    // when we explicitly declare a SetupModel type, we need to provide the create method, where we'll be
    // passed in the model that the navigator was given to navigate to this coordinator.
    static func create(with model: MyModel, navigator: Navigator) -> MyCoordinator {
        let coordinator = MyCoordinator()
        coordinator.navigator = navigator
        // configure the coordinator with the model, set to a variable, etc
        return coordinator
    }
    
    // other 'Coordinator' methods
}

// now, this is how we navigate to `MyCoordinator` (and the compiler will enforce it!)
let model = MyModel(string: "abc", number: 123)
navigator.go(to: MyCoordinator.self, by: .modallyPresenting, with: model)
```

The idea is that anything your coordinator and/or its managed view need as a dependency should be in its `SetupModel` type. This could be a 'profile' object for a profile detail view controller, the 'song' object for a music player view controller - anything. This ensures that your coordinators always get what they need and become pretty self-documenting - useful especially when working with larger teams. However, there are often more optional 'configuration' properties we'd like to expose to consumers on our coordinators and their views. To faciliate this, a navigator's `go(to:)` method actually returns the created coordinator object if there's anything else you want to do with it.

## But wait, there's more: Flows

Another tool that Corduroy offers is 'flow coordinators'. Often in apps there exist series of view controllers that are meant to work together in a 'flow' - think login flows that span 2 or 3 view controllers, or signup flows, or onboarding flows. View controllers in these flows often have to share resources and models and know a lot about each other, which can make adding to or updating the flow involve a lot of refactoring. Flow coordinators (objects conforming to `FlowCoordinator`) are special coordinators that are meant to effectively 'black box' the flow to other views, managing all involved view controllers and their shared state.

Flows are often used to accomplish tasks or get a value from something. To facilitate this, `FlowCoordinator`s can be navigated to with 'flow completion' closures to report when the flow completes or is abandoned. This completion would likely be used to dismiss the flow coordinator or (like as would be expected in the case of a login flow) continue to a specific other coordinator. They can also declare a `FlowResult` associated type that is meant to be the flow's 'return' value (i.e. is passed into the flow completion closure). Here's what a flow coordinator could look like:

```swift
class MyFlowCoordinator: FlowCoordinator {
    typealias FlowResult = MyModel

    // instead of a 'start' method, flow coordinators have 'start' where,
    // along with a context, they can also be passed a 'completion' closure they're expected to call.
    func start(context: NavigationContext, flowCompletion: @escaping (Error?, FlowResult?) -> Void) {
        self.flowCompletion = flowCompletion //store the flow completion to call it later
        // present first view controller
    }
    
    func firstFlowVCDidFinish() {
        // present second view controller
    }
    
    func secondFlowVCDidFinish() {
        self.flowCompletion?()
    }
}
```
The flow coordinator is then navigated to in basically the same way, other than you can pass in a 'flow completion' closure:

```swift
navigator.go(to: MyFlowCoordinator.self, by: .modallyPresenting, flowCompletion: { error, model in
    if let model = model {
        // do stuff with the model
    }
    // probably navigate to another coordinator
})
```

## Preconditions

Corduroy also has support for preconditions to navigation between coordinators. These can be simple checks (user is logged in, user has completed onboarding, etc) or can move up in complexity to preconditions that, if not initially met, can attempt to recover with an asynchronous task or with the result of a flow coordinator. This can be used to easily create more complex conditions like 'the user must be logged in to navigate to this coordinator. If they aren't, start the login flow and navigate if it succeeds'. Preconditions are represented by simple objects that conform to one of either `NavigationPrecondition`, `RecoveringNavigationPrecondition`, or `FlowRecoveringNavigationPrecondition`.

A basic precondition conforming to `NavigationPrecondition` only needs to implement one method - `evaluate(context:)` - where it throws an error if it didn't pass. This error is ultimately propogated to the coordinator that started the navigation the precondition was a part of so it can handle it. Things get a little more interesting with recovering preconditions - if they throw in their `evaluate(context:)` method, then their `attemptRecovery(context:completion:)` method is called, where it can start an asynchronous task to attemp to recover so the navigation can continue. This could be something like making sure changes have been saved to a server before continuing, and could look something like this:

```swift
class DataSavedPrecondition: RecoveringNavigationPrecondition {
    func evaluate(context: NavigationContext) throws {
        if !dataAlreadySaved {
            throw DataNotSavedError()
        }
    }
    
    func attemptRecovery(context: NavigationContext, completion: @escaping (Bool) -> Void) {
        // start the network request to save the data, then:
        completion(dataSavedSuccessfully)
    }
}
```

Coordinators that require preconditions for navigation should conform to the `NavigationPreconditionRequiring` protocol, where they are required to list their preconditions as an array of preconditions types, like this:

```swift
class MyCoordinator: Coordinator, NavigationPreconditionRequiring {
    static let preconditions: [NavigationPrecondition.Type] = [
        DataSavedPrecondition.self,
        UserLoggedInPrecondition.self
    ]
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
