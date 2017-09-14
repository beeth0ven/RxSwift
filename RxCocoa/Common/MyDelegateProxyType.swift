//
//  MyDelegateProxyType.swift
//  Rx
//
//  Created by luojie on 2017/9/14.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

public protocol IsDelegateProxy: AnyObject {
    
    static func createProxyForObject(_ object: AnyObject) -> AnyObject
    static func getProxyFor(_ object: AnyObject) -> AnyObject?
    static func setProxy(_ proxy: AnyObject, to object: AnyObject)
    
    static func getDelegateFor(_ object: AnyObject) -> AnyObject?
    static func setDelegate(_ delegate: AnyObject?, to object: AnyObject)
    
    func getForwardDelegate() -> AnyObject?
    func setForwardDelegate(_ delegate: AnyObject?, retainDelegate: Bool)
    
}

extension IsDelegateProxy {
    
    public static func proxyForObject(_ object: AnyObject) -> Self {
        MainScheduler.ensureExecutingOnScheduler()
        
        let maybeProxy = Self.getProxyFor(object) as? Self
        
        let proxy: Self
        if let existingProxy = maybeProxy {
            proxy = existingProxy
        } else {
            proxy = Self.createProxyForObject(object) as! Self
            Self.setProxy(proxy, to: object)
            assert(Self.getProxyFor(object) === proxy)
        }
        
        let delegate: AnyObject? = Self.getDelegateFor(object)
        
        if delegate !== proxy {
            proxy.setForwardDelegate(delegate, retainDelegate: false)
            assert(proxy.getForwardDelegate() === delegate)
            Self.setDelegate(proxy, to: object)
            assert(Self.getDelegateFor(object) === proxy)
            assert(proxy.getForwardDelegate() === delegate)
        }
        
        return proxy
    }
}

import UIKit

protocol HasDelegate: AnyObject {
    associatedtype Delegate
    var delegate: Delegate? { get set }
}

extension UIScrollView: HasDelegate {
    typealias Delegate = UIScrollViewDelegate
}

extension UITableView {
    typealias Delegate = UITableViewDelegate
}

class MyDelegateProxy<O: HasDelegate> {
    
}

class MyScrollViewDelegateProxy: MyDelegateProxy<UIScrollView> {
    
}

class MyTableViewDelegateProxy: MyDelegateProxy<UITableView> {
    
}
