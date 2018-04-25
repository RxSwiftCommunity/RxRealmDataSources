//
//  RxOutlineViewRealmDataItem.swift
//  Pods
//
//  Created by Loki on 4/23/18.
//

public protocol RxOutlineViewRealmDataItem {
    var  childrenCount : Int    { get }
    var  isExpandable  : Bool   { get }
    var  indexInParent : Int    { get }
    
    func childAt(idx: Int) -> RxOutlineViewRealmDataItem?
    func getParent()       -> RxOutlineViewRealmDataItem?
}
