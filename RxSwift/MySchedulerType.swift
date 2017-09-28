//
//  MySchedulerType.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol MySchedulerType: MyImmediateSchedulerType {
    var now: Date { get }
    
    func scheduleRelative<StateType>(_ state: StateType, dueTime: TimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable
    
    func schedulePeriodic<StateType>(_ state: StateType, startAfter delayTime: TimeInterval, period: TimeInterval, action: @escaping (StateType) -> StateType) -> Disposable
    
}


