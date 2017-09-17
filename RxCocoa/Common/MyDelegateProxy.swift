//
//  MyDelegateProxy.swift
//  Rx
//
//  Created by luojie on 2017/9/15.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

let delegateAssociatedKey: UnsafeRawPointer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))
let dataSourceAssociatedKey: UnsafeRawPointer = UnsafeRawPointer(UnsafeMutablePointer<UInt8>.allocate(capacity: 1))

open class MyDelegateProxy: _RXDelegateProxy {
    
    private var sentMessageSubjects = [Selector: PublishSubject<[Any]>]()
    private var methodInvokedSubjects = [Selector: PublishSubject<[Any]>]()
    
    weak private(set) var parentObject: AnyObject?
    
    public required init(parentObject: AnyObject) {
        self.parentObject = parentObject
        
        MainScheduler.ensureExecutingOnScheduler()
        
        super.init()
    }
    
    open func sentMessage(_ selector: Selector) -> Observable<[Any]> {
        MainScheduler.ensureExecutingOnScheduler()
        
        checkSelectorIsObservable(selector)
        
        if let subject = sentMessageSubjects[selector] {
            return subject.asObservable()
        } else {
            let subject = PublishSubject<[Any]>()
            sentMessageSubjects[selector] = subject
            return subject.asObservable()
        }
    }
    
    open func methodInvoked(_ selector: Selector) -> Observable<[Any]> {
        MainScheduler.ensureExecutingOnScheduler()
        
        checkSelectorIsObservable(selector)
        
        if let subject = methodInvokedSubjects[selector] {
            return subject.asObservable()
        } else {
            let subject = PublishSubject<[Any]>()
            methodInvokedSubjects[selector] = subject
            return subject.asObservable()
        }
    }
    
    private func checkSelectorIsObservable(_ selector: Selector) {
        MainScheduler.ensureExecutingOnScheduler()
        
        if hasWiredImplementation(for: selector) {
            print("Delegate proxy is already implementing `\(selector)`, a more performant way of registering might exist.")
            return
        }
        
        guard (self.getForwardDelegate()?.responds(to: selector) ?? false) || voidDelegateMethodsContain(selector) else { //  First condition is hard to understand
            fatalError("This class doesn't respond to selector \(selector)")
        }
    }
    
    open override func _sentMessage(_ selector: Selector, withArguments arguments: [Any]) {
        sentMessageSubjects[selector]?.onNext(arguments)
    }
    
    open override func _methodInvoked(_ selector: Selector, withArguments arguments: [Any]) {
        methodInvokedSubjects[selector]?.onNext(arguments)
    }
    
    open class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        return self.init(parentObject: object)
    }

    open class func getProxyFor(_ object: AnyObject) -> AnyObject? {
        return objc_getAssociatedObject(object, delegateAssociatedKey) as AnyObject?
    }
    
    open class func setProxy(_ proxy: AnyObject, to object: AnyObject) {
        precondition(proxy.isKind(of: self.classForCoder()))
        objc_setAssociatedObject(object, delegateAssociatedKey, proxy, .OBJC_ASSOCIATION_RETAIN)
    }
    
    open func setForwardDelegate(_ delegate: AnyObject?, retainDelegate: Bool) {
        MainScheduler.ensureExecutingOnScheduler()
        self._setForward(toDelegate: delegate, retainDelegate: retainDelegate)
        self.reset()
    }
    
    open func getForwardDelegate() -> AnyObject? {
        return _forwardToDelegate
    }
    
    private func hasObservers(selector: Selector) -> Bool {
        return (sentMessageSubjects[selector]?.hasObservers ?? false)
        || (methodInvokedSubjects[selector]?.hasObservers ?? false)
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        return super.responds(to: aSelector)
        || (self._forwardToDelegate?.responds(to: aSelector) ?? false)
        || (self.voidDelegateMethodsContain(aSelector) && self.hasObservers(selector: aSelector))
    }
    
    func reset() {
        guard let delegateProxySelf = self as? IsDelegateProxy else {
            rxFatalErrorInDebug("\(self) doesn't implement delegate proxy type.")
            return
        }
        
        guard let parentObject = self.parentObject else { return }
        
        let selfType = type(of: delegateProxySelf)
        
        let maybeDelegate = selfType.getDelegateFor(parentObject)
        
        if maybeDelegate === self {
            selfType.setDelegate(nil, to: parentObject)
            selfType.setDelegate(self, to: parentObject)
        }
    }
    
    deinit {
        sentMessageSubjects.values.forEach { $0.onCompleted() }
        methodInvokedSubjects.values.forEach { $0.onCompleted() }
    }
}
