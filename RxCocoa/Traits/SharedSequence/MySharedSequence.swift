//
//  MySharedSequence.swift
//  Rx
//
//  Created by luojie on 2017/9/24.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public struct MySharedSequence<SharedSequenceStrategy: MySharedSequenceStrategyProtocol, Element>: MySharedSequenceConvertibleType {
    public typealias E = Element
    typealias S = SharedSequenceStrategy
    private let _source: Observable<E>
    
    init(_ source: Observable<E>) {
        _source = S.share(source)
    }
    
    public func asSharedSequence() -> MySharedSequence<SharedSequenceStrategy, E> {
        return self
    }
    
    public func asObservable() -> Observable<Element> {
        return _source
    }
}

public protocol MySharedSequenceConvertibleType: ObservableConvertibleType {
    associatedtype SharedSequenceStrategy: MySharedSequenceStrategyProtocol
    func asSharedSequence() -> MySharedSequence<SharedSequenceStrategy, E>
}

public protocol MySharedSequenceStrategyProtocol {
    static func scheduler() -> SchedulerType
    static func share<E>(_ source: Observable<E>) -> Observable<E>
}

