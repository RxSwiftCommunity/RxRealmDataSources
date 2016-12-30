//
//  MenuViewController.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/30/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Cocoa

class MenuViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!

    let menuItems = ["Table Demo", "Collection Demo"]
    let targetNames = ["TableViewController", "CollectionViewController"]

    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.selectRowIndexes(IndexSet([0]), byExtendingSelection: false)
    }
}

extension MenuViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return 2
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 32.0
    }
}

extension MenuViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.make(withIdentifier: "MenuCell", owner: self) as! NSTableCellView
        cell.textField?.stringValue = menuItems[row]
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow > -1 {
            if let split = parent as? NSSplitViewController, split.childViewControllers.count > 1,
                let targetVC = storyboard?.instantiateController(withIdentifier: targetNames[tableView.selectedRow]) as? NSViewController {

                split.childViewControllers.replaceSubrange(1...1, with: [targetVC])
            }
        }
    }
}
