//
//  Timer.swift
//  RxRealmDataSources
//
//  Created by Marin Todorov on 12/8/16.
//  Copyright © 2016 RxSwiftCommunity. All rights reserved.
//

import Foundation
import RealmSwift

class Timer: Object {
    let laps = List<Lap>()
}
