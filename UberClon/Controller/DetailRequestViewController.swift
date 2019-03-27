//
//  DetailRequestViewController.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import MapKit

class DetailRequestViewController: UIViewController {
    
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var acceptButton: UIButton!
    
    var riderEmail = ""
    var riderLocation = CLLocationCoordinate2D()

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
        
        
        
        
    }
    

   

}
