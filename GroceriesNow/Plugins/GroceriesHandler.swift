//
//  GroceriesHandler.swift
//  GroceriesNow
//
//  Created by evan on 3/29/18.
//  Copyright © 2018 evan. All rights reserved.
//

import Foundation
import FirebaseDatabase

protocol GroceriesController: class {
    func canOrderGroceries(delegateCalled: Bool)
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String)
    func updateDriversLocation(lat: Double, long: Double)
}

class GroceriesHandler{
    private static let _instance = GroceriesHandler()
    
    weak var delegate: GroceriesController?
    
    var customer = ""
    var driver = ""
    var customer_id = ""
    var orderPrice = ""
    
    static var Instance: GroceriesHandler{
        return _instance
    }
    
    func observeMessagesForCustomer(){
        //CUSTOMER ORDERED GROCERIES
        DBProvider.Instance.requestRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.customer{
                        self.customer_id = snapshot.key
                        self.delegate?.canOrderGroceries(delegateCalled: true)
                    }
                }
            }
        }
        //CUSTOMER CANCELLED GROCERIES
        DBProvider.Instance.requestRef.observe(DataEventType.childRemoved){ (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.customer{
                        self.delegate?.canOrderGroceries(delegateCalled: false)
                    }
                }
            }
        }
        
        //DRIVER ACCEPTS ORDER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childAdded) { (snapshot: DataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary{
                if let name = data[Constants.NAME] as? String{
                    if self.driver == "" {
                        self.driver = name
                        self.delegate?.driverAcceptedRequest(requestAccepted: true, driverName: name)
                    }
                }
            }
        }
        
        //DRIVER CANCELS ORDER
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childRemoved) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        self.driver = ""
                        self.delegate?.driverAcceptedRequest(requestAccepted: false, driverName: name)
                    }
                }
            }
        }
        
        //DRIVER UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(DataEventType.childChanged) { (snapshot: DataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String{
                    if name == self.driver{
                        if let lat = data[Constants.LATITUDE] as? Double{
                            if let long = data[Constants.LONGITUDE] as? Double{
                                self.delegate?.updateDriversLocation(lat: lat, long: long)
                            }
                        }
                    }
                }
                if let price = data[Constants.ORDER_PRICE] as? String{
                    self.orderPrice = price
                }
            }
        }
    }//observeMessagesForRider
    
    func requestGroceries(latitude: Double, longitude: Double, storeInfo: StoreLocation, orderDetails: String){
        let data: Dictionary<String, Any> = [Constants.NAME: self.customer, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude, Constants.STORE_NAME: storeInfo.name, Constants.ORDER_DETAILS: orderDetails]
        
        DBProvider.Instance.requestRef.childByAutoId().setValue(data)
    }//requestGroceries
    
    func cancelGroceries() {
        DBProvider.Instance.requestRef.child(self.customer_id).removeValue()
    }
    
    func getOrderPrice() -> String {
        return self.orderPrice
    }
    
    func updateCustomerLocation(lat: Double, long: Double){
        DBProvider.Instance.requestRef.child(self.customer_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long])
    }
    
}//class
