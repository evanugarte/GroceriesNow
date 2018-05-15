//
//  DBProvider.swift
//  GroceriesNow
//
//  Created by evan on 3/29/18.
//  Copyright © 2018 evan. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DBProvider{
    private static let _instance = DBProvider()
    
    static var Instance: DBProvider {
        return _instance
    }
    
    //allows us to reference data in firebase
    var dbRef: DatabaseReference{
        return Database.database().reference()
    }
    
    var ridersRef: DatabaseReference{
        //return name of person ordering groceries
        return dbRef.child(Constants.CUSTOMERS)
    }
    var requestRef: DatabaseReference{
        return dbRef.child(Constants.GROCERIES_REQUEST)
    }
    var requestAcceptedRef: DatabaseReference{
        return dbRef.child(Constants.GROCERIES_ACCEPTED)
    }
    
    func saveUser(withID: String, email: String, password: String){
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isCustomer: true]
        
        //adds user to database
        ridersRef.child(withID).child(Constants.DATA).setValue(data)
        
    }
    
} //class
