//
//  AppDelegate.swift
//  RxRealmDataSources_tvOSExample
//
//  Created by Oleksandr Vitruk on 07.03.18.
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

