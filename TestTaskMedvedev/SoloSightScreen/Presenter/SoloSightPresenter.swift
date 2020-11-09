//
//  SoloSightPresenter.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 09.11.2020.
//

import Foundation
import UIKit

protocol SoloSightPresenterProtocol {
    init(view: SoloSightViewProtocol, router: Routing, sight: SightCD)
    
    func startConfigure()

    func goBackToSightsScreen()
}

class SoloSightPresenter: SoloSightPresenterProtocol {
    
    weak var view: SoloSightViewProtocol?
    var router: Routing!
    var sight: SightCD!
    
    var imagesArray: [UIImage] = []
    
    required init(view: SoloSightViewProtocol, router: Routing, sight: SightCD) {
        self.view = view
        self.router = router
        self.sight = sight
    }
    
    func startConfigure() {
        self.view?.layoutNavigationBar(sightTitle: self.sight.name!)
        loadImages()
        
    }
    func loadImages() {
        for imageURL in self.sight.images! {
            let session = URLSession(configuration: .default)
            
            session.dataTask(with: imageURL) { (data, response, error) in
                if error == nil &&  data != nil {
                    if let _ = response as? HTTPURLResponse {
                        if let imageData = data {
                            
                            let image = UIImage(data: imageData)
                            DispatchQueue.main.async {
                                if image != nil {
                                    self.imagesArray.append(image!)
                                    if let geoCoords = self.sight.geo {
                                        self.view?.layoutSoloView(sentImages: self.imagesArray, sightTitle: self.sight.name!, sightDescFull: self.sight.descfull!, sightLatitude: geoCoords["lat"]!, sightLongitude: geoCoords["lng"]!)
                                    }
                                }
                            }
                            
                        } else {
                            print("ERROR: Couldn't get image")
                        }
                    } else {
                        print("ERROR: Couldn't get image")
                    }
                } else if let foundError = error {
                    print("ERROR: during picture download \(foundError.localizedDescription)")
                }
            }.resume()
        }
        
    }
    

    func goBackToSightsScreen() {
        self.router.popLastViewController()
    }
}
