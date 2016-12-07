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

public typealias CellFactory<E: Object> = (RxTableViewRealmDataSource<E>, UITableView, IndexPath, E) -> UITableViewCell
public typealias CellConfig<E: Object, CellType: UITableViewCell> = (CellType, IndexPath, E) -> Void

public class RxTableViewRealmDataSource<E>: NSObject, UITableViewDataSource where E: Object {


    public var items: Results<E>? 
    public var tableView: UITableView?

    public var cellIdentifier: String
    public var cellFactory: CellFactory<E>?

    public init(cellIdentifier: String, cellFactory: @escaping CellFactory<E>) {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = cellFactory
    }

    public init<CellType>(cellIdentifier: String, cellType: CellType.Type, cellConfig: @escaping CellConfig<E, CellType>) where CellType: UITableViewCell {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = {ds, tv, ip, model in
            let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: ip) as! CellType
            cellConfig(cell, ip, model)
            return cell
        }
    }

    //UITableViewDataSource
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellFactory!(self, tableView, indexPath, items![indexPath.row])
    }

    func applyChanges(items: Results<E>, changes: RealmChangeset?) {
        if self.items == nil {
            self.items = items
        }

        let tableView = self.tableView!

        if let changes = changes {
            let fromRow = {(row: Int) in
                return IndexPath(row: row, section: 0)}

            tableView.beginUpdates()
            tableView.insertRows(at: changes.inserted.map(fromRow), with: .automatic)
            tableView.reloadRows(at: changes.updated.map(fromRow), with: .none)
            tableView.deleteRows(at: changes.deleted.map(fromRow), with: .automatic)
            tableView.endUpdates()

        } else {
            tableView.reloadData()
        }
    }
}

public class RealmBindObserver<E, O: Object>: ObserverType {

    public typealias E = UpdateTuple
    public typealias UpdateTuple = (Results<O>, RealmChangeset?)
    typealias BindingType = (RxTableViewRealmDataSource<O>, Results<O>, RealmChangeset?) -> Void

    let dataSource: RxTableViewRealmDataSource<O>
    let binding: BindingType

    init(dataSource: RxTableViewRealmDataSource<O>, binding: @escaping BindingType) {
        self.dataSource = dataSource
        self.binding = binding
    }

    public func on(_ event: Event<E>) {
        switch event {
        case .next(let element):
            binding(dataSource, element.0, element.1)
        case .error:
            return
        case .completed:
            return
        }
    }

    func asObserver() -> AnyObserver<E> {
        return AnyObserver(eventHandler: on)
    }
}


extension Reactive where Base: UITableView {

    public func realmChanges<E>(_ dataSource: RxTableViewRealmDataSource<E>)
        -> RealmBindObserver<(Results<E>, RealmChangeset?), E> where E: Object {

        return RealmBindObserver(dataSource: dataSource) {ds, results, changes in
            if ds.tableView == nil {
                ds.tableView = self.base
            }
            if ds.tableView?.dataSource == nil {
                ds.tableView?.dataSource = ds
            }
            ds.applyChanges(items: results, changes: changes)
        }
    }
}
