//
//  C.swift
//  Physics Ball
//
//  Created by Matthew Chiang on 5/29/19.
//  Copyright © 2019 Matthew Chiang. All rights reserved.
//

import Foundation

enum CollisionCategory: Int {
    case none = 0
    case ball = 1
    case hoop = 2
    case score = 4
    case floor = 8
}
