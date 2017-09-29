//
//  MyBehaviorSubject.swift
//  Rx
//
//  Created by luojie on 2017/9/29.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

public final class MyBehaviorSubject<Element>: Observable<Element>
    , SubjectType
    , ObserverType
    , SynchronizedUnsubscribeType
    , Cancelable {
    
    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType
    public typealias SubjectObserverType = MyBehaviorSubject<Element>
    
    private var _isDisposed = false
    private var _element: Element
    private var _observers = Observers()
    private var _stopEvent: Event<Element>?
    
    let _lock = RecursiveLock()
    
    init(value: Element) {
        _element = value
    }
    
    public func value() throws -> Element {
        _lock.lock(); defer { _lock.unlock() }
        if _isDisposed {
            throw RxError.disposed(object: self)
        }
        
        if let error = _stopEvent?.error {
            throw error
        } else {
            return _element
        }
    }
    
    public var isDisposed: Bool {
        return _isDisposed
    }
    
    public func on(_ event: Event<Element>) {
        _lock.lock(); defer { _lock.unlock() }
        if _stopEvent != nil || _isDisposed {
            return
        }
        
        switch event {
        case .next(let element):
            _element = element
        case .error, .completed:
            _stopEvent = event
        }
        
        dispatch(_observers, event)
    }
    
    public func asObserver() -> MyBehaviorSubject<Element> {
        return self
    }
    
    public override func subscribe<O>(_ observer: O) -> Disposable where Element == O.E, O : ObserverType {
        _lock.lock(); defer { _lock.unlock() }
        
        if _isDisposed {
            observer.onError(RxError.disposed(object: self))
            return Disposables.create()
        }
        
        if let stopEvent = _stopEvent {
            observer.on(stopEvent)
            return Disposables.create()
        }
        
        let key = _observers.insert(observer.on)
        observer.onNext(_element)
        
        return SubscriptionDisposable(owner: self, key: key)
    }
    
    func synchronizedUnsubscribe(_ disposeKey: DisposeKey) {
        _lock.lock(); defer { _lock.unlock() }
        _ = _observers.removeKey(disposeKey)
    }
    
    public func dispose() {
        _lock.lock(); defer { _lock.unlock() }
        _isDisposed = true
        _observers.removeAll()
        _stopEvent = nil
    }
}
