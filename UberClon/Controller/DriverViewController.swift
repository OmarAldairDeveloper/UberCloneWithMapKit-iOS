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
import MapKit



class DriverViewController: UICollectionViewController {
    
    var requests = [Request]()
    var locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
        
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
    
    
    
    
    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
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
        
        
        // Calcular distancia entre conductor y pasajero
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: request.lat, longitude: request.lon)
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundDistance = round(distance * 100) / 100
        
        cell.emailLabel.text = request.email
        cell.riderDistance.text = "\(roundDistance) km de distancia"
    
        return cell
    }

   

}


extension DriverViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate{
            // Obtener localización del conductor
            driverLocation = coord
        }
    }
}
