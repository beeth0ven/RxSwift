//
//  SchedulerTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
#if os(Linux)
import Glibc
import Dispatch
#endif

import struct Foundation.Date

class ConcurrentDispatchQueueSchedulerTests: RxTest {
    func createScheduler() -> SchedulerType {
        return ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    }
}

final class SerialDispatchQueueSchedulerTests: RxTest {
    func createScheduler() -> SchedulerType {
        return SerialDispatchQueueScheduler(qos: .userInitiated)
    }
}

extension ConcurrentDispatchQueueSchedulerTests {
    func test_scheduleRelative() {
        
        typealias ScheduleAction = (Int) -> Disposable
        
        let scheduleRelatives: [(SchedulerType, @escaping ScheduleAction) -> Disposable] = [
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: 0.5, action: action) },
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: .milliseconds(500), action: action) },
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: .microseconds(500_000), action: action) },
        ]
        
        for scheduleRelative in scheduleRelatives {
            
            let expectScheduling = expectation(description: "wait")
            let start = Date()
            
            var interval = 0.0
            
            let scheduler = self.createScheduler()
            
            _ = scheduleRelative(scheduler) { (_) -> Disposable in
                interval = Date().timeIntervalSince(start)
                expectScheduling.fulfill()
                return Disposables.create()
            }
            
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
            }
            
            XCTAssertEqual(interval, 0.5, accuracy: 0.2)
            
        }
    }

    func test_scheduleRelativeCancel() {
        
        typealias ScheduleAction = (Int) -> Disposable
        
        let scheduleRelatives: [(SchedulerType, @escaping ScheduleAction) -> Disposable] = [
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: 0.1, action: action) },
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: .milliseconds(100), action: action) },
        { scheduler, action in scheduler.scheduleRelative(1, dueTime: .microseconds(100_000), action: action) },
        ]
        
        for scheduleRelative in scheduleRelatives {
            
            let expectScheduling = expectation(description: "wait")
            let start = Date()
            
            var interval = 0.0
            
            let scheduler = self.createScheduler()
            
            let disposable = scheduleRelative(scheduler) { (_) -> Disposable in
                interval = Date().timeIntervalSince(start)
                expectScheduling.fulfill()
                return Disposables.create()
            }
            disposable.dispose()
            
            DispatchQueue.main.asyncAfter (deadline: .now() + .milliseconds(200)) {
                expectScheduling.fulfill()
            }
            
            waitForExpectations(timeout: 0.5) { error in
                XCTAssertNil(error)
            }
            
            XCTAssertEqual(interval, 0.0, accuracy: 0.0)
            
        }
    }

    func test_schedulePeriodic() {
        
        typealias ScheduleAction = (Int) -> Int
        
        let schedulePeriodics: [(SchedulerType, @escaping ScheduleAction) -> Disposable] = [
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: 0.2, period: 0.3, action: action) },
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: .milliseconds(200), period: .milliseconds(300), action: action) },
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: .microseconds(200_000), period: .microseconds(300_000), action: action) },
        ]
        
        for schedulePeriodic in schedulePeriodics {
            
            let expectScheduling = expectation(description: "wait")
            let start = Date()
            var times = [Date]()
            
            let scheduler = self.createScheduler()
            
            let disposable = schedulePeriodic(scheduler) { (state) -> Int in
                times.append(Date())
                if state == 1 {
                    expectScheduling.fulfill()
                }
                return state + 1
            }
            
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
            }
            
            disposable.dispose()
            
            XCTAssertEqual(times.count, 2)
            XCTAssertEqual(times[0].timeIntervalSince(start), 0.2, accuracy: 0.1)
            XCTAssertEqual(times[1].timeIntervalSince(start), 0.5, accuracy: 0.2)
            
        }
    }

    func test_schedulePeriodicCancel() {
        
        typealias ScheduleAction = (Int) -> Int
        
        let schedulePeriodics: [(SchedulerType, @escaping ScheduleAction) -> Disposable] = [
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: 0.2, period: 0.3, action: action) },
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: .milliseconds(200), period: .milliseconds(300), action: action) },
        { scheduler, action in scheduler.schedulePeriodic(0, startAfter: .microseconds(200_000), period: .microseconds(300_000), action: action) },
        ]
        
        for schedulePeriodic in schedulePeriodics {
            
            let expectScheduling = expectation(description: "wait")
            var times = [Date]()
            
            let scheduler = self.createScheduler()
            
            let disposable = schedulePeriodic(scheduler) { (state) -> Int in
                times.append(Date())
                return state + 1
            }
            
            disposable.dispose()
            
            DispatchQueue.main.asyncAfter (deadline: .now() + .milliseconds(300)) {
                expectScheduling.fulfill()
            }
            
            waitForExpectations(timeout: 1.0) { error in
                XCTAssertNil(error)
            }
            
            XCTAssertEqual(times.count, 0)
        }
    }
}
