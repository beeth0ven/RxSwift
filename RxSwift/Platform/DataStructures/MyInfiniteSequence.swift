//
//  MyInfiniteSequence.swift
//  Rx
//
//  Created by luojie on 2017/10/19.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

struct MyInfiniteSequence<E>: Sequence {
    typealias Element = E
    typealias Iterator = AnyIterator<E>
    
    private let _repeatedValue: E
    
    init(repeatedValue: E) {
        _repeatedValue = repeatedValue
    }
    
    func makeIterator() -> AnyIterator<E> {
        let repeatedValue = _repeatedValue
        return AnyIterator {
            return repeatedValue
        }
    }
}
