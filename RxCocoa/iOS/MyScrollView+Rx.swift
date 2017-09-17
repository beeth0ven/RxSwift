//
//  MyScrollView+Rx.swift
//  Rx
//
//  Created by luojie on 2017/9/17.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import UIKit

extension Reactive where Base: UIScrollView {
    
    var myDelegate: MyDelegateProxy {
        return MyCrollViewDelegateProxy.proxyForObject(base)
    }
    
    var myContentOffset: ControlProperty<CGPoint> {
        let source = MyCrollViewDelegateProxy.proxyForObject(base).contentOffsetBehaviorSubject
        let valueSink = UIBindingObserver<UIScrollView, CGPoint>(UIElement: base) { (base, point) in
            base.contentOffset = point
        }
        return ControlProperty(values: source, valueSink: valueSink)
    }
    
    var myDidScroll: ControlEvent<Void> {
        let source = MyCrollViewDelegateProxy.proxyForObject(base).contentOffsetPublishSubject
        return ControlEvent(events: source)
    }
    
    func mySetDelegate(_ delegate: UIScrollViewDelegate) -> Disposable {
        return MyCrollViewDelegateProxy
            .installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: base)
    }
}
