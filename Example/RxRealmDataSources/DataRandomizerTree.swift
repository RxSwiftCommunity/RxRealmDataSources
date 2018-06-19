//
//  DataRandomizerTree.swift
//  RxRealmDataSources
//
//  Created by Sergiy Vynnychenko on 4/24/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

class DataRandomizerTree {
    
    private let bag = DisposeBag()
    private let rootItem = TreeItem()
    
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
        try! realm.write {
            rootItem.title = "1"
            rootItem.time = 40
            realm.add(rootItem)
        }
    }
    
    private func insertChild() {
        let items = realm.objects(TreeItem.self)
        let index = items.count.random()
        let parent = items[index]
        let newItem = TreeItem()
        
        
        try! realm.write {
            newItem.title = "\(parent.title)+1"
            newItem.time = parent.time * 3.14
            newItem.parent = parent
            
            realm.add(newItem)
            print("tree item: added child for \(parent.title)]")
        }
    }
    
    private func updateItem() {
        let items = realm.objects(TreeItem.self)
        let index = items.count.random()
        let item = items[index]
        
        try! realm.write {
            print("tree item: going to update \(item.title)")
            item.title += "+"
        }
    }
    
    private func deleteItem() {
        let items = realm.objects(TreeItem.self).filter("children.@count = 0")
        if items.count > 0 {
            let item = items[items.count.random()]
            
            let parentTitle = item.parent?.title ?? "root item"
            print("tree item: going to delete \(item.title) of parent \(parentTitle)")
            
            try! realm.write {
                realm.delete(item)
            }
        }
    }
    
    func start() {
        // insert some laps
        Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.insertChild()
            })
            .disposed(by: bag)
        
        Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.updateItem()
            })
            .disposed(by: bag)
        
        Observable<Int>.interval(2.0, scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] _ in
                self?.deleteItem()
            })
            .disposed(by: bag)
    }
}

