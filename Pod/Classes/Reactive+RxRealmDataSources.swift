//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//  Check the LICENSE file for details
//

import Foundation

import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

public typealias RealmChange<E: RealmCollectionValue> = (AnyRealmCollection<E>, RealmChangeset?)

#if os(iOS)
// MARK: - iOS / UIKit

import UIKit
extension Reactive where Base: UITableView {

    @available(*, deprecated, message: "use items(dataSource:) instead")
    public func realmChanges<
            DataSource: RxTableViewDataSourceType & UITableViewDataSource,
            O: ObservableType>
        (_ dataSource: DataSource)
        -> (_ source: O)
        -> Disposable
        where DataSource.Element == O.E {
        return items(dataSource: dataSource)
    }

    @available(*, deprecated, renamed: "modelSelected")
    public func realmModelSelected<E>(_ modelType: E.Type) -> ControlEvent<E> where E: RealmSwift.Object {
        return modelSelected(modelType)
    }
}

extension Reactive where Base: UICollectionView {

    @available(*, deprecated, message: "use items(dataSource:) instead")
    public func realmChanges<
            DataSource: RxCollectionViewDataSourceType & UICollectionViewDataSource,
            O: ObservableType>
        (_ dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.E {
        return items(dataSource: dataSource)
    }

    @available(*, deprecated, renamed: "modelSelected")
    public func realmModelSelected<E>(_ modelType: E.Type) -> ControlEvent<E> where E: RealmSwift.Object {
        return modelSelected(modelType)
    }
}


#elseif os(OSX)
// MARK: - macOS / Cocoa

import Cocoa
extension Reactive where Base: NSTableView {

    public func realmChanges<E>(_ dataSource: RxTableViewRealmDataSource<E>)
        -> Binder<RealmChange<E>> {

            base.delegate = dataSource
            base.dataSource = dataSource

            return Binder(base) { tableView, element in
                if dataSource.tableView == nil {
                    dataSource.tableView = tableView
                }
                dataSource.applyChanges(items: element.0, changes: element.1)
            }
    }
}

extension Reactive where Base: NSCollectionView {

    public func realmChanges<E>(_ dataSource: RxCollectionViewRealmDataSource<E>)
        -> Binder<RealmChange<E>> {

            base.dataSource = dataSource
            
            return Binder(base) { collectionView, element in
                if dataSource.collectionView == nil {
                    dataSource.collectionView = collectionView
                }
                dataSource.applyChanges(items: element.0, changes: element.1)
            }
    }
}

#endif
