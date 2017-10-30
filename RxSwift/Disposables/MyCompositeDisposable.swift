//
//  MyCompositeDisposable.swift
//  Rx
//
//  Created by luojie on 2017/10/25.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation

public final class MyCompositeDisposable: DisposeBase, Cancelable {
    
    public struct DisposeKey {
        fileprivate let key: BagKey
        fileprivate init(key: BagKey) {
            self.key = key
        }
    }
    
    private var _lock = SpinLock()
    
    private var _disposables: Bag<Disposable>? = .init()
    
    public func insert(_ disposable: Disposable) -> DisposeKey? {
        let key = _insert(for: disposable)
        
        if key == nil {
            disposable.dispose()
        }
        
        return key
    }
    
    private func _insert(for disposable: Disposable) -> DisposeKey? {
        _lock.lock(); defer { _lock.unlock() }
        let bagKey = _disposables?.insert(disposable)
        return bagKey.map(DisposeKey.init)
    }
    
    public func remove(for disposeKey: DisposeKey) {
        _reomove(for: disposeKey)?.dispose()
    }
    
    private func _reomove(for disposeKey: DisposeKey) -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables?.removeKey(disposeKey.key)
    }
    
    public var isDisposed: Bool {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables == nil
    }
    
    public var count: Int {
        _lock.lock(); defer { _lock.unlock() }
        return _disposables?.count ?? 0
    }
    
    public func dispose() {
        if let disposables = _dispose() {
            disposeAll(in: disposables)
        }
    }
    
    private func _dispose() -> Bag<Disposable>? {
        _lock.lock(); defer { _lock.unlock() }
        
        let disposables = _disposables
        _disposables = nil
        return disposables
    }
}
