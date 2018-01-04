//
//  DispatchTimeConverterTest.swift
//  Tests
//
//  Created by luojie on 2018/1/1.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Dispatch

class DispatchTimeConverterTest: RxTest {
}

extension DispatchTimeConverterTest {
    
    func testDispatchTimeInterval() {
        
        let intervals: [TimeInterval] = [
            0.0001,
            0.001,
            0.01,
            0.1,
            1,
            10,
            100,
            1000,
            10000
        ]
        
        let dispatchIntervals = intervals.map(DispatchTimeConverter.dispatchTimeInterval)
        
        let correct: [DispatchTimeInterval] = [
            .milliseconds(0),
            .milliseconds(1),
            .milliseconds(10),
            .milliseconds(100),
            .milliseconds(1000),
            .milliseconds(10000),
            .milliseconds(100000),
            .milliseconds(1000000),
            .milliseconds(10000000)
        ]
        
        XCTAssertEqual(dispatchIntervals, correct)
    }
    
    func testDispatchTimeInterval_random() {
        
        let intervals: [TimeInterval] = [
            89444.94,
            128479.0,
            540280.9,
            3186.185,
            43148.2,
            448.2853,
            26571.19,
            807875.3,
            299702.70,
            988.3292,
            ]
        
        let dispatchIntervals = intervals.map(DispatchTimeConverter.dispatchTimeInterval)
        
        let correct: [DispatchTimeInterval] = [
            .milliseconds(89444940),
            .milliseconds(128479000),
            .milliseconds(540280900),
            .milliseconds(3186185),
            .milliseconds(43148200),
            .milliseconds(448285),
            .milliseconds(26571190),
            .milliseconds(807875300),
            .milliseconds(299702700),
            .milliseconds(988329)
        ]
        
        XCTAssertEqual(dispatchIntervals, correct)
    }
    
    func testTimeInterval_seconds() {
        
        let dispatchIntervals: [DispatchTimeInterval] = [
            .seconds(1),
            .seconds(4),
            .seconds(154),
            .seconds(18676),
            .seconds(142352),
            .seconds(5243555),
            .seconds(23451),
            .seconds(1230),
            .seconds(978979),
            ]
        
        let intervals = dispatchIntervals.map(DispatchTimeConverter.timeInterval)
        
        XCTAssertEqual(intervals, [
            1.0,
            4.0,
            154.0,
            18676.0,
            142352.0,
            5243555.0,
            23451.0,
            1230.0,
            978979.0,
            ])
    }
    
    func testTimeInterval_milliseconds() {
        
        let dispatchIntervals: [DispatchTimeInterval] = [
            .milliseconds(1),
            .milliseconds(4),
            .milliseconds(154),
            .milliseconds(18676),
            .milliseconds(142352),
            .milliseconds(5243555),
            .milliseconds(23451),
            .milliseconds(1230),
            .milliseconds(978979),
            ]
        
        let intervals = dispatchIntervals.map(DispatchTimeConverter.timeInterval)
        
        XCTAssertEqual(intervals, [
            0.001,
            0.004,
            0.154,
            18.676,
            142.352,
            5243.555,
            23.451,
            1.230,
            978.979,
            ])
    }
    
    func testTimeInterval_microseconds() {
        
        let dispatchIntervals: [DispatchTimeInterval] = [
            .microseconds(1),
            .microseconds(4),
            .microseconds(154),
            .microseconds(18676),
            .microseconds(142352),
            .microseconds(5243555),
            .microseconds(23451),
            .microseconds(1230),
            .microseconds(978979),
            ]
        
        let intervals = dispatchIntervals.map(DispatchTimeConverter.timeInterval)
        
        XCTAssertEqual(intervals, [
            0.000001,
            0.000004,
            0.000154,
            0.018676,
            0.142352,
            5.243555,
            0.023451,
            0.001230,
            0.978979,
            ])
    }
    
    func testTimeInterval_nanoseconds() {
        
        let dispatchIntervals: [DispatchTimeInterval] = [
            .nanoseconds(1),
            .nanoseconds(4),
            .nanoseconds(154),
            .nanoseconds(18676),
            .nanoseconds(142352),
            .nanoseconds(5243555),
            .nanoseconds(23451),
            .nanoseconds(1230),
            .nanoseconds(978979),
            ]
        
        let intervals = dispatchIntervals.map(DispatchTimeConverter.timeInterval)
        
        XCTAssertEqual(intervals, [
            0.000000001,
            0.000000004,
            0.000000154,
            0.000018676,
            0.000142352,
            0.005243555,
            0.000023451,
            0.000001230,
            0.000978979,
            ])
        
    }
    
    func testTimeInterval_never() {
        
        let dispatchInterval = DispatchTimeInterval.never
        
        let interval = DispatchTimeConverter.timeInterval(dispatchInterval)
        
        XCTAssertEqual(interval, TimeInterval.infinity)
    }
}

