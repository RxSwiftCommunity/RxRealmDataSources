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

        // create data source
        let dataSource = RxTableViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: PersonCell.self) {cell, ip, lap in
            cell.customLabel.text = "\(ip.row). \(lap.text)"
        }

        // RxRealm to get Observable<Results>
        let realm = try! Realm(configuration: DataRandomizer.realmConfig)
        let laps = Observable.changesetFrom(realm.objects(Timer.self).first!.laps)
            .share()

        // bind to table view
        laps
            .bindTo(tableView.rx.realmChanges(dataSource))
            .addDisposableTo(bag)

        // bind to vc title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .bindTo(rx.title)
            .addDisposableTo(bag)

        // demo inserting and deleting data
        data.start()
    }
}

