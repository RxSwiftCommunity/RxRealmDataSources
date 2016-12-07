//
//  ViewController.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/07/2016.
//  Copyright (c) 2016 Marin Todorov. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxRealmDataSources

class Lap: Object {
    dynamic var text = Date().description
}

func delay(seconds: Double, completion: @escaping ()->Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    let bag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // load laps from Realm
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = "Memory"

        let realm = try! Realm(configuration: config)
        let results = realm.objects(Lap.self)


        // create data source
        let dataSource = RxTableViewRealmDataSource<Lap>(cellIdentifier: "Cell") {ds, tv, ip, lap in
            let cell = tv.dequeueReusableCell(withIdentifier: ds.cellIdentifier, for: ip) as! PersonCell
            cell.customLabel.text = "\(ip.row). \(lap.text)"
            return cell
        }

        // RxRealm to get Observable<Results>
        let laps = Observable.changesetFrom(results)
            .share()

        // bind to table view
        laps
            .bindTo(tableView.rx.realmChanges(dataSource))
            .addDisposableTo(bag)

        // bind to vc title
        laps
            .map { results, _ in
                return "\(results.count) laps"
            }
            .bindTo(rx.title)
            .addDisposableTo(bag)

        // insert some laps
        for i in 0...200 {
            delay(seconds: Double(i)/2, completion: {
                let realm = try! Realm(configuration: config)
                try! realm.write {
                    realm.add(Lap())
                }
            })
        }
    }
}

