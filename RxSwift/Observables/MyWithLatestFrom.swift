//
//  MyWithLatestFrom.swift
//  Rx
//
//  Created by luojie on 2017/9/5.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    
    
    public func myWithLatestFrom<SecondO: ObservableConvertibleType, ResultType>(_ second: SecondO, resultSelector: @escaping (E, SecondO.E) throws -> ResultType) -> Observable<ResultType> {
        return MyWithLatestFrom(first: self.asObservable(), second: second.asObservable(), resultSelector: resultSelector)
    }
    
    public func myWithLatestFrom<SecondO: ObservableConvertibleType>(_ second: SecondO) -> Observable<SecondO.E> {
        return MyWithLatestFrom(first: self.asObservable(), second: second.asObservable(), resultSelector: { $1 })
    }
}

final fileprivate class MyWithLatestFromSink<FirstType, SecondType, O: ObserverType>
    : Sink<O>
    , ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    typealias ResultType = O.E
    typealias Parent = MyWithLatestFrom<FirstType, SecondType, ResultType>
    typealias E = FirstType

    fileprivate let _parent: Parent
    
    var _lock = RecursiveLock()
    fileprivate var _latest: SecondType?
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let sndSubscription = SingleAssignmentDisposable()
        let sndO = MyWithLatestFromSecond(parent: self, disposable: sndSubscription)
        
        sndSubscription.setDisposable(_parent._second.subscribe(sndO))
        let fstSubscription = _parent._first.subscribe(self)
        
        return Disposables.create(fstSubscription, sndSubscription)
    }
    
    func on(_ event: Event<FirstType>) {
        synchronizedOn(event)
    }
    
    func _synchronized_on(_ event: Event<FirstType>) {
        switch event {
        case .next(let value):
            guard let latest = _latest else { return }
            do {
                let res = try _parent._resultSelector(value, latest)
                forwardOn(.next(res))
            } catch let e {
                forwardOn(.error(e))
                dispose()
            }
        case .completed:
            forwardOn(.completed)
            dispose()
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        }
    }
}

final fileprivate class MyWithLatestFromSecond<FirstType, SecondType, O: ObserverType>
    : ObserverType
    , LockOwnerType
    , SynchronizedOnType {
    
    typealias ResultType = O.E
    typealias Parent = MyWithLatestFromSink<FirstType, SecondType, O>
    typealias E = SecondType
 
    private let _parent: Parent
    private let _disposable: Disposable
    
    var _lock: RecursiveLock {
        return _parent._lock
    }
    
    init(parent: Parent, disposable: Disposable) {
        _parent = parent
        _disposable = disposable
    }
    
    func on(_ event: Event<SecondType>) {
        synchronizedOn(event)
    }
    
    func _synchronized_on(_ event: Event<SecondType>) {
        switch event {
        case let .next(value):
            _parent._latest = value
        case .completed:
            _disposable.dispose()
        case let .error(error):
            _parent.forwardOn(.error(error))
            _parent.dispose()
        }
    }
}

final fileprivate class MyWithLatestFrom<FirstType, SecondType, ResultType>: Producer<ResultType> {
    typealias ResultSelector = (FirstType, SecondType) throws -> ResultType
    
    fileprivate let _first: Observable<FirstType>
    fileprivate let _second: Observable<SecondType>
    fileprivate let _resultSelector: ResultSelector
    
    init(first: Observable<FirstType>, second: Observable<SecondType>, resultSelector: @escaping ResultSelector) {
        _first = first
        _second = second
        _resultSelector = resultSelector
    }
    
    override func run<O>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O : ObserverType, O.E == ResultType {
        let sink = MyWithLatestFromSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
    
}





