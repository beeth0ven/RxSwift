//
//  MyPrimitiveSequence.swift
//  Rx
//
//  Created by luojie on 2017/9/25.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public struct MyPrimitiveSequence<Trait, Element> {
    fileprivate let source: Observable<Element>
    init(_ source: Observable<Element>) {
        self.source = source
    }
}

extension MyPrimitiveSequence: MyPrimitiveSequenceProtocol {
    public typealias TraitType = Trait
    public typealias ElementType = Element
    
    public var primitiveSequence: MyPrimitiveSequence<Trait, Element> {
        return self
    }
}

public protocol MyPrimitiveSequenceProtocol {
    associatedtype TraitType
    associatedtype ElementType
    var primitiveSequence: MyPrimitiveSequence<TraitType, ElementType> { get }
}

extension MyPrimitiveSequence: ObservableConvertibleType {
    
    public func asObservable() -> Observable<Element> {
        return source
    }
}


public enum MySingleTrait {}
public typealias MySingle<Element> = MyPrimitiveSequence<MySingleTrait, Element>


public enum MyMaybeTrait {}
public typealias MyMaybe<Element> = MyPrimitiveSequence<MyMaybeTrait, Element>


public enum MyCompletableTrait {}
public typealias MyCompletable = MyPrimitiveSequence<MyCompletableTrait, Swift.Never>


///


extension MyPrimitiveSequence {
    
}

extension MyPrimitiveSequence where Trait == MySingleTrait {
    
}

extension MyPrimitiveSequence where Trait == MyMaybeTrait {
    
}

extension MyPrimitiveSequence where Trait == MyCompletableTrait, Element == Swift.Never {
    
}


