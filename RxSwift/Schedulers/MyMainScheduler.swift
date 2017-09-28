//
//  MyMainScheduler.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Dispatch

public final class MyMainScheduler: MySerialDispatchQueueScheduler {
    
    private let _mainQueue: DispatchQueue
    
    var numberEnqueued: AtomicInt = 0

    public init() {
        _mainQueue = DispatchQueue.main
        super.init(serialQueue: _mainQueue)
    }
    
    public let instance = MainScheduler()
    
    public static let asyncInstance = MySerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)
    
    override public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let currentNumberQnqueued = AtomicIncrement(&numberEnqueued)
        
        if DispatchQueue.isMain && currentNumberQnqueued == 1 {
            let disposable = action(state)
            _ = AtomicDecrement(&numberEnqueued)
            return action(state)
        }
        
        let cancel = SingleAssignmentDisposable()
        
        _mainQueue.async {
            defer { _ = AtomicDecrement(&self.numberEnqueued) }
            guard !cancel.isDisposed else { return }
            cancel.setDisposable(action(state))
        }
        
        return cancel
    }
    
}


