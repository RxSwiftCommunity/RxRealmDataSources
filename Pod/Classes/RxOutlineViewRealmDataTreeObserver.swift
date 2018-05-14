//
//  RxOutlineViewRealmDataTreeObserver.swift
//  RxRealmDataSources-macOS
//
//  Created by Loki on 4/24/18.
//

import Foundation

class ObserverTreeNode {
    private(set) var children               = [ObserverTreeNode]()
    private(set) var childrenCountBefore    : Int   = 0
    
    init(item: RxOutlineViewRealmDataItem) {
        item.getChildren().forEach {
            children.append(ObserverTreeNode(item: $0))
        }
    }
    
    func update(item: RxOutlineViewRealmDataItem) {
        childrenCountBefore = children.count
        
        let diff = children.count - item.childrenCount
        
        if diff > 0 {
            children.removeLast(diff)
        }
        
        for (idx,child) in item.getChildren().enumerated() {
            if idx < children.count {
                children[idx].update(item: child)
            } else {
                children.append(ObserverTreeNode(item: child))
            }
        }
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
