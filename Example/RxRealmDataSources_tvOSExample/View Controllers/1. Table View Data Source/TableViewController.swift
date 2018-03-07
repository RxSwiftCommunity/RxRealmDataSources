//
//  TableViewController.swift
//  RxRealmDataSources_Example
//
//  Created by Oleksandr Vitruk on 07.03.18.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit
import RealmSwift

import RxSwift
import RxCocoa
import RxRealm
import RxRealmDataSources

class TableViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
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
        let realm = try! Realm(configuration: data.config)
        let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
            .share()
        
        // bind to table view
        laps
            .bind(to: tableView.rx.realmChanges(dataSource))
            .disposed(by: bag)
        
        // bind to vc title
        laps
            .map {results, _ in
                return "\(results.count) laps"
            }
            .bind(to: titleLabel.rx.text)
            .disposed(by: bag)
        
        // react on cell taps
        tableView.rx.realmModelSelected(Lap.self)
            .map({ $0.text })
            .bind(to: titleLabel.rx.text)
            .disposed(by: bag)
        
        // demo inserting and deleting data
        data.start()
    }
}
