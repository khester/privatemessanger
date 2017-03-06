//
//  User.swift
//  fdsfa
//
//  Created by Roman on 04.03.16.
//  Copyright © 2016 Roman. All rights reserved.
//



import UIKit

struct User {
    var firstName: String?
    var lastName: String?
    var id: Int
    
    init(firstName: String?, lastName: String?, id: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.id = id    }
}

