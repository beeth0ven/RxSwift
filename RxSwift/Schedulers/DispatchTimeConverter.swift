//
//  DispatchTimeConverter.swift
//  RxSwift
//
//  Created by luojie on 2017/12/29.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import Foundation

#if os(Linux)
    import let CDispatch.NSEC_PER_MSEC
    import let CDispatch.USEC_PER_SEC
    import let CDispatch.NSEC_PER_SEC
#endif

/// Converts intervals between **TimeInterval** and **DispatchTimeInterval**
public struct DispatchTimeConverter {
    
    private static var MSEC_PER_SEC: UInt64 {
        return NSEC_PER_SEC / NSEC_PER_MSEC
    }
    
    /**
     Converts from `TimeInterval` to `DispatchTimeInterval`.
     
     - parameter interval: `TimeInterval` to convert to `DispatchTimeInterval`.
     - returns: `DispatchTimeInterval` corresponding to `TimeInterval`.
     */
    public static func dispatchTimeInterval(_ interval: TimeInterval) -> DispatchTimeInterval {
        precondition(interval >= 0.0)
        let milliseconds = interval * TimeInterval(MSEC_PER_SEC)
        return DispatchTimeInterval.milliseconds(Int(milliseconds))
    }
    
    
    /**
     Converts from `DispatchTimeInterval` to `TimeInterval`.
     
     - parameter interval: `DispatchTimeInterval` to convert to `TimeInterval`.
     - returns: `TimeInterval` corresponding to `DispatchTimeInterval`.
     */
    public static func timeInterval(_ interval: DispatchTimeInterval) -> TimeInterval {
        switch interval {
        case .seconds(let seconds):
            return TimeInterval(seconds)
        case .milliseconds(let milliseconds):
            return TimeInterval(milliseconds) / TimeInterval(MSEC_PER_SEC)
        case .microseconds(let microseconds):
            return TimeInterval(microseconds) / TimeInterval(USEC_PER_SEC)
        case .nanoseconds(let nanoseconds):
            return TimeInterval(nanoseconds) / TimeInterval(NSEC_PER_SEC)
        case .never:
            return TimeInterval.infinity
        }
    }
}
