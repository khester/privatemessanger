//
//  User.swift
//  fdsfa
//
//  Created by Roman on 18.04.16.
//  Copyright © 2016 Roman. All rights reserved.
//

import Foundation
import RealmSwift

class User2: Object {
   dynamic var name = ""
   dynamic var phone = ""
   dynamic var id = 0
}

// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }

