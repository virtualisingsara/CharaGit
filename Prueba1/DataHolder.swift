//
//  DataHolder.swift
//  Prueba1
//
//  Created by SARA CORREAS GORDITO on 10/4/18.
//  Copyright © 2018 SARA CORREAS GORDITO. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import MapKit
import CoreLocation
import Foundation
import Octokit

class DataHolder: NSObject {
    static let sharedInstance:DataHolder = DataHolder()
    var firestoreDB:Firestore?
    var firStorage:Storage?
    var firStorageRef:StorageReference?
    var locationAdmin:LocationAdmin?
    var myUser:User = User()
    var arRepos:[Repo] = []
    var arUsers:[User] = []
    var pines:[String:MKAnnotation]? = [:]
    var tokenValue = "";
    var nRepos:Int?
    var nFollowers:Int?
    
    func initFireBase() {
        FirebaseApp.configure()
        firestoreDB = Firestore.firestore()
        firStorage = Storage.storage()
        firStorageRef = firStorage?.reference()
    }
    
    func initLocationAdmin() {
        locationAdmin = LocationAdmin()
    }
    
    func downloadRepos(delegate:DataHolderDelegate) {
        var blEnd:Bool = false
        DataHolder.sharedInstance.firestoreDB?.collection("Repos").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                blEnd = false
                delegate.DHDdownloadReposComplete!(blEnd: false)
            } else {
                for document in querySnapshot!.documents {
                    let repo:Repo = Repo()
                    repo.sID = document.documentID
                    repo.setMap(valores: document.data())
                    self.arRepos.append(repo)
                    print("\(document.documentID) => \(document.data())")
                }
                print("Nº repos: ",self.arRepos.count)
                blEnd = true
                delegate.DHDdownloadReposComplete!(blEnd: true)
            }
        }
    }
    
    func downloadPines(map:MKMapView, delegate:DataHolderDelegate) {
        var myMap = map
        var blEnd:Bool = false
        DataHolder.sharedInstance.firestoreDB?.collection("Users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                blEnd = false
                //delegate.DHDdownloadPinesComplete!(blEnd: false)
            } else {
                for document in querySnapshot!.documents {
                    let user:User = User()
                    user.sID = document.documentID
                    user.setMap(valores: document.data())
                    self.arUsers.append(user)
                    print("\(document.documentID) => \(document.data())")
                    
                    self.addPin(myTitle: user.sUsername!, latitude: user.dbLatitude!, longitude: user.dbLongitude!, map: myMap)
                }
                blEnd = true
                //delegate.DHDdownloadPinesComplete!(blEnd: true)
            }
        }
    }
    
    func addPin(myTitle:String, latitude lat:Double, longitude lon:Double, map:MKMapView) {
        var myAnnotation:MKPointAnnotation = MKPointAnnotation()
        
        if pines![myTitle] == nil {
            
        } else {
            myAnnotation = pines?[myTitle] as! MKPointAnnotation
        }
        
        myAnnotation.coordinate.latitude = lat
        myAnnotation.coordinate.longitude = lon
        myAnnotation.title = myTitle
        pines?[myTitle] = myAnnotation
        map.addAnnotation(myAnnotation)
    }
    
    func login(email: String, pass: String, delegate:DataHolderDelegate){
        var blEnd:Bool = false
        Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
            if (user != nil) {
                print("Te registraste con user ID: " + (user?.uid)!)
                let refUser = DataHolder.sharedInstance.firestoreDB?.collection("Users").document((user?.uid)!)
                refUser?.getDocument { (document, error) in
                    if document != nil {
                        DataHolder.sharedInstance.myUser.setMap(valores: (document?.data())!)
                        print("Username: ",DataHolder.sharedInstance.myUser.sUsername)
                        //self.performSegue(withIdentifier: "trLogin", sender: self)
                        blEnd = true
                        delegate.DHDloginComplete!(blEnd: true)
                    } else {
                        print(error!)
                    }
                }
            } else {
                print (error!)
            }
        }
        
    }
    
    func signin(email: String, pass: String, repass: String, delegate:DataHolderDelegate){
        var blEnd:Bool = false
        DataHolder.sharedInstance.myUser.sEmail = email
        DataHolder.sharedInstance.myUser.dbLatitude = 0
        DataHolder.sharedInstance.myUser.dbLongitude = 0
        DataHolder.sharedInstance.myUser.iXP = 0
        DataHolder.sharedInstance.myUser.nFollowers = 0
        DataHolder.sharedInstance.myUser.nRepos = 0
        DataHolder.sharedInstance.myUser.sAvatar = "none"
        DataHolder.sharedInstance.myUser.sBio =  "none"
        DataHolder.sharedInstance.myUser.sImage =  "https://firebasestorage.googleapis.com/v0/b/charagit-e5789.appspot.com/o/logo.png?alt=media&token=5b357f09-92e7-4f36-b4f9-1b0a7cbc9208"
        DataHolder.sharedInstance.myUser.sName =  "none"
        DataHolder.sharedInstance.myUser.sTitle =  "none"
        DataHolder.sharedInstance.myUser.sUsername = email
        if pass ==  repass {
            Auth.auth().createUser(withEmail: email, password: pass) { (user, error) in
                if (user != nil) {
                    print("Te registraste con user ID: " + (user?.uid)!)
                    // Add a new document with a generated ID
                    DataHolder.sharedInstance.firestoreDB?.collection("Users").document((user?.uid)!).setData(DataHolder.sharedInstance.myUser.getMap()) { err in
                        if let err = err {
                            print("Error adding document: \(err)")
                        } else {
                            print("Document added with ID: ")
                        }
                    }
                    blEnd = true
                    delegate.DHDregisterComplete!(blEnd: true)
                    //self.performSegue(withIdentifier: "trSignin", sender: self)
                } else {
                    print (error!)
                }
            }
        }
    }
}

@objc protocol DataHolderDelegate {
    @objc optional func DHDdownloadReposComplete(blEnd:Bool)
    @objc optional func DHDdownloadPinesComplete(blEnd:Bool)
    @objc optional func DHDloginComplete(blEnd:Bool)
    @objc optional func DHDregisterComplete(blEnd:Bool)
}
