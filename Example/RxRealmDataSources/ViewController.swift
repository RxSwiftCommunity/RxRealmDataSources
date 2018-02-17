//
//  ViewController.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/07/2016.
//  Copyright (c) 2016 RxSwiftCommunity. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift
import RxCocoa
import RxRealm
import RxRealmDataSources

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let bag = DisposeBag()
    private let data = DataRandomizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editButtonItem

        // create data source
        let dataSource = RxTableViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: PersonCell.self) {cell, ip, lap in
            cell.customLabel.text = "\(ip.row). \(lap.text)"
        }

        // RxRealm to get Observable<Results>
        let realm = try! Realm(configuration: data.config)
        let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
            .share()

        // bind to table view
        laps
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: bag)

        // bind to vc title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .bind(to: rx.title)
            .disposed(by: bag)

        // react on cell taps
        tableView.rx.modelSelected(Lap.self)
            .map({ $0.text })
            .bind(to: rx.title)
            .disposed(by: bag)

        tableView.rx.itemDeleted.asObservable()
            .subscribe(onNext: { indexPath in
                try! realm.write {
                    let laps = realm.objects(Timer.self).first!.laps
                    realm.delete(laps[indexPath.row])
                }
            })
            .disposed(by: bag)

        // demo inserting and deleting data
        data.start()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        if editing {
            data.stop()
        } else {
            data.start()
        }
    }
}
