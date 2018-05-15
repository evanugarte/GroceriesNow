//
//  MenuVC.swift
//  GroceriesNow
//
//  Created by evan on 3/31/18.
//  Copyright © 2018 evan. All rights reserved.
//

import UIKit
import Foundation

class MenuVC: UIViewController{
    
    private let CUSTOMER_SEGUE = "UserVC"
    private var canOrderGroceries = Bool();
    
    var orderDetails = ""
    
    let walmartLocation = StoreLocation(name: "Walmart", lat: 37.322119, long: -121.973251)
    let safewayLocation = StoreLocation(name: "Safeway", lat: 37.336162, long: -122.034762)
    let wholeFoodsLocation = StoreLocation(name: "Whole Foods", lat: 37.323174, long:-122.039508)
    
    @IBOutlet weak var walmartPhoto: UIImageView!
    @IBOutlet weak var safewayPhoto: UIImageView!
    @IBOutlet weak var wholeFoodsPhoto: UIImageView!
  
    var storeID = StoreLocation(name: "", lat: 0.0, long: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        canOrderGroceries = true
    }
    
    @IBAction func walmartTapped(_ sender: Any) {
        storeID = walmartLocation
        segueToCustomerVC()
    }
 
    @IBAction func safewayTapped(_ sender: Any) {
        storeID = safewayLocation
        segueToCustomerVC()
    }
    
    @IBAction func wholeFoodsTapped(_ sender: Any) {
        storeID = wholeFoodsLocation
        segueToCustomerVC()
    }

    @IBAction func orderDetails(_ sender: Any) {
        openOrderAlert()
    }
    @IBAction func logOut(_ sender: Any) {
        if AuthProvider.Instance.logOut(){
            
            if !canOrderGroceries {
                GroceriesHandler.Instance.cancelGroceries()
            }
            dismiss(animated: true, completion: nil)
            //go back to signInVC if logged out
            //dismiss(animated: true, completion: nil)
        }else{
            //tell user of an error from trying to log out
            alertTheUser(title: "Problem Logging out", message: "Unable to logout at the moment, please try again later")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let customerViewController = segue.destination as! CustomerVC
        
        customerViewController.orderDetails = orderDetails
        customerViewController.storeID = storeID
    }
    
    func segueToCustomerVC(){
        canOrderGroceries = false
        if orderDetails != "" {
            self.performSegue(withIdentifier: self.CUSTOMER_SEGUE, sender: nil)
        }else{
            alertTheUser(title: "No Order Details Specified", message: "Please specify your desired groceries from the store.")
        }
    }
    
    func openOrderAlert() {
        
        //Create Alert Controller
        let alert9 = UIAlertController (title: "Order Details:", message: nil, preferredStyle: UIAlertControllerStyle.alert)
      
    //Create Cancel Action
        let cancel9 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    
        alert9.addAction(cancel9)

        //Create OK Action
        let ok9 = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action: UIAlertAction) in print("OK")
            let textfield = alert9.textFields?[0]
            self.orderDetails = (textfield?.text!)!
        }
        //TEXT FIELD NOTIFICATION
        alert9.addAction(ok9)
    
        //Add Text Field
        alert9.addTextField { (textfield: UITextField) in
            textfield.text = self.orderDetails
        
            textfield.placeholder = "Enter Details Here"
        }
    
        //Present Alert Controller
        self.present(alert9, animated:true, completion: nil)
    }
    //END TEXT FIELD NOTIFCATION
    //create alert notification
    private func alertTheUser(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
