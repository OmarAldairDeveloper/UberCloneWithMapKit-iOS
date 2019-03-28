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
    var driverLocation = CLLocationCoordinate2D()
    var hasBeenUberCalled = false
    var driverOnTheWay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()

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
                
                
                
                // Vamos a escuchar si ya hay conductor asignado a nuestro viaje, si es así entonces lo tenemos que mostrar en nuestro mapa también
                if let snapValue = snapshot.value as? [String: AnyObject]{
                    
                    if let driverLat = snapValue["driverLat"] as? Double, let driverLon = snapValue["driverLon"] as? Double{
                        
                        // Asignar localización del conductor
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                        
                        // Driver ya viene en camino
                        self.driverOnTheWay = true
                        self.displayDistanceBetweenDriverAndRider()
                        
                        
                        // Ir observando si cambia la posicion del conductor
                        Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: Auth.auth().currentUser?.email).observe(.childChanged) { (snapshot) in
                            
                            if let snapValue = snapshot.value as? [String: AnyObject]{
                                
                                if let driverLat = snapValue["driverLat"] as? Double, let driverLon = snapValue["driverLon"] as? Double{
                                    
                                    // Asignar localización del conductor
                                    self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                    
                                    // Driver ya viene en camino
                                    self.driverOnTheWay = true
                                    self.displayDistanceBetweenDriverAndRider()
                                    
                                    
                                }
                                
                            }
                            
                            
                        }
                        
                        
                    }
                    
                }
            }
        }
        
        
        
        
        
    }
    
    
    func displayDistanceBetweenDriverAndRider(){
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: riderLocation.latitude, longitude: riderLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundDistance = round(distance * 100) / 100
        callUberButton.setTitle("Tu conductor está a \(roundDistance) km de distancia", for: .normal)
        
        
        // Ahora el paso es mostrar a ambos en el mapa
        map.removeAnnotations(map.annotations)
        
        // Calcular la distancia de la cual se tiene que ver ambos, tanto el conductor como el pasajero
        let latDelta = abs(driverLocation.latitude - riderLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - riderLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: riderLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        // Annotation del pasajero
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = riderLocation
        riderAnnotation.title = "Tu punto de partida"
        map.addAnnotation(riderAnnotation)
        
        // Annotation del conductor
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Tu conductor"
        map.addAnnotation(driverAnnotation)
        
        
    }
    

    @IBAction func signOutAction(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func callUberAction(_ sender: UIButton) {
        
        // Si no hay un conductor asignado entonces podemos cancelar o pedir
        if !driverOnTheWay{
            
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
    
    func configureUI(){
        let mainYellow = UIColor(red: CGFloat(251)/255, green: CGFloat(192)/255, blue: CGFloat(45)/255, alpha: 1)
        
        callUberButton.backgroundColor = mainYellow
        callUberButton.layer.cornerRadius = 20
        self.navigationController?.navigationBar.barTintColor = mainYellow
        callUberButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
    }
    
    

}


extension RiderViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let coord = manager.location?.coordinate{
            
            // Localización del usuario
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            
            // Asignar localización de usuario
            riderLocation = center
            
           
            
            // Si ya se ha llamado a un Uber entonces esperar a llamar al conductor, sino insistir en mostrar nadamas la localización del usuario
            if hasBeenUberCalled{
                self.displayDistanceBetweenDriverAndRider()
            }else{
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
    
}
