//
//  MyRxTableViewDelegateProxy.swift
//  Rx
//
//  Created by luojie on 2017/9/17.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import UIKit

public class MyRxTableViewDelegateProxy: MyCrollViewDelegateProxy, UITableViewDelegate {
    
    public weak private(set) var tableView: UITableView?
    
    public required init(parentObject: AnyObject) {
        self.tableView = parentObject as? UITableView
        super.init(parentObject: parentObject)
    }
}
