//
//  MySerialDispatchQueueScheduler.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class MySerialDispatchQueueScheduler: MySchedulerType {
    public var now: Date {
        return Date()
    }
    
    let configuration: MyDispatchQueueConfiguration
    
    init(serialQueue: DispatchQueue, leeway: DispatchTimeInterval = .nanoseconds(0)) {
        self.configuration = MyDispatchQueueConfiguration(queue: serialQueue, leeway: leeway)
    }
    
    public convenience init(label: String, serialQueueConfiguration: ((DispatchQueue) -> Void)? = nil, leeway: DispatchTimeInterval = .nanoseconds(0)) {
        let queue = DispatchQueue(label: label, attributes: [])
        serialQueueConfiguration?(queue)
        self.init(serialQueue: queue, leeway: leeway)
    }
    
    public convenience init(queue: DispatchQueue, label: String, leeway: DispatchTimeInterval = .nanoseconds(0)) {
        let serialQueue = DispatchQueue(
            label: label,
            attributes: [],
            target: queue
        )
        self.init(serialQueue: serialQueue, leeway: leeway)
    }
    
    @available(iOS 8, OSX 10.10, *)
    public convenience init(qos: DispatchQoS, label: String = "rx.global_dispatch_queue.serial", leeway: DispatchTimeInterval = .nanoseconds(0)) {
        self.init(queue: DispatchQueue.global(qos: qos.qosClass), label: label, leeway: leeway)
    }
    
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        return configuration.schedule(state, action: action)
    }
    
    public func scheduleRelative<StateType>(_ state: StateType, dueTime: TimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        return configuration.scheduleRelative(state, dueTime: dueTime, action: action)
    }
    
    public func schedulePeriodic<StateType>(_ state: StateType, startAfter delayTime: TimeInterval, period: TimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        return configuration.schedulePeriodic(state, startAfter: delayTime, period: period, action: action)
    }
    
}
