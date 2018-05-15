//
//  UserVC.swift
//  GroceriesNow
//
//  Created by evan on 3/28/18.
//  Copyright © 2018 evan. All rights reserved.
//

import UIKit
import MapKit

class CustomerVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, GroceriesController{
    
    private let SIGNIN_SEGUE = "SignInVC"
    private let MENU_SEGUE = "MenuVC"
    
    @IBOutlet weak var myMap: MKMapView!
    @IBOutlet weak var orderGroceriesBtn: UIButton!
    @IBOutlet weak var getPriceBtn: UIButton!
    
    private var locationManager = CLLocationManager()
    private var userLocation: CLLocationCoordinate2D?
    private var driverLocation: CLLocationCoordinate2D?
    
    //variable to remember what store was chosen by customer
    var storeID = StoreLocation(name: "", lat: 0.0, long: 0.0)
    var orderDetails = ""
    
    private var timer = Timer()
    
    private var canOrderGroceries = true
    private var customerCancelledRequest = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getPriceBtn.isHidden = true
        
        //extra code added
        myMap.delegate = self
        myMap.showsScale = true
        myMap.showsPointsOfInterest = true
        myMap.showsUserLocation = true
        //end extra code added
        
        //request new permissions
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        //if agreed to share location
        if CLLocationManager.locationServicesEnabled(){
            initializeLocationManager()
        }
        
        
        GroceriesHandler.Instance.delegate = self
        GroceriesHandler.Instance.observeMessagesForCustomer()
        
    }
    
    private func initializeLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //if we have coordinates from the manager, create user location
        if let location = locationManager.location?.coordinate{
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            myMap.setRegion(region, animated: true)
            //remove any old annotations from previous runs
            myMap.removeAnnotations(myMap.annotations)
            
            if driverLocation != nil{
                if !canOrderGroceries{
                    let driverAnnotation = MKPointAnnotation()
                    driverAnnotation.coordinate = driverLocation!
                    driverAnnotation.title = "Driver Location"
                    myMap.addAnnotation(driverAnnotation)
                }
            }
            
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = userLocation!
//            annotation.title = "Driver's Location"
//            myMap.addAnnotation(annotation)
        }
    }
    
    @objc func updateCustomerLocation(){
        GroceriesHandler.Instance.updateCustomerLocation(lat: userLocation!.latitude, long: userLocation!.longitude)
    }
    
    func canOrderGroceries(delegateCalled: Bool) {
        if delegateCalled{
            orderGroceriesBtn.setTitle("Cancel Order", for: UIControlState.normal)
            canOrderGroceries = false;
        }else{
            orderGroceriesBtn.setTitle("Order My Groceries", for: UIControlState.normal)
            canOrderGroceries = true
        }
    }
    
    func driverAcceptedRequest(requestAccepted: Bool, driverName: String) {
        
        if !customerCancelledRequest{
            if requestAccepted{
                alertTheUser(title: "Grocery Order Accepted", message: "\(driverName) Accepted Your Grocery Request")
                getPriceBtn.isHidden = false
            }else{
                GroceriesHandler.Instance.cancelGroceries()
                timer.invalidate()
                alertTheUser(title: "Order Cancelled", message: "\(driverName) Cancelled Your Grocery Request")
                getPriceBtn.isHidden = true
            }
        }
        customerCancelledRequest = false
    }

    @IBAction func orderMyGroceries(_ sender: AnyObject) {
        //avoid a crash by checking if location has value
        if userLocation != nil{
            if canOrderGroceries{
                GroceriesHandler.Instance.requestGroceries(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude), storeInfo: storeID, orderDetails: orderDetails)
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(CustomerVC.updateCustomerLocation), userInfo: nil, repeats: true)
            }else{
                customerCancelledRequest = true
                GroceriesHandler.Instance.cancelGroceries()
                timer.invalidate()
            }
        }
    }
    
    @IBAction func getOrderPrice(_ sender: Any) {
        let price = GroceriesHandler.Instance.getOrderPrice()
        if price != ""{
        alertTheUser(title: "Order Price", message: "Your order is \(price)")
        }else{
            alertTheUser(title: "No Order Price", message: "Your driver hasn't specified a price yet.")
        }
    }
    
    func updateDriversLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
    @IBAction func logout(_ sender: AnyObject){
        if AuthProvider.Instance.logOut(){
            
            if !canOrderGroceries {
                GroceriesHandler.Instance.cancelGroceries()
                timer.invalidate()
            }
            self.performSegue(withIdentifier: self.SIGNIN_SEGUE, sender: nil)
            //dismiss(animated: true, completion: nil)
            //go back to signInVC if logged out
            //dismiss(animated: true, completion: nil)
        }else{
            //tell user of an error from trying to log out
            alertTheUser(title: "Problem Logging out", message: "Unable to logout at the moment, please try again later")
        }
    }

    @IBAction func changeOrder(_ sender: Any) {
        if !canOrderGroceries{
            GroceriesHandler.Instance.cancelGroceries()
            customerCancelledRequest = true
            timer.invalidate()
        }
        self.performSegue(withIdentifier: self.MENU_SEGUE, sender: nil)
    }
    
    private func alertTheUser(title: String, message: String){
        //make alert notifcation with passed title, message, and an "OK" button
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}//class
