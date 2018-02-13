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

#if os(iOS)
// MARK: - iOS / UIKit

import UIKit
extension Reactive where Base: UITableView {

    public func realmChanges<E>(_ dataSource: RxTableViewRealmDataSource<E>)
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxTableViewRealmDataSource<E>> {

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if ds.tableView == nil {
                    ds.tableView = self.base
                }
                ds.tableView?.dataSource = ds
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
    }

    @available(*, deprecated, renamed: "modelSelected")
    public func realmModelSelected<E>(_ modelType: E.Type) -> ControlEvent<E> where E: RealmSwift.Object {
        return modelSelected(modelType)
    }
}

extension Reactive where Base: UICollectionView {

    public func realmChanges<E>(_ dataSource: RxCollectionViewRealmDataSource<E>)
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxCollectionViewRealmDataSource<E>> {

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if ds.collectionView == nil {
                    ds.collectionView = self.base
                }
                ds.collectionView?.dataSource = ds
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
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
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxTableViewRealmDataSource<E>> {

            base.delegate = dataSource
            base.dataSource = dataSource

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if dataSource.tableView == nil {
                    dataSource.tableView = self.base
                }
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
    }
}

extension Reactive where Base: NSCollectionView {

    public func realmChanges<E>(_ dataSource: RxCollectionViewRealmDataSource<E>)
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxCollectionViewRealmDataSource<E>> {

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if ds.collectionView == nil {
                    ds.collectionView = self.base
                }
                ds.collectionView?.dataSource = ds
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
    }
}

#endif
