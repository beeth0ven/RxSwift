//
//  Observable+MyCombineLatestTests.swift
//  Rx
//
//  Created by luojie on 2017/9/9.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMyCombineLatestTest: RxTest {}

extension ObservableMyCombineLatestTest {
    
    func testMyCombineLatest_NeverEmpty() {
        
        let factories: [(TestableObservable<Int>, TestableObservable<Int>) -> Observable<Int>] =
            [
                { e0, e1 in Observable.myCombineLatest([e0, e1]) { values in values[0] + values[1] } },
                { e0, e1 in Observable.myCombineLatest([e0, e1]).map { values in values[0] + values[1] } }
            ]
        
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)
            
            let e0 = scheduler.createHotObservable([
                next(150, 1)
                ])
            
            let e1 = scheduler.createHotObservable([
                next(150, 1),
                completed(210)
                ])
            
            let res = scheduler.start {
                factory(e0, e1)
            }

            XCTAssertEqual(res.events, [])
            
            XCTAssertEqual(e0.subscriptions, [Subscription(200, 1000)])
            XCTAssertEqual(e1.subscriptions, [Subscription(200, 210)])
        }
    }
}
