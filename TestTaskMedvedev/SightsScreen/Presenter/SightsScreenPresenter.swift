//
//  SightsScreenPresenter.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 08.11.2020.
//

import Foundation
import UIKit

protocol SightsScreenPresenterProtocol {
    init(view: SightsScreenViewProtocol, router: Routing, city:  City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?)
    
    func startConfigure()
    func openSoloSightScreen(sight: SightCD)
    func goBackToCityWeatherView()
}
class SightsScreenPresenter: SightsScreenPresenterProtocol {
    weak var view: SightsScreenViewProtocol?
    var router: Routing!
    var city: City!
    var webPlaces: [Sight]?
    var hardTypedPlaces: [SightCD]?
    
    required init(view: SightsScreenViewProtocol, router: Routing, city: City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?) {
        self.view = view
        self.router = router
        self.city = city
        self.webPlaces = webPlaces
        self.hardTypedPlaces = hardTypedPlaces
    }
    
    func startConfigure() {
        self.view?.layoutNavigationBar()
        
        if self.hardTypedPlaces != nil {
            self.view?.layoutHardTypedSights(preloaded: self.hardTypedPlaces!)
        } else if self.webPlaces != nil {
            self.view?.layoutWebSights(preloaded: self.webPlaces!)
        } else {
            print("Both are nil")
        }
    }
    
    
    func openSoloSightScreen(sight: SightCD) {
        self.router.soloSightViewController(sight: sight)
    }
    
    func goBackToCityWeatherView() {
        self.router.popLastViewController()
    }
    
    
}
