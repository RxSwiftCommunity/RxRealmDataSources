//
//  MenuViewController.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa
import RealmSwift

import RxSwift
import RxCocoa
import RxRealm
import RxRealmDataSources

class CollectionViewController: NSViewController {

    @IBOutlet var collectionView: NSCollectionView!

    private let bag = DisposeBag()
    private let data = DataRandomizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // create data source
        let dataSource = RxCollectionViewRealmDataSource<Lap>(itemIdentifier: "CollectionItem", itemType: CollectionItem.self) {cell, row, lap in
            cell.text.stringValue = "\(lap.text)"
        }
        dataSource.delegate = self

        // RxRealm to get Observable<Results>
        let realm = try! Realm(configuration: data.config)
        let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
            .share()

        // bind to table view
        let binder = collectionView.rx.realmChanges(dataSource)

        laps
            .bind(to: binder)
            .disposed(by: bag)

        // bind to window title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .subscribe(onNext: {title in
                NSApp.windows.first?.title = title
            })
            .disposed(by: bag)

        // demo inserting and deleting data
        data.start()
    }
}

extension CollectionViewController: NSCollectionViewDelegate {

}
