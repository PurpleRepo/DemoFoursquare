//
//  RestaurantFinderViewController.swift
//  DemoFoursquare
//
//  Created by Andrew Bailey on 11/13/18.
//  Copyright © 2018 Andrew Bailey. All rights reserved.
//

import UIKit

class RestaurantFinderViewController: UIViewController {

    var dataSource_venuesArray = Array<Venue>()
    
    @IBOutlet weak var venueTableView: UITableView!
    @IBOutlet weak var venueLocationTextField: UITextField!
    @IBOutlet weak var venueTypeTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FourSquare - Restaurants"
        
        let tapper = UITapGestureRecognizer(target: self, action:#selector(hideKeyboard))
        tapper.cancelsTouchesInView = false
        view.addGestureRecognizer(tapper)
    }
    
    @objc func hideKeyboard(){
        view.endEditing(true)
    }
    
    @IBAction func pressedGoButton(_ sender: Any) {
        if let location = venueLocationTextField.text, let searchCriteria = venueTypeTextField.text {
            MBProgressHUD.showAdded(to: view, animated: true)
            FourSquareAPIHandler.shared.getVenues(around: location, for: searchCriteria) { (venuesArray, error) in
                
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
                
                if error == nil {
                    self.dataSource_venuesArray = venuesArray!
                    DispatchQueue.main.async {
                        self.venueTableView.reloadData()
                    }
                } else {
                    DispatchQueue.main.async {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        // Display Search Failed
                    }
                }
            }
        } else {
            // No text in either one of the text fields!
        }
    }
}

extension RestaurantFinderViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource_venuesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VenueCell") as! VenueTableViewCell
        
        cell.venueNameLabel.text = dataSource_venuesArray[indexPath.row].name
        cell.venueAddressLabel.text = dataSource_venuesArray[indexPath.row].address
        
        return cell
    }
}

extension RestaurantFinderViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == venueLocationTextField {
            venueTypeTextField.becomeFirstResponder()
        } else {
            pressedGoButton(textField)
        }
        
        return true
    }
}
