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
    
    // MARK: - NSOutlineViewDataSource protocol
    public func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        guard let item = item as? E else { return nil }
        let columnId = tableColumn?.identifier.rawValue
        return cellFactory(outlineView, columnId, item)
    }
    
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if item == nil {
            if let rootItems = items?.filter("parent = null", 0) {
                return rootItems.count
            }
            return 0
        }
        if let item = item as? RxOutlineViewRealmDataItem {
            return item.childrenCount
        }
        
        return 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        if item == nil {
            if let rootItems = items?.filter("parent = null", 0) {
                return rootItems[index]
            }
            return 0
        }
        guard let item = item as? RxOutlineViewRealmDataItem else { return false }
        guard let child = item.childAt(idx: index) else { return false }
        
        return child

    }
    
    public func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        guard let item = item as? RxOutlineViewRealmDataItem else { return false }
        
        return item.isExpandable
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
            fatalError("You have to bind a table view to the data source.")
        }
        
        //guard animated else {
        //    outlineView.reloadData()
        //    return
        //}
        
//        guard let changes = changes else {
//            outlineView.reloadData()
//            return
//        }
        
        //outlineView.reloadData()
        
        outlineView.beginUpdates()
        outlineView.removeItems(at: IndexSet(changes.deleted), inParent: <#T##Any?#>, withAnimation: <#T##NSTableView.AnimationOptions#>)
        //tableView.removeRows(at: IndexSet(changes.deleted), withAnimation: rowAnimations.delete)
        //tableView.insertRows(at: IndexSet(changes.inserted), withAnimation: rowAnimations.insert)
        //outlineView.reloadData(forRowIndexes: IndexSet(changes.updated), columnIndexes: IndexSet([0]))
        //outlineView.endUpdates()
    }
}

#endif
