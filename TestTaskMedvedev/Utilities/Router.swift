//
//  Router.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import UIKit

protocol Routing {
    var firstOpen: Bool { get set }
    var navigationController: UINavigationController? { get set }
    var builder: Builder? { get set }
    
    func initialViewController()
    func cityWeatherViewController(city: City)
    func sightsViewController(city: City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?)
    func soloSightViewController(sight: SightCD)
    func popLastViewController()
    func popToRoot()
}
class Router: Routing {
    
    var firstOpen: Bool = true
    
    var navigationController: UINavigationController?
    
    var builder: Builder?
    
    init(navigationController: UINavigationController, builder: Builder) {
        self.navigationController = navigationController
        self.builder = builder
    }
    /// Открытие начального экрана
    func initialViewController() {
        if navigationController != nil {
            // Создаем view controller главного экрана
            guard let mainViewController = builder?.createMainScreen(router: self) else {
                fatalError("ERROR: Failure while creating Main Screen via Builder") }
            // Показываем его
            navigationController!.viewControllers = [mainViewController]
        } else { fatalError("ERROR: UINavigationController is nil") }
    }
    func cityWeatherViewController(city: City) {
        if navigationController != nil {
            // Создаем view controller экрана c погодой
            guard let cityWeatherViewController = builder?.createCityWeatherScreen(router: self, city: city) else {
                fatalError("ERROR: Failure while creating Main Screen via Builder") }
            // Показываем его
            navigationController!.pushViewController(cityWeatherViewController, animated: true)
        } else { fatalError("ERROR: UINavigationController is nil") }
    }
    func sightsViewController(city: City, webPlaces: [Sight]?, hardTypedPlaces: [SightCD]?) {
        if navigationController != nil {
            // Создаем view controller экрана c достопримечательностями
            guard let sightsViewController = builder?.createSightsScreen(router: self,
                                                                         city: city,
                                                                         webPlaces: webPlaces,
                                                                         hardTypedPlaces: hardTypedPlaces) else {
                fatalError("ERROR: Failure while creating Main Screen via Builder") }
            // Показываем его
            navigationController!.pushViewController(sightsViewController, animated: true)
        } else { fatalError("ERROR: UINavigationController is nil") }
    }
    
    func soloSightViewController(sight: SightCD) {
        if navigationController != nil {
            // Создаем view controller экрана c достопримечательностями
            guard let soloSightViewController = builder?.createSoloSightScreen(router: self,
                                                                         sight: sight) else {
                fatalError("ERROR: Failure while creating Main Screen via Builder") }
            // Показываем его
            navigationController!.pushViewController(soloSightViewController, animated: true)
        } else { fatalError("ERROR: UINavigationController is nil") }
    }
    func popLastViewController() {
        if navigationController != nil {
            let controllers = navigationController!.viewControllers
            let controller = controllers[(controllers.count - 2)]
            navigationController?.popToViewController(controller, animated: true)
        }
    }
    /// Возврат к начальному экрану
    func popToRoot() {
        // Изменение firstOpen отвечает за то, чтобы главный экран понимал,
        // необходимо ли ему перепроверить наличие предыдущих запросов
        if self.firstOpen == true { self.firstOpen = true }
        // Производим возврат
        guard navigationController != nil else { fatalError("ERROR: UINavigationController is nil") }

        navigationController!.popToRootViewController(animated: true)
        
        if let controller = navigationController!.viewControllers[0] as? MainViewController {
            controller.refreshPreviousRequestsLayout()
        }
    }
}
