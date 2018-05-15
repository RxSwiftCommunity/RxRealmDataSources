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
    
    dynamic var key             : String            = UUID().uuidString
    dynamic var title           : String            = ""
    dynamic var time            : Double            = 0
    dynamic var children        = LinkingObjects(fromType: TreeItem.self, property: "parent")
    dynamic var parent          : TreeItem?         { didSet { _indexInParent = (parent == nil) ? -1 : parent!.childrenCount } }
    dynamic var _indexInParent  : Int               = -1
    
    // RxOutlineViewRealmDataItem implementation
    var isExpandable    : Bool  { return childrenCount > 0 }
    var childrenCount   : Int   { return children.count }
    var indexInParent   : Int   { return _indexInParent}
    
    func childAt(idx: Int) -> RxOutlineViewRealmDataItem? {
        guard idx >= 0 else { return nil }
        guard idx < children.count else { return nil }
        
        return children[idx]
    }
    
    func getParent() -> RxOutlineViewRealmDataItem? {
        return parent
    }
    
    func getChildren() -> [RxOutlineViewRealmDataItem] {
        return children.toArray()
    }
}

