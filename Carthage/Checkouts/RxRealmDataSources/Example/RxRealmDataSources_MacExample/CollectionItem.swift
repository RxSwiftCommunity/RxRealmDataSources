//
//  CollectionItem.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa

class CollectionItem: NSCollectionViewItem {
    @IBOutlet var text: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
}
