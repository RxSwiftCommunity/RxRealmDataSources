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
    
    private let bag = DisposeBag()
    private let data = DataRandomizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
/*
extension TableViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 40.0
    }
}*/
