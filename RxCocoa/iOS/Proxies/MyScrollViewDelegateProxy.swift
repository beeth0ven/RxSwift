//
//  MyScrollViewDelegateProxy.swift
//  Rx
//
//  Created by luojie on 2017/9/17.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import UIKit

public class MyCrollViewDelegateProxy: MyDelegateProxy,
    UIScrollViewDelegate,
    IsDelegateProxy {
    
    fileprivate weak var scrollView: UIScrollView?
    
    fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
    fileprivate var _contentOffsetPublishSubject: PublishSubject<Void>?

    internal var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
        switch _contentOffsetBehaviorSubject {
        case let subject?:
            return subject
        default:
            let subject = BehaviorSubject<CGPoint>(value: scrollView?.contentOffset ?? .zero)
            _contentOffsetBehaviorSubject = subject
            return subject
        }
    }
    
    internal var contentOffsetPublishSubject: PublishSubject<Void> {
        switch _contentOffsetPublishSubject {
        case let subject?:
            return subject
        default:
            let subject = PublishSubject<Void>()
            _contentOffsetPublishSubject = subject
            return subject
        }
    }
    
    required public init(parentObject: AnyObject) {
        self.scrollView = parentObject as? UIScrollView
        super.init(parentObject: parentObject)
    }
    
    public static func getDelegateFor(_ object: AnyObject) -> AnyObject? {
        return (object as! UIScrollView).delegate
    }
    
    public static func setDelegate(_ delegate: AnyObject?, to object: AnyObject) {
        (object as! UIScrollView).delegate = delegate as? UIScrollViewDelegate
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        _contentOffsetBehaviorSubject?.onNext(scrollView.contentOffset)
        _contentOffsetPublishSubject?.onNext(())
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    deinit {
        _contentOffsetBehaviorSubject?.onCompleted()
        _contentOffsetPublishSubject?.onCompleted()
    }
    
}
