//
//  RxOutlineViewRealmDataTreeObserver.swift
//  RxRealmDataSources-macOS
//
//  Created by Loki on 4/24/18.
//

import Foundation

class ObserverTreeNode {
    private(set) var children               = [ObserverTreeNode]()
    private(set) var childrenCount: Int     = 0
    
    init(item: RxOutlineViewRealmDataItem) {
        
        childrenCount = item.childrenCount
        
        for i in 0 ..< item.childrenCount {
            let child = item.childAt(idx: i)
            assert(child != nil)
            if let child = child {
                children.append(ObserverTreeNode(item: child))
            }
        }
    }
    
    func update(item: RxOutlineViewRealmDataItem) {
    
    }
}

class RxOutlineViewRealmDataTreeObserver {
    
    private(set) var items = [ObserverTreeNode]()
    
    init(rootItems: [RxOutlineViewRealmDataItem]) {
        for item in rootItems {
            items.append(ObserverTreeNode(item: item))
        }
    }
    
}
