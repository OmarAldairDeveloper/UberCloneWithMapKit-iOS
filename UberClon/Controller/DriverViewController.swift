//
//  DriverViewController.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase



class DriverViewController: UICollectionViewController {
    
    var requests = [Request]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Obtener todos los viajes
        Database.database().reference().child("RideRequests").observe(.childAdded) { (snapshot) in
            
            if let snapValue = snapshot.value as? [String: Any]{
                
                if let email = snapValue["email"] as? String, let lat = snapValue["lat"] as? Double, let lon = snapValue["lon"] as? Double{
                    
                    let request = Request(email: email, lat: lat, lon: lon)
                    self.requests.append(request)
                    self.collectionView.reloadData()
                }
                
            }
        }
        

      
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return requests.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RiderCell", for: indexPath) as! RiderCell
        
        let request = requests[indexPath.row]
        
        cell.emailLabel.text = request.email
    
        return cell
    }

   

}
