//
//  DataRandomizer.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/11/16.
//  Copyright © 2016 RxSwiftCommunity. All rights reserved.
//

import Foundation
import Dispatch
import RealmSwift
import RxSwift

extension Int {
    public func random() -> Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}

class DataRandomizer {

    private let bag = DisposeBag()

    lazy var config: Realm.Configuration = {
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = UUID().uuidString
        return config
    }()

    private lazy var realm: Realm = {
        let realm: Realm
        do {
            realm = try Realm(configuration: self.config)
            return realm
        }
        catch let e {
            print(e)
            fatalError()
        }
    }()

    init() {
        reset()
    }

    func reset() {
        try! realm.write {
            realm.deleteAll()
            realm.add(Timer())
        }
    }

    private func insertRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            timerLaps.insert(Lap(), at: index)
            print("insert at [\(index)]")
        }
    }

    private func updateRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            timerLaps[index].text = ">" + timerLaps[index].text
            print("update at [\(index)]")
        }
    }

    private func deleteRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            timerLaps.remove(objectAtIndex: index)
            print("delete from [\(index)]")
        }
    }

    func start() {
        // insert some laps
        Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.insertRow()
            })
            .addDisposableTo(bag)

        Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.updateRow()
            })
            .addDisposableTo(bag)

        Observable<Int>.interval(2.4, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.deleteRow()
            })
            .addDisposableTo(bag)
    }
}
