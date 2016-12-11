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

public typealias CollectionCellFactory<E: Object> = (RxCollectionViewRealmDataSource<E>, UICollectionView, IndexPath, E) -> UICollectionViewCell
public typealias CollectionCellConfig<E: Object, CellType: UICollectionViewCell> = (CellType, IndexPath, E) -> Void

public class RxCollectionViewRealmDataSource <E: Object>: NSObject, UICollectionViewDataSource {
    private var items: AnyRealmCollection<E>?

    // MARK: - Configuration

    public var collectionView: UICollectionView?
    public var animated = true

    // MARK: - Init
    public let cellIdentifier: String
    public let cellFactory: CollectionCellFactory<E>

    public init(cellIdentifier: String, cellFactory: @escaping CollectionCellFactory<E>) {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = cellFactory
    }

    public init<CellType>(cellIdentifier: String, cellType: CellType.Type, cellConfig: @escaping CollectionCellConfig<E, CellType>) where CellType: UICollectionViewCell {
        self.cellIdentifier = cellIdentifier
        self.cellFactory = {ds, cv, ip, model in
            let cell = cv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: ip) as! CellType
            cellConfig(cell, ip, model)
            return cell
        }
    }

    // MARK: - UICollectionViewDataSource protocol
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items?.count ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellFactory(self, collectionView, indexPath, items![indexPath.row] as! E)
    }

    // MARK: - Applying changeset to the collection view
    private let fromRow = {(row: Int) in return IndexPath(row: row, section: 0)}

    func applyChanges(items: AnyRealmCollection<E>, changes: RealmChangeset?) {
        if self.items == nil {
            self.items = items
        }

        guard let collectionView = collectionView else {
            fatalError("You have to bind a collection view to the data source.")
        }

        guard animated else {
            collectionView.reloadData()
            return
        }

        guard let changes = changes else {
            collectionView.reloadData()
            return
        }

        let lastItemCount = collectionView.numberOfItems(inSection: 0)
        guard items.count == lastItemCount + changes.inserted.count - changes.deleted.count else {
            collectionView.reloadData()
            return
        }

        collectionView.performBatchUpdates({[unowned self] in
            collectionView.deleteItems(at: changes.deleted.map(self.fromRow))
            collectionView.reloadItems(at: changes.updated.map(self.fromRow))
            collectionView.insertItems(at: changes.inserted.map(self.fromRow))
        }, completion: nil)
    }
}
