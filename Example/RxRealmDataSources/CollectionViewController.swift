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

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(CollectionViewController.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)

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
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // bind to vc title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .bind(to: rx.title)
            .disposed(by: bag)

        // react on cell taps
        collectionView.rx.modelSelected(Lap.self)
            .map({ $0.text })
            .bind(to: rx.title)
            .disposed(by: bag)

        collectionView.rx.dataSource.methodInvoked(#selector(UICollectionViewDataSource.collectionView(_:moveItemAt:to:)))
            .subscribe(onNext: { a in
                guard let from = a[1] as? IndexPath, let to = a[2] as? IndexPath else { return }
                try! realm.write {
                    let laps = realm.objects(Timer.self).first!.laps
                    laps.swapAt(from.row, to.row)
                }
            })
            .disposed(by: bag)

        // demo inserting and deleting data
        data.start()
    }

    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            guard let selectedIndexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            data.stop()
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            collectionView.endInteractiveMovement()
            data.start()
        default:
            collectionView.cancelInteractiveMovement()
            data.start()
        }
    }
}
