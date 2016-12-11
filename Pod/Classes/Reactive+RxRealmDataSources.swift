//
//  RxRealm extensions
//
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//
   
import Foundation
import RealmSwift
import RxSwift
import RxCocoa
import RxRealm

extension Reactive where Base: UITableView {

    public func realmChanges<E>(_ dataSource: RxTableViewRealmDataSource<E>)
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxTableViewRealmDataSource<E>> where E: Object {

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if ds.tableView == nil {
                    ds.tableView = self.base
                }
                ds.tableView?.dataSource = ds
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
    }
}

extension Reactive where Base: UICollectionView {

    public func realmChanges<E>(_ dataSource: RxCollectionViewRealmDataSource<E>)
        -> RealmBindObserver<E, AnyRealmCollection<E>, RxCollectionViewRealmDataSource<E>> where E: Object {

            return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
                if ds.collectionView == nil {
                    ds.collectionView = self.base
                }
                ds.collectionView?.dataSource = ds
                ds.applyChanges(items: AnyRealmCollection<E>(results), changes: changes)
            }
    }
}

