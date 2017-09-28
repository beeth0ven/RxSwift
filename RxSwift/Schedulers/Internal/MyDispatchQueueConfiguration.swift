//
//  MyDispatchQueueConfiguration.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import Foundation

struct MyDispatchQueueConfiguration {
    let queue: DispatchQueue
    let leeway: DispatchTimeInterval
}

private func dispatchTime(_ timeInterval: TimeInterval) -> DispatchTimeInterval {
    return DispatchTimeInterval.microseconds(Int(timeInterval * 1000))
}

extension MyDispatchQueueConfiguration {
    
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        queue.async {
            guard !cancel.isDisposed else { return }
            cancel.setDisposable(action(state))
        }
        return cancel
    }
    
    func scheduleRelative<StateType>(_ state: StateType, dueTime: TimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        let cancel = SerialDisposable()
        var timer: DispatchSourceTimer? = DispatchSource.makeTimerSource(queue: queue)
        timer!.scheduleOneshot(deadline: .now() + dispatchTime(dueTime))
        
        cancel.disposable = Disposables.create {
            timer?.cancel()
            timer = nil
        }
        
        timer!.setEventHandler {
            guard !cancel.isDisposed else { return }
            cancel.disposable = action(state)
        }
        timer?.resume()
        
        
        return cancel
    }
    
    func schedulePeriodic<StateType>(_ state: StateType, startAfter delayTime: TimeInterval, period: TimeInterval, action: @escaping (StateType) -> StateType) -> Disposable {
        var timerState = state
        var timer: DispatchSourceTimer? = DispatchSource.makeTimerSource(queue: queue)
        timer?.scheduleRepeating(deadline: .now() + dispatchTime(delayTime), interval: dispatchTime(period))
        let cancel = Disposables.create {
            timer?.cancel()
            timer = nil
        }
        
        timer?.setEventHandler {
            guard !cancel.isDisposed else { return }
            timerState = action(timerState)
        }
        timer?.resume()
        
        return cancel
    }
}

