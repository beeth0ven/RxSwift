//
//  MyQueue.swift
//  Rx
//
//  Created by luojie on 2017/10/21.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

struct MyQueue<T>: Sequence {
    typealias Iterator = AnyIterator<T>
    
    private let _resizeFactor = 2
    
    private var _storage: ContiguousArray<T?>
    private var _count = 0
    private var _pushNextIndex = 0
    private let _initailCapacity: Int
    
    init(capacity: Int) {
        _initailCapacity = capacity
        _storage = ContiguousArray(repeating: nil, count: capacity)
    }
    
    private var dequeueIndex: Int {
        let index = _pushNextIndex - count
        return index < 0 ? index + _storage.count : index
    }
    
    var isEmpty: Bool {
        return count == 0
    }
    
    var count: Int {
        return _count
    }
    
    func peek() -> T {
        precondition(count > 0)
        
        return _storage[dequeueIndex]!
    }
    
    mutating private func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
        
        let count = _count
        
        let dequequeIndex = self.dequeueIndex
        let spaceToEndOfQueue = _storage.count - dequeueIndex
        
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0..<countElementsInFirstBatch] = _storage[dequequeIndex..<(dequequeIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch..<(countElementsInFirstBatch + numberOfElementsInSecondBatch)] = _storage[0..<numberOfElementsInSecondBatch]
        
        _count = count
        _pushNextIndex = count
        _storage = newStorage
    }
    
    mutating func enqueue(_ element: T) {
        if count == _storage.count {
            resizeTo(Swift.max(_storage.count, 1) * _resizeFactor)
        }
        
        _storage[_pushNextIndex] = element
        _pushNextIndex += 1
        _count += 1
        
        if _pushNextIndex >= _storage.count {
            _pushNextIndex -= _storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)
        
        let index = dequeueIndex
        
        defer {
            _storage[index] = nil
            _count -= 1
        }
        
        return _storage[index]!
    }
    
    mutating func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        
        defer {
            let downsizeLimit = _storage.count / (_resizeFactor * _resizeFactor)
            if _count < downsizeLimit && downsizeLimit >= _initailCapacity {
                resizeTo(_storage.count / _resizeFactor)
            }
        }
        
        return dequeueElementOnly()
    }
    
    func makeIterator() -> AnyIterator<T> {
        var i = dequeueIndex
        var count = _count
        
        return AnyIterator {
            if count == 0 {
                return nil
            }
            
            defer {
                count -= 1
                i += 1
            }
            
            if i >= self._storage.count {
                i -= self._storage.count
            }
            
            return self._storage[i]
        }
    }
}
