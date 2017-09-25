//
//  MyDriver.swift
//  Rx
//
//  Created by luojie on 2017/9/24.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public typealias MyDriver<E> = MySharedSequence<MyDriverStrategy, E>

public struct MyDriverStrategy: MySharedSequenceStrategyProtocol {
    
    public static func scheduler() -> SchedulerType {
        return MainScheduler()
    }
    
    public static func share<E>(_ source: Observable<E>) -> Observable<E> {
        return source.share(replay: 1, scope: .whileConnected)
    }
}

extension ObservableConvertibleType {
    
    public func asMyDriver(catchErrorJustReturn element: E) -> MyDriver<E> {
        let source = self.asObservable()
            .observeOn(DriverSharingStrategy.scheduler)
            .catchErrorJustReturn(element)
        return MyDriver(source)
    }
}
