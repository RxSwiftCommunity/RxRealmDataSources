# RxRealmDataSources

[![Version](https://img.shields.io/cocoapods/v/RxRealmDataSources.svg?style=flat)](http://cocoapods.org/pods/RxRealmDataSources)
[![License](https://img.shields.io/cocoapods/l/RxRealmDataSources.svg?style=flat)](http://cocoapods.org/pods/RxRealmDataSources)
[![Platform](https://img.shields.io/cocoapods/p/RxRealmDataSources.svg?style=flat)](http://cocoapods.org/pods/RxRealmDataSources)

This library is currently WIP.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

This library is a light data source implementation for `RxRealm`. It allows you to easily bind an Observable sequence of Realm objects to a table or a collection view. The library is both iOS and macOS compatible.

### Binding to a table view

Check out the included demo app to see this in action.

```swift
// create data source
let dataSource = RxTableViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: PersonCell.self) {cell, ip, lap in
    cell.customLabel.text = "\(ip.row). \(lap.text)"
}

// RxRealm to get Observable<Results>
let realm = try! Realm(configuration: DataRandomizer.realmConfig)
let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
    .share()

// bind to table view
laps
    .bindTo(tableView.rx.realmChanges(dataSource))
    .disposed(by: bag)
```

### Binding to a collection view

Check out the included demo app to see this in action.

```swift
// create data source
let dataSource = RxCollectionViewRealmDataSource<Lap>(cellIdentifier: "Cell", cellType: LapCollectionCell.self) {cell, ip, lap in
    cell.customLabel.text = "\(ip.row). \(lap.text)"
}

// RxRealm to get Observable<Results>
let realm = try! Realm(configuration: DataRandomizer.realmConfig)
let laps = Observable.changeset(from: realm.objects(Timer.self).first!.laps)
    .share()

// bind to collection view
laps
    .bindTo(collectionView.rx.realmChanges(dataSource))
    .disposed(by: bag)
```

### Reacting to cell taps

The library adds an extension to table views and collection views, allowing you to easily subscribe to the cell selected delegate event. Here's a snippet from the example demo app:

```swift
tableView.rx.realmModelSelected(Lap.self)
  .map({ $0.text })
  .bind(to: rx.title)
  .disposed(by: bag)
```

## Installation

This library depends on __RxSwift__,  __RealmSwift__, and __RxRealm__.

#### CocoaPods
RxRealm is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "RxRealmDataSources"
```

## TODO

* Test add platforms and add compatibility for the pod

## License

This library belongs to _RxSwiftCommunity_. It has been created by Marin Todorov.

RxRealm is available under the MIT license. See the LICENSE file for more info.
