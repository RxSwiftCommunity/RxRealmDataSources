//
//  OutlineViewController.swift
//  RxRealmDataSources_MacExample
//
//  Created by Loki on 4/23/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Cocoa
import RealmSwift

import RxSwift
import RxCocoa
import RxRealm
import RxRealmDataSources

class OutlineViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    private let bag = DisposeBag()
    private let data = DataRandomizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dataSource = RxOutlineViewRealmDataSource<TreeItem>(cellIdentifier: "Title", cellType: NSTableCellView.self) {
            cell, columnId, treeItem  in
            
            guard let columnId = columnId else { return }
            
            switch columnId {
            case "Title":
                cell.textField!.stringValue = treeItem.title
            case "Time":
                cell.textField!.stringValue = "\(treeItem.time)"
            default:
                break
            }
        }
        dataSource.delegate = self
        
        let realm = try! Realm(configuration: data.config)
        let items = Observable.changeset(from: realm.objects(TreeItem.self))
            .share()
        
        items
            .bind(to: outlineView.rx.realmChanges(dataSource))
            .disposed(by: bag)
    }
    
    override func viewDidAppear() {
        let realm = try! Realm(configuration: data.config)
        
        let rootItem = TreeItem()
        rootItem.title = "Root Item"
        rootItem.time = Double(60)
        try! realm.write {
            realm.add(rootItem)
        }
        
        for i in 0...5 {
            let newItem = TreeItem()
            newItem.title = "Item \(i)"
            newItem.time = Double(i * 60)
            newItem.parent = rootItem
            
            try! realm.write {
                realm.add(newItem)
            }
        }
    }

}

extension OutlineViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 20.0
    }
}
