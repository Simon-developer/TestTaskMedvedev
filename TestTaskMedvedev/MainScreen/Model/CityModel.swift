//
//  CityModel.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import UIKit

struct City {
    var name: String
    var lat:  Double
    var lng:  Double
    
    var temperatures:        [[String: Double]]
    var feelTemperatures:    [[String: Double]]
    var weatherDescriptions: [String]
    var weatherIcons:        [UIImage]
    
    init(name: String,
         lat: Double,
         lng: Double,
         temps: [[String: Double]],
         feels: [[String: Double]],
         descriptions: [String],
         icons: [String]) {
        
        self.name = name
        self.lat = lat
        self.lng = lng
        self.temperatures = temps
        self.feelTemperatures = feels
        self.weatherDescriptions = descriptions
        
        self.weatherIcons = []
        
        for imageName in icons {
            if let image = UIImage(named: imageName) {
                self.weatherIcons.append(image)
            } else {
                guard let extraImage = UIImage(named: "cancel") else { fatalError("ERROR: Could not find cancel image in bundle") }
                self.weatherIcons.append(extraImage)
            }
        }
    }
    
}
