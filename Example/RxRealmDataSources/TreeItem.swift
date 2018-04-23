//
//  TreeItem.swift
//  RxRealmDataSources
//
//  Created by Sergiy Vynnychenko on 4/23/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealmDataSources

@objcMembers class TreeItem: Object, RxOutlineViewRealmDataItem {
    
    
    
    override static func primaryKey() -> String? { return "key" }
    
    dynamic var key         : String            = UUID().uuidString
    dynamic var title       : String            = ""
    dynamic var time        : Double            = 0
    dynamic var children    = List<TreeItem>()
    dynamic var _parents    = LinkingObjects(fromType: TreeItem.self, property: "children")

    
    // RxOutlineViewRealmDataItem implementation
    var isExpandable: Bool  { return childrenCount > 0 }
    var childrenCount : Int  { get { return children.count } }
    
    func childAt(idx: Int) -> RxOutlineViewRealmDataItem? {
        guard idx >= 0 else { return nil }
        guard idx < children.count else { return nil }
        
        return children[idx]
    }
    
    func getParent() -> RxOutlineViewRealmDataItem? {
        guard _parents.count > 0 else { return nil }
        
        return _parents[0]
    }
}

