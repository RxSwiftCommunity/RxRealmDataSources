//
//  DataRandomizer.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/11/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift

extension Int {
    public func random() -> Int {
        return Int(arc4random_uniform(UInt32(self)))
    }
}

class DataRandomizer {

    static var realmConfig: Realm.Configuration = {
        var config = Realm.Configuration.defaultConfiguration
        config.inMemoryIdentifier = "Memory"
        let realm = try! Realm(configuration: config)
        try! realm.write {
            realm.add(Timer())
        }
        return config
    }()

    private lazy var realm: Realm = {
        return try! Realm(configuration: DataRandomizer.realmConfig)
    }()

    private func insertRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            //timerLaps.insert(Lap(), at: index)
            timerLaps.append(Lap())
            print("insert at [\(index)]")
        }
        delay(seconds: 0.5, completion: insertRow)
    }

    private func updateRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            timerLaps[index].text = ">" + timerLaps[index].text
            print("update at [\(index)]")
        }
        delay(seconds: 0.5, completion: updateRow)
    }

    private func deleteRow() {
        try! realm.write {
            let timerLaps = realm.objects(Timer.self).first!.laps
            let index = timerLaps.count.random()
            timerLaps.remove(objectAtIndex: index)
            print("delete from [\(index)]")
        }
        delay(seconds: 1.0, completion: deleteRow)
    }

    func start() {
        // insert some laps
        insertRow()
        delay(seconds: 0.5, completion: updateRow)
        delay(seconds: 1.0, completion: deleteRow)
    }
}
