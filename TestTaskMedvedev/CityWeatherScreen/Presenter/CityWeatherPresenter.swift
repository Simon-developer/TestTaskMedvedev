//
//  CityWeatherPresenter.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 07.11.2020.
//

import Foundation
import UIKit
import MapKit

enum GoSightseeingButtonType {
    case webSights, hardTypedSights, noSights
}

protocol CityWeatherPresenterProtocol {
    init(view: CityWeatherViewProtocol, router: Routing, city: City)
    
    func startConfigure()
    func goToSightsScreen()
    func goBackToMain()
}
class CityWeatherPresenter: CityWeatherPresenterProtocol {
    
    weak var view: CityWeatherViewProtocol?
    var router: Routing!
    var city: City!
    
    var webSights: [Sight]?
    var hardTypedSights: [SightCD]?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    required init(view: CityWeatherViewProtocol, router: Routing, city: City) {
        self.view = view
        self.router = router
        self.city = city
    }
    func checkForHardtypedSights() -> [SightCD]? {
        
        var sightsToReturn: [SightCD] = []
        
        do {
            let sightsFromCD = try context.fetch(SightCD.fetchRequest())
            if sightsFromCD.count == 0 {
                fatalError("ERROR: Could not retrieve any sights from CoreData somehow.")
            } else {
                //print(sightsFromCD.count)
                for case let sight as SightCD in sightsFromCD {
                    if let place = sight.place {
                        if place.longtitude == city.lng && place.latitude == city.lat {
                            sightsToReturn.append(sight)
                        }
                    }
                }
            }
        } catch { print(error.localizedDescription) }
        
        if sightsToReturn.count > 0 { return sightsToReturn }
        return nil
    }
    
    func checkForWebSights(completion: @escaping (_ data: [Sight]?) -> ()) {
        let queryURL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(city.lat),\(city.lng)&radius=2500&type=tourist_attraction&key=\(AppConstants.googleApiKey)"

        guard let url = URL(string: queryURL) else { fatalError("ERROR: Unable to get sights for spot, URL is bad") }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                    guard let results = json["results"] as? [[String: Any]] else { fatalError("ERrooooooooor") }
                    
                    var places: [Sight] = []
                    
                    for item in results {
                        guard let placeId    = item["place_id"] as? String else { continue }
                        guard let sightName  = item["name"] as? String else { fatalError("Ошибка") }
                        guard let geometry   = item["geometry"] as? [String: Any] else { fatalError("Ошибка") }
                        guard let location   = geometry["location"] as? [String: Any] else { fatalError("Ошибка") }
                        guard let latitude   = location["lat"] as? Double else { fatalError("Ошибка") }
                        guard let longtitude = location["lng"] as? Double else { fatalError("Ошибка") }
                        //print(placeId)
                        
                        if sightName == "" && latitude != 0 && longtitude != 0 && placeId == "" {
//                            print("---------------------------------------")
//                            print("Name: \(sightName)")
//                            print("PlaceId: \(placeId)")
//                            print("Geo: lat: \(latitude), lng: \(longtitude)")
//                            print("missing smth")
                            continue
                        }
                        let sight = Sight(name: sightName, placeId: placeId, lat: latitude, lng: longtitude)
                        places.append(sight)
                    }
                    if places.count > 0 { completion(places) }
                    else { completion(nil) }
                } catch {
                    fatalError("ERROR: Unable to understand json sights for spot")
                }
            } else {
                fatalError("ERROR: Unable to get sights for spot")
            }
            
        }.resume()

    }
    
    func startConfigure() {
        // SEARCH FOR WEATHER AND LOCATIONS
        self.view?.layoutNavigationBar()
        let cityCoordinate = CLLocationCoordinate2D(latitude: city.lat, longitude: city.lng)
        let cityMapAnnotation = CityMapAnnotation(coordinate: cityCoordinate, title: city.name)
        self.view?.layoutCityView(city: city, cityMapAnnotation: cityMapAnnotation)
        
        var weatherDayViews: [WeatherDayView] = []
        for index in 0..<city.temperatures.count {
            
            guard let temp  = city.temperatures[index]["day"] else { fatalError("Не вышло") }
            guard let feels = city.feelTemperatures[index]["day"] else { fatalError("Не вышло") }
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "d MMMM"
            
            var dateString: String
            
            if index == 0 {
                dateString = "Сегодня"
            } else if index == 1 {
                dateString = "Завтра"
            } else {
                let today = Date()
                if let nextDate = Calendar.current.date(byAdding: .day, value: index, to: today) {
                    let formattedDateString = dateFormatter.string(from: nextDate)
                    dateString = formattedDateString
                } else {
                    dateString = "Unknown"
                }
            }
            
            let weatherDayView = WeatherDayView(icon: city.weatherIcons[index],
                                                weatherDescription: city.weatherDescriptions[index],
                                                temperature: temp,
                                                temperatureFeelsLike: feels,
                                                dateString: dateString)
            
            weatherDayViews.append(weatherDayView)
        }
        self.view?.layoutWeatherDays(views: weatherDayViews)
        // Отобразим кнопку с достопримечательностями
        // в зависимости от источников достопримечательностей
        self.checkSights()
    }
    func completionWeb(_ data: [Sight]?) {
        DispatchQueue.main.async {
            if data == nil {
                // Ни в интернете, ни в сохраненках не нашлось достопримечательностей
                self.view?.layoutGoSightseeingButton(type: GoSightseeingButtonType.noSights)
            } else {
                // Достопримечательности нашлись в интернете
                self.webSights = data
                self.view?.layoutGoSightseeingButton(type: GoSightseeingButtonType.webSights)
            }
        }
    }
    
    func checkSights() {
        // Проверим, есть ли для этого города заранее введенные места
        let hardSights = checkForHardtypedSights()
        if hardSights == nil {
            // Если заранее введенных мест не оказалось, проверим
            // что может предложить интернет
            checkForWebSights(completion: completionWeb(_:))
        } else {
            self.hardTypedSights = hardSights
            // Есть сохраненные достопримечательности
            self.view?.layoutIfCityIsHardTyped()
            self.view?.layoutGoSightseeingButton(type: GoSightseeingButtonType.hardTypedSights)
        }
    }
    
    func goToSightsScreen() {
        self.router.sightsViewController(city: self.city, webPlaces: webSights, hardTypedPlaces: hardTypedSights)
    }
    
    func goBackToMain() {
        self.router.popToRoot()
    }    
}
