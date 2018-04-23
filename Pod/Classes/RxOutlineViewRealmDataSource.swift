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

open class RxOutlineViewRealmDataItem : Object {
    var  childrenCount : Int  { assert(false, "implement me"); return 0 }
    var  isExpandable  : Bool { return childrenCount > 0}
    func childAt(idx: Int) -> RxOutlineViewRealmDataItem? { assert(false, "implement me"); return nil }
}

#if os(OSX)
import Cocoa

public typealias TableCellFactory<E: RxOutlineViewRealmDataItem> = (RxOutlineViewRealmDataSource<E>, NSOutlineView, Int, String?, E) -> NSTableCellView
public typealias TableCellConfig<E: RxOutlineViewRealmDataItem, CellType: NSTableCellView> = (CellType, Int, String?, E) -> Void

open class RxOutlineViewRealmDataSource<E: RxOutlineViewRealmDataItem>: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    
    private var items: AnyRealmCollection<E>?
    
    // MARK: - Configuration
    
    public var tableView: NSTableView?
    public var animated = true
    public var rowAnimations = (
        insert: NSTableView.AnimationOptions.effectFade,
        update: NSTableView.AnimationOptions.effectFade,
        delete: NSTableView.AnimationOptions.effectFade)
    
    public weak var delegate: NSTableViewDelegate?
    public weak var dataSource: NSTableViewDataSource?
    
    // MARK: - Init
    public let cellIdentifier: String
    public let cellFactory: TableCellFactory<E>
    
    public init(cellIdentifier: String, cellFactory: @escaping TableCellFactory<E>) {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = cellFactory
    }
    
    public init<CellType>(cellIdentifier: String, cellType: CellType.Type, cellConfig: @escaping TableCellConfig<E, CellType>) where CellType: NSTableCellView {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = { ds, tv, row, columnId, model in
            let cell = tv.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: tv) as! CellType
            cellConfig(cell, row, columnId, model)
            return cell
        }
    }
    
    // MARK: - NSOutlineViewDataSource protocol
    public func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        if let item = item as? RxOutlineViewRealmDataItem {
            return item.childrenCount
        }
        
        return 0
    }
    
    public func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
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
        
        guard let tableView = tableView else {
            fatalError("You have to bind a table view to the data source.")
        }
        
        guard animated else {
            tableView.reloadData()
            return
        }
        
        guard let changes = changes else {
            tableView.reloadData()
            return
        }
        
        let lastItemCount = tableView.numberOfRows
        guard items.count == lastItemCount + changes.inserted.count - changes.deleted.count else {
            tableView.reloadData()
            return
        }
        
        tableView.beginUpdates()
        tableView.removeRows(at: IndexSet(changes.deleted), withAnimation: rowAnimations.delete)
        tableView.insertRows(at: IndexSet(changes.inserted), withAnimation: rowAnimations.insert)
        tableView.reloadData(forRowIndexes: IndexSet(changes.updated), columnIndexes: IndexSet([0]))
        tableView.endUpdates()
    }
}

#endif
