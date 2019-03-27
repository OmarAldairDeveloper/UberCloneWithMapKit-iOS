//
//  RiderViewController.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import MapKit

class RiderViewController: UIViewController {

    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callUberButton: UIButton!
    
    var locationManager = CLLocationManager()
    var riderLocation = CLLocationCoordinate2D()
    
    var hasBeenUberCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email{
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                
                // Si hay una petición del usuario logueado entonces:
                self.hasBeenUberCalled = true
                self.callUberButton.setTitle("Cancelar taxi", for: .normal)
                
                Database.database().reference().child("RideRequests").removeAllObservers()
            }
        }
        
        
        
        
        
    }
    

    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func callUberAction(_ sender: UIButton) {
        
        if let email = Auth.auth().currentUser?.email{
            
            if hasBeenUberCalled{
                // Si ya lo ha llamado entonces poder borrar la petición
                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapshot) in
                    
                    
                    self.hasBeenUberCalled = false
                    self.callUberButton.setTitle("Llamar a un taxi", for: .normal)
                    
                    snapshot.ref.removeValue()
                    Database.database().reference().child("RideRequests").removeAllObservers()
                    
                    
                }
                
            }else{
                // Sino pedirlo
                
                self.hasBeenUberCalled = true
                self.callUberButton.setTitle("Cancelar taxi", for: .normal)
                
                let data: [String:Any] = ["email": email, "lat": riderLocation.latitude, "lon": riderLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(data)
            }
 
        }

    }
    

}


extension RiderViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate{
            
            // Localización del usuario
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            // Asignar localización de usuario
            riderLocation = center
            
            // Región rectangular de la localización y su largo y ancho de la región es 0.01
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            
            
            
            // Annotations
            map.removeAnnotations(map.annotations) // Remover todas las anotaciones para que se muestre nadamas la nueva
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Tu localización actual"
            map.addAnnotation(annotation)
            
        
        }
        
        
    }
    
}
