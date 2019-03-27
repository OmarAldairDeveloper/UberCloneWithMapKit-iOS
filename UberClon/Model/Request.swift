//
//  Request.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import Foundation

class Request{
    
    var email: String
    var lat: Double
    var lon: Double
    
    init(email: String, lat: Double, lon: Double) {
        self.email = email
        self.lat = lat
        self.lon = lon
    }
}
