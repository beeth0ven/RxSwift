//
//  MyBag.swift
//  Rx
//
//  Created by luojie on 2017/10/19.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Swift

let myArrayDictionaryMaxSize = 30

struct MyBagKey {
    fileprivate let rawValue: UInt64
}

struct MyBag<Value> {
    typealias Key = MyBagKey
    
    typealias Entry = (key: Key, value: Value)
    
    fileprivate var _nextKey: Key = Key(rawValue: 0)
    
    var _key0: Key? = nil
    var _value0: Value? = nil
    
    var _array = ContiguousArray<Entry>()
    
    var _dictionary: [Key: Value]? = nil
    
    var _onlyFastPath = true
    
    init() {}
    
    mutating func insert(_ value: Value) -> Key {
        let key = _nextKey
        
        _nextKey = Key(rawValue: _nextKey.rawValue &+ 1)
        
        if _key0 == nil {
            _key0 = key
            _value0 = value
            return key
        }
        
        _onlyFastPath = false
        
        if _dictionary != nil {
            _dictionary![key] = value
            return key
        }
        
        if _array.count < myArrayDictionaryMaxSize {
            _array.append(key: key, value: value)
            return key
        }
        
        _dictionary = [key: value] // Improved
        
        return key
    }
    
    var count: Int {
        let dictionaryCount: Int = _dictionary?.count ?? 0
        return (_value0 != nil ? 1 : 0) + _array.count + dictionaryCount
    }
    
    mutating func removeAll() {
        _key0 = nil
        _value0 = nil
        
        _array.removeAll(keepingCapacity: false)
        _dictionary?.removeAll(keepingCapacity: false)
    }
    
    mutating func removeKey(_ key: Key) -> Value? {
        if _key0 == key {
            _key0 = nil
            let value = _value0
            _value0 = nil
            return value
        }
        
        if let value = _dictionary?.removeValue(forKey: key){
            return value
        }
        
        for (index, entry) in _array.enumerated() {
            if entry.key == key {
                _array.remove(at: index)
                return entry.value
            }
        }
        
        return nil
    }
    
    func forEach(_ action: (Value) -> Void) {
        if _onlyFastPath {
            if let value = _value0 {
                action(value)
            }
            return
        }
        
        let value0 = _value0
        let dictionary = _dictionary
        
        if let value = value0 {
            action(value)
        }
        
        _array.forEach { action($0.value) }
        dictionary?.values.forEach(action)
    }
}


extension MyBagKey: Hashable {
    
    static func ==(lhs: MyBagKey, rhs: MyBagKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
    
    var hashValue: Int {
        return rawValue.hashValue
    }
}

