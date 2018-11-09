//
//  AppDelegate.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/07/2016.
//  Copyright (c) RxSwiftCommunity. All rights reserved.
//

import UIKit

func delay(seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}
