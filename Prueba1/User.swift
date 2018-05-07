//
//  User.swift
//  Prueba1
//
//  Created by SARA CORREAS GORDITO on 17/4/18.
//  Copyright © 2018 SARA CORREAS GORDITO. All rights reserved.
//

import UIKit

class User: NSObject {
    var sID:String?
    var sAvatar:String?
    var sBio:String?
    var sEmail:String?
    var sName:String?
    var sUsername:String?
    var dbLatitude:Double?
    var dbLongitude:Double?
    
    func setMap(valores:[String:Any]) {
        sAvatar = valores["Avatar"] as? String
        sBio = valores["Bio"] as? String
        sEmail = valores["Email"] as? String
        sName = valores["Name"] as? String
        sUsername = valores["Username"] as? String
        dbLatitude = valores["Latitude"] as? Double
        dbLongitude = valores["Longitude"] as? Double
    }
    
    func getMap() -> [String:Any] {
        var mapTemp:[String:Any] = [:]
        mapTemp["Avatar"] = sAvatar as Any
        mapTemp["Bio"] = sBio as Any
        mapTemp["Email"] = sEmail as Any
        mapTemp["Name"] = sName as Any
        mapTemp["Username"] = sUsername as Any
        mapTemp["Latitude"] = dbLatitude as Any
        mapTemp["Longitude"] = dbLongitude as Any
        return mapTemp
    }
}
