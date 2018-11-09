//
//  CollectionViewController.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/11/16.
//  Copyright © 2016 RxSwiftCommunity. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift
import RxCocoa
import RxRealm
import RxRealmDataSources

class CollectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!

    private let bag = DisposeBag()
    private let data = DataRandomizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // create data source
        let dataSource = RxCollectionViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: LapCollectionCell.self) {cell, ip, lap in
            cell.customLabel.text = "\(ip.row). \(lap.text)"
        }

        // RxRealm to get Observable<Results>
        let realm = try! Realm(configuration: data.config)
        let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
            .share()

        // bind to collection view
        laps
            .bind(to: collectionView.rx.realmChanges(dataSource))
            .disposed(by: bag)

        // bind to vc title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .bind(to: rx.title)
            .disposed(by: bag)

        // react on cell taps
        collectionView.rx.realmModelSelected(Lap.self)
            .map({ $0.text })
            .bind(to: rx.title)
            .disposed(by: bag)

        // demo inserting and deleting data
        data.start()
    }
}

