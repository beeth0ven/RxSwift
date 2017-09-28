//
//  MyPublishSubject.swift
//  Rx
//
//  Created by luojie on 2017/9/28.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

public final class MyPublishSubject<Element>
    : Observable<Element>
    , SubjectType
    , ObserverType
    , Cancelable
    , SynchronizedUnsubscribeType {
    
    public typealias SubjectObserverType = MyPublishSubject<Element>
    
    typealias Observers = AnyObserver<Element>.s
    typealias DisposeKey = Observers.KeyType
    
    public var hasObservers: Bool {
        _lock.lock(); defer { _lock.unlock() }
        return _observers.count > 0
    }
    
    private let _lock = RecursiveLock()
    
    // state
    
    private var _isDisposed = false
    private var _observers = Observers()
    private var _stopped = false
    private var _stoppedEvent: Event<Element>? = nil

    public var isDisposed: Bool {
        return _isDisposed
    }
    
    public func on(_ event: Event<Element>) {
        _lock.lock(); defer { _lock.unlock() }
        if isDisposed || _stopped { return }
        if event.isStopEvent {
            _stoppedEvent = event
            _stopped = true
        }
        dispatch(_observers, event)
    }
    
    public func asObserver() -> MyPublishSubject<Element> {
        return self
    }
    
    public override func subscribe<O>(_ observer: O) -> Disposable where Element == O.E, O : ObserverType {
        _lock.lock(); defer { _lock.unlock() }
        if let stopEvent = _stoppedEvent {
            observer.on(stopEvent)
            return Disposables.create()
        }
        
        if isDisposed {
            observer.onError(RxError.disposed(object: self))
            return Disposables.create()
        }
        
        let key = _observers.insert(observer.on)
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
        _stoppedEvent = nil
    }
    
}

