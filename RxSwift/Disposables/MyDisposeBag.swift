//
//  MyDisposeBag.swift
//  Rx
//
//  Created by luojie on 2017/10/24.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

public final class MyDisposeBag: DisposeBase {
    
    private var _lock = SpinLock()
    
    private var _disposables = [Disposable]()
    private var _isDisposed = false
    
    public func insert(_ disposable: Disposable) {
        _insert(disposable)?.dispose()
    }
    
    private func _insert(_ disposable: Disposable) -> Disposable? {
        _lock.lock(); defer { _lock.unlock() }
        if _isDisposed {
            return disposable
        }
        _disposables.append(disposable)
        return nil
    }
    
    private func dispose() {
        disposables().forEach { $0.dispose() }
    }
    
    private func disposables() -> [Disposable] {
        _lock.lock(); defer { _lock.unlock() }
        let disposables = _disposables
        _disposables.removeAll(keepingCapacity: false)
        _isDisposed = true
        return disposables
    }
    
    deinit {
        dispose()
    }
}
