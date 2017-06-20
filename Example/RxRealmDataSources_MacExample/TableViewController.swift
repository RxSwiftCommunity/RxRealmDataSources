//
//  TableViewController.swift
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

class TableViewController: NSViewController {

    @IBOutlet var tableView: NSTableView!

    private let bag = DisposeBag()
    private let data = DataRandomizer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // create data source
        let dataSource = RxTableViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: NSTableCellView.self) {cell, row, lap in
            cell.textField!.stringValue = "\(lap.text)"
        }
        dataSource.delegate = self

        // RxRealm to get Observable<Results>
        let realm = try! Realm(configuration: data.config)
        let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
            .share()

        // bind to table view
        laps
            .bind(to: tableView.rx.realmChanges(dataSource))
            .addDisposableTo(bag)

        // bind to window title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .subscribe(onNext: {title in
                NSApp.windows.first?.title = title
            })
            .addDisposableTo(bag)

        // demo inserting and deleting data
        data.start()
    }
}

extension TableViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40.0
    }
}
