//
//  Observable+MyWithLatestFromTests.swift
//  Rx
//
//  Created by luojie on 2017/9/6.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMyWithLatestFromTest: RxTest {}

extension ObservableMyWithLatestFromTest {
    
    func testMyWithLatestFrom_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(90, 1),
            next(180, 2),
            next(250, 3),
            next(260, 4),
            next(310, 5),
            next(340, 6),
            next(410, 7),
            next(420, 8),
            next(470, 9),
            next(550, 10),
            completed(590)
            ])
        
        let ys = scheduler.createHotObservable([
            next(255, "bar"),
            next(330, "foo"),
            next(350, "qux"),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.withLatestFrom(ys) { x, y in "\(x)\(y)" }
        }
        
        XCTAssertEqual(res.events, [
            next(260, "4bar"),
            next(310, "5bar"),
            next(340, "6foo"),
            next(410, "7qux"),
            next(420, "8qux"),
            next(470, "9qux"),
            next(550, "10qux"),
            completed(590)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 590)
            ])
        
        XCTAssertEqual(ys.subscriptions, [
            Subscription(200, 400)
            ])
    }
}
