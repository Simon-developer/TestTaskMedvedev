//
//  Builder.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import UIKit

protocol Builder {
    func createMainScreen(router: Routing) -> UIViewController
    func createCityWeatherScreen(router: Routing, city: City) -> UIViewController
    func createSightsScreen(router: Routing, city: City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?) -> UIViewController
    func createSoloSightScreen(router: Routing, sight: SightCD) -> UIViewController
}

class ScreenBuilder: Builder {
    /// Возвращает ViewController главного экрана приложения
    func createMainScreen(router: Routing) -> UIViewController {
        // Инициализируем и делаем иньекции для
        // взаимосвязей модулей view и presenter
        let view = MainViewController()
        let presenter = MainPresenter(view: view, router: router)
        
        view.presenter = presenter
        
        return view
    }
    /// Возвращает экран с погодой в городе
    func createCityWeatherScreen(router: Routing, city: City) -> UIViewController {
        let view = CityWeatherViewController()
        let presenter = CityWeatherPresenter(view: view, router: router, city: city)
        
        view.presenter = presenter
        
        return view
    }
    func createSightsScreen(router: Routing, city: City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?) -> UIViewController {
        let view = SightsScreenViewController()
        let presenter = SightsScreenPresenter(view: view,
                                              router: router,
                                              city: city,
                                              webPlaces: webPlaces,
                                              hardTypedPlaces: hardTypedPlaces)
        
        view.presenter = presenter
        
        return view
    }
    func createSoloSightScreen(router: Routing, sight: SightCD) -> UIViewController {
        let view = SoloSightViewController()
        let presenter = SoloSightPresenter(view: view,
                                           router: router,
                                           sight: sight)
        
        view.presenter = presenter
        
        return view
    }
}
