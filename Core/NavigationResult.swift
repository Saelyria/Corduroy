import UIKit

/**
 An object returned from navigator `go(to:)` methods that allows the object that started the navigation to subscribe to
 various events related to the navigation.
 
 Note: do not hold reference to this object - simply call its various methods for adding callbacks.
 */
public class NavigationResult<C: BaseCoordinator> {
    private var onFail: ((Error) -> Void)?
    private var onRecoveringPreconditionStarted: (() -> Void)?
    private var onFlowRecoveryStarted: (() -> Void)?
    private var onCoordinatorCreated: ((C) -> Void)?
    
    // A closure that this result should call when it deinits (goes out of scope); used to indicate to the navigator
    // that all callbacks are set that will be set.
    private var completionHandler: () -> Void
    
    // Internal variables set by the navigator that indicate when a condition has passed that warrants one of the
    // appropriate handlers be called.
    internal var preconditonError: Error? {
        didSet {
            if let error = preconditonError, let onFail = self.onFail {
                onFail(error)
                self.onFail = nil
            }
        }
    }
    
    internal var recoveringPreconditionsHaveStarted: Bool = false {
        didSet {
            if recoveringPreconditionsHaveStarted, let preconditionsStarted = self.onRecoveringPreconditionStarted {
                preconditionsStarted()
                self.onRecoveringPreconditionStarted = nil
            }
        }
    }
    
    internal var flowRecoveryHasStarted: Bool = false {
        didSet {
            if flowRecoveryHasStarted, let flowStarted = self.onFlowRecoveryStarted {
                flowStarted()
                self.onFlowRecoveryStarted = nil
            }
        }
    }
    
    internal var coordinator: C? {
        didSet {
            if let coordinator = coordinator, let onCoordinatorCreated = self.onCoordinatorCreated {
                onCoordinatorCreated(coordinator)
                self.onCoordinatorCreated = nil
            }
        }
    }
    
    // Navigation results are created with a closure to call after they have been deallocated. The idea is to capture
    // when they go out of scope to know when all event bindings have been set so the navigator can go through with the
    // final 'present view controller' part of its navigation. This ensures that events (especially the 'on coordinator
    // created' event) are guaranteed to be called before the final presentation of the view controller occurs.
    internal init(completionHandler: @escaping () -> Void) {
        self.completionHandler = completionHandler
    }
    
    deinit {
        self.completionHandler()
    }
    
    /**
     Adds a handler to the navigation that is called when the coordinator being navigated to is created.
     
     In most cases this will be called immediately; however, in the case of a coordinator that has recovering
     preconditions, the handler is called after all preconditions have passed or been recovered. The handler is not
     called if any preconditions fail and were not recoverable. This handler is guaranteed to be called before the
     created coordinator's `presentViewController` or `presentFirstViewController` methods, so additional configuration
     of the coordinator can be done in this handler.
     - parameter onCreated: The handler that will be called with the created coordinator.
     */
    @discardableResult
    public func onCoordinatorCreated(_ onCreated: @escaping (C) -> Void) -> NavigationResult<C> {
        if let coordinator = self.coordinator {
            onCreated(coordinator)
        } else {
            self.onCoordinatorCreated = onCreated
        }
        return self
    }
    
    /**
     Adds a handler to the navigation that is called when a precondition fails and navigation cannot continue.
     
     The passed in handler is called when a precondition fails and was not recoverable. The error from the failed
     precondition is passed into this handler.
     - parameter onFail: The handler that will be called when a precondition fails.
     */
    @discardableResult
    public func onPreconditionFailed(_ onFail: @escaping (Error) -> Void) -> NavigationResult<C> {
        if let error = self.preconditonError {
            onFail(error)
        } else {
            self.onFail = onFail
        }
        return self
    }
    
    /**
     Adds a handler to the navigation that is called when an asynchronous task has started to attempt recovery for a
     failed precondition.
     
     This method is only called when an asynchronous recovery task is started, not for a flow recovering precondition
     when it has started a flow. This handler can be used to indicate to the user that an asynchronous task has started,
     such as displaying a loading indicator.
     - parameter onStarted: The handler that will be called when precondition recovery starts.
     */
    @discardableResult
    public func onPreconditionRecoveryStarted(_ onStarted: @escaping () -> Void) -> NavigationResult<C> {
        if self.recoveringPreconditionsHaveStarted {
            onStarted()
        } else {
            self.onRecoveringPreconditionStarted = onStarted
        }
        return self
    }
    
    /**
     Adds a handler to the navigation that is called when an an auxilliary flow coordinator was navigated to attempt
     recovery for a failed precondition.
     */
    @discardableResult
    public func onPreconditionFlowStarted(_ onStarted: @escaping () -> Void) -> NavigationResult<C> {
        if self.flowRecoveryHasStarted {
            onStarted()
        } else {
            self.onFlowRecoveryStarted = onStarted
        }
        return self
    }
}
