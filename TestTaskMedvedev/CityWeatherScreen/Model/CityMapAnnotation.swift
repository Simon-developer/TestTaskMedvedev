//
//  CityMapAnnotation.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 07.11.2020.
//

import Foundation
import MapKit

class CityMapAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    var title: String?
    
    var region: MKCoordinateRegion {
        let coordinateSpan = MKCoordinateSpan(latitudeDelta: 0.3, longitudeDelta: 0.3)
        return MKCoordinateRegion(center: coordinate, span: coordinateSpan)
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.coordinate = coordinate
        self.title = title
        
        super.init()
    }
}
