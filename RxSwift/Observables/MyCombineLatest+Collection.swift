//
//  MyCombineLatest+Collection.swift
//  Rx
//
//  Created by luojie on 2017/9/8.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

extension Observable {
    
    public static func myCombineLatest<O: ObservableType>(_ collection: O..., _ resultSelector: @escaping ([O.E]) throws -> Element) -> Observable<Element> {
            return MyCombineLatestCollectionType(sources: collection, resultSelector: resultSelector)
    }
    
    public static func myCombineLatest<O: ObservableType>(_ collection: O ...) -> Observable<[Element]>
        where O.E == Element {
            return MyCombineLatestCollectionType(sources: collection, resultSelector: { $0 })
    }
    
    public static func myCombineLatest<C: Collection>(_ collection: C, _ resultSelector: @escaping ([C.Iterator.Element.E]) throws -> Element) -> Observable<Element>
        where C.Iterator.Element: ObservableType {
        return MyCombineLatestCollectionType(sources: collection, resultSelector: resultSelector)
    }
    
    public static func myCombineLatest<C: Collection>(_ collection: C) -> Observable<[Element]>
        where C.Iterator.Element: ObservableType, C.Iterator.Element.E == Element {
            return MyCombineLatestCollectionType(sources: collection, resultSelector: { $0 })
    }

}

final fileprivate class MyCombineLatestCollectionTypeSink<C: Collection, O: ObserverType>
    : Sink<O> where C.Iterator.Element: ObservableConvertibleType {
    typealias R = O.E
    typealias Parent = MyCombineLatestCollectionType<C, R>
    typealias SourceElement = C.Iterator.Element.E
    
    let _parent: Parent
    
    let _lock = RecursiveLock()
    
    // state
    var _numberOfValues = 0
    var _values: [SourceElement?]
    var _isDone: [Bool]
    var _numberOfDone = 0
    var _subcriptions: [SingleAssignmentDisposable]
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        _values = [SourceElement?](repeatElement(nil, count: parent._count))
        _isDone = [Bool](repeatElement(false, count: parent._count))
        _subcriptions = Array<SingleAssignmentDisposable>()
        _subcriptions.reserveCapacity(parent._count)
        
        for _ in 0 ..< parent._count {
            _subcriptions.append(SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<SourceElement>, at index: Int) {
        _lock.lock(); defer { _lock.unlock() }
        switch event {
        case .next(let element):
            if _values[index] == nil {
                _numberOfValues += 1
            }
            
            _values[index] = element
            
            if _numberOfValues < _parent._count {
                let numberOfOthersThatAreDone = self._numberOfValues - (_isDone[index] ? 1 : 0)
                if numberOfOthersThatAreDone == self._parent._count - 1 {
                    forwardOn(.completed)
                    dispose()
                }
                return
            }
            
            do {
                let res = try _parent._resultSelector(_values.map { $0! })
                forwardOn(.next(res))
            } catch let error {
                forwardOn(.error(error))
                dispose()
            }
            
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            if _isDone[index] {
                return
            }
            
            _isDone[index] = true
            _numberOfDone += 1
            
            if _numberOfDone == _parent._count {
                forwardOn(.completed)
                dispose()
            } else {
                _subcriptions[index].dispose()
            }
        }
        
    }
    
    func run() -> Disposable {
        var j = 0
        for i in _parent._sources {
            let index = j
            let source = i.asObservable()
            let disposable = source.subscribe(AnyObserver { event in
                self.on(event, at: index)
            })
            
            _subcriptions[index].setDisposable(disposable)
            
            j += 1
        }
        
        if _parent._sources.isEmpty {
            forwardOn(.completed)
            dispose()
        }
        
        return Disposables.create(_subcriptions)
    }
}

final fileprivate class MyCombineLatestCollectionType<C: Collection, R>: Producer<R> where C.Iterator.Element: ObservableConvertibleType {
    typealias ResultSelector = ([C.Iterator.Element.E]) throws -> R
    
    let _sources: C
    let _resultSelector: ResultSelector
    let _count: Int
    
    init(sources: C, resultSelector: @escaping ResultSelector) {
        _sources = sources
        _resultSelector = resultSelector
        _count = Int(self._sources.count.toIntMax())
    }
    
    override func run<O>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O : ObserverType, O.E == R {
        let sink = MyCombineLatestCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
