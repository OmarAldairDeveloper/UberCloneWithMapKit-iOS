//
//  DetailRequestViewController.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class DetailRequestViewController: UIViewController {
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptButton: UIButton!
    
    var riderEmail = ""
    var riderLocation = CLLocationCoordinate2D()
    var driverLocation = CLLocationCoordinate2D()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Agregar región
        let region = MKCoordinateRegion(center: riderLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
        
        // Agregar Annotation
        map.removeAnnotations(map.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = riderLocation
        annotation.title = "Tu pasajero"
        map.addAnnotation(annotation)
        
    

    }
    
    
    
    @IBAction func acceptAction(_ sender: UIButton) {
        
        // Vamos a poner a la petición del usuario en la base de datos, 2 campos más que serán la localización del driver asignado
        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observe(.childAdded) { (snapshot) in
            
            
            snapshot.ref.updateChildValues(["driverLat":self.driverLocation.latitude, "driverLon":self.driverLocation.longitude])
            
            
            Database.database().reference().child("RideRequests").removeAllObservers()
        }
        
        
        
        // Vamos a abrir el mapa para que el conductor vaya hacía el pasaje
        let requestCLLocation = CLLocation(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
        
        
        CLGeocoder().reverseGeocodeLocation(requestCLLocation) { (placemarks, error) in
            
            if let placemarks = placemarks{
                if placemarks.count > 0{
                    let placeMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: placeMark)
                    mapItem.name = self.riderEmail
                    
                    // Modo manejo
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
        
    
        
        
        
        
    }
    

   

}
