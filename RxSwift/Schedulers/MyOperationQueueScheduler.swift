//
//  MyOperationQueueScheduler.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct MyOperationQueueScheduler {
    public let operationQueue: OperationQueue
    
    init(operationQueue: OperationQueue) {
        self.operationQueue = operationQueue
    }
}

extension MyOperationQueueScheduler: MyImmediateSchedulerType {
    
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        operationQueue.addOperation {
            guard !cancel.isDisposed else { return }
            cancel.setDisposable(action(state))
        }
        return cancel
    }
}
