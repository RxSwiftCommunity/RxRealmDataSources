//
//  RxOutlineViewRealmDataSource.swift
//  Pods-Demo-RxRealmDataSources_MacExample
//
//  Created by Loki on 4/23/18.
//

import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

#if os(OSX)
import Cocoa

public typealias OutlineCellFactory<E: Object> = (NSOutlineView, String?, E) -> NSTableCellView
public typealias OutlineCellConfig<E: Object, CellType: NSTableCellView> = (CellType, String?, E) -> Void

open class RxOutlineViewRealmDataSource<E: Object>: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    private var items: AnyRealmCollection<E>?
    
    // MARK: - Configuration
    
    public var outlineView: NSOutlineView?
    public var animated = true
    public var rowAnimations = (
        insert: NSTableView.AnimationOptions.effectFade,
        update: NSTableView.AnimationOptions.effectFade,
        delete: NSTableView.AnimationOptions.effectFade)
    
    public weak var delegate: NSOutlineViewDelegate?
    public weak var dataSource: NSOutlineViewDataSource?
    
    // MARK: - Init
    public let cellIdentifier: String
    public let cellFactory: OutlineCellFactory<E>
    
    public init(cellIdentifier: String, cellFactory: @escaping OutlineCellFactory<E>) {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = cellFactory
    }
    
    public init<CellType>(cellIdentifier: String, cellType: CellType.Type, cellConfig: @escaping OutlineCellConfig<E, CellType>) where CellType: NSTableCellView {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = { ov, columnId, model in
            let cell = ov.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: ov) as! CellType
            cellConfig(cell, columnId, model)
            return cell
        }
    }
    
    private func objectBy(key: Any) -> RxOutlineViewRealmDataItem? {
        guard let items = items else { return nil }
        guard let key = key as? String else { return nil }
        guard let index = items.index(matching: "key = %s", key) else { return nil }
        
        return items[index] as? RxOutlineViewRealmDataItem
    }

    
    // MARK: - NSOutlineViewDataSource protocol
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let object = objectBy(key: item) as? E else { return nil }
        let columnId = tableColumn?.identifier.rawValue
        return cellFactory(outlineView, columnId, object)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        guard let item = item else {
            if let rootItems = items?.filter("parent = null", 0) {
                return rootItems.count
            }
            return 0
        }
        
        guard let object = objectBy(key: item) else { return 0 }
        return object.childrenCount
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        guard let item = item else {
            guard let items = items else { return false }
            if let rootItems = Array(items.filter("parent = null", 0)) as? [RxOutlineViewRealmDataItem] {
                return rootItems[index].key
            }
            return false
        }
        
        guard let object = objectBy(key: item) else { return false }
        guard let child = object.childAt(idx: index) else { return false}
        
        return child.key
    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let object = objectBy(key: item) else { return false }
        return object.isExpandable
    }
    
    // MARK: - Proxy unimplemented data source and delegate methods
    open override func responds(to aSelector: Selector!) -> Bool {
        if RxOutlineViewRealmDataSource.instancesRespond(to: aSelector) {
            return true
        } else if let delegate = delegate {
            return delegate.responds(to: aSelector)
        } else if let dataSource = dataSource {
            return dataSource.responds(to: aSelector)
        } else {
            return false
        }
    }
    
    open override func forwardingTarget(for aSelector: Selector!) -> Any? {
        return delegate ?? dataSource
    }
    
    // MARK: - Applying changeset to the table view
    private let fromRow = {(row: Int) in return IndexPath(item: row, section: 0)}
    
    func applyChanges(items: AnyRealmCollection<E>, changes: RealmChangeset?) {
        if self.items == nil {
            self.items = items
        }
        
        guard let outlineView = outlineView else {
            fatalError("You have to bind a outline view to the data source.")
        }
        
        outlineView.reloadData()
    }
}

#endif
