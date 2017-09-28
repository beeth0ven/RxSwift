//
//  MyImmediateSchedulerType.swift
//  Rx
//
//  Created by luojie on 2017/9/27.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol MyImmediateSchedulerType {
    
    func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable
}


