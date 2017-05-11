//
//  CLBeaconRegionExt.swift
//  ibeacon_example_iOS_swift
//
//  Created by David Pugh on 11/05/2017.
//  Copyright © 2017 David Pugh. All rights reserved.
//

import Foundation
import CoreLocation

extension CLBeaconRegion{
    /**
     Alternative method of displaying region information
    */
    var strDescription:String{
        var str:String  = self.proximityUUID.uuidString
        if let major = self.major{ str = str + " Major: " + String(describing: major)}
        if let minor = self.minor{ str = str + " Minor: " + String(describing: minor)}
        str = str + " : " + self.identifier
        return str
    }}
