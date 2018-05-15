//
//  StoreLocation.swift
//  GroceriesNow
//
//  Created by evan on 4/1/18.
//  Copyright © 2018 evan. All rights reserved.
//

import Foundation

class StoreLocation {
    
    var name = ""
    var latitude = 0.0
    var longitude = 0.0
    
    init(name: String, lat: Double, long: Double) {
        self.name = name
        self.latitude = lat
        self.longitude = long
    }
    
}

