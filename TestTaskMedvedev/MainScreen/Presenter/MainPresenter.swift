//
//  MainPresenter.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import UIKit

protocol MainPresenterProtocol {
    var previousRequests: [String] { get set }
    init(view: MainViewControllerProtocol, router: Routing)
    
    func startConfigure()
    func goToSearchResult(query: String)
}

class MainPresenter: MainPresenterProtocol {
    
    weak var view:  MainViewControllerProtocol?
    var router:     Routing?
    // Flow vars
    var previousRequests: [String] = []
    var city: City?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    required init(view: MainViewControllerProtocol, router: Routing) {
        self.view   = view
        self.router = router
    }
    func checkIfCitiesExistInCD() {
        do {
            let citiesFromCD = try context.fetch(CityCD.fetchRequest())
            if citiesFromCD.count == 0 {
                self.insertData()
            } else {
                if let cities = citiesFromCD as? [CityCD] {
                    self.view?.layoutCitiesInFavour(citiesArray: cities)
                }
            }
        } catch { print(error.localizedDescription) }
    }
    
    func startConfigure() {
        // ПОДГРУЖАЕМ МОДЕЛЬ ПОСЛЕДНЕГО ГОРОДА ИЗ UserDefaults
        previousRequests = loadPreviousRequests()
        
        // Проверяем, были ли уже добавлены данные о 50 достопримечательностях в 5 городах
        // Если да, все ОК, если нет, добавляем

        
        if self.router?.firstOpen == false {
            self.view?.refreshPreviousRequestsLayout()
        } else {
            self.view?.layoutNavBar()
            
            self.view?.layoutPreviousRequests()
            checkIfCitiesExistInCD()
            
            self.view?.layoutSearchOptions()
            self.view?.layoutAnimation()
        }
    }
    func loadPreviousRequests() -> [String] {
        // Подгружаем ранее использованные
        // запросы из UserDefaults
        let defaults = UserDefaults.standard
        let loadedData = defaults.object(forKey: "previousRequests") as? [String] ?? [String]()
        return loadedData
    }
    
    func goToSearchResult(query: String) {

        let stringURL = "https://maps.googleapis.com/maps/api/geocode/json?address=\(query)&key=AIzaSyCmEH-KR4nyXXPNe3k7R__LN6YAQQdNYuo"
        if let encodedURL = stringURL.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) {
            guard let googleApiUrl = URL(string: encodedURL) else { fatalError("ERROR: GOOGLE API ERROR") }
            let locationQuery = URLSession.shared.dataTask(with: googleApiUrl) { data, response, error in
                if let data = data, error == nil {
                    do {
                        guard let json      = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                        guard let results   = json["results"] as? [[String: Any]] else { return }
                        if results.count == 0 {
                            DispatchQueue.main.async {
                                self.view?.showAlert(title: "Неверный запрос", message: "К сожалению, мы не смогли найти такой город!")
                            }
                            return
                        }
                        guard let geometry  = results[0]["geometry"] as? [String: Any] else { return }
                        guard let location  = geometry["location"] as? [String: Any] else { return }
                        // Получаем финальные величины ширины и долготы
                        guard let longitude = location["lng"] as? Double else { return }
                        guard let latitude  = location["lat"] as? Double else { return }
                        
//                        print("------------------------")
//                        print(query)
//                        print("Долгота - \(longitude)")
//                        print("Широта - \(latitude)")
//                        print("------------------------")
                        
                        guard let weatherURL = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(String(latitude))&lon=\(String(longitude))&exclude=minutely,hourly,alerts&units=metric&lang=ru&appid=6e6e8147f2f37ea597ef83e52c344165") else { return }
                        let weatherQuery = URLSession.shared.dataTask(with: weatherURL) { data, response, error in
                            if let data = data, error == nil {
                                do {
                                    guard let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] else { return }
                                    guard let dailyForecast = json["daily"] as? [[String: Any]] else { return }
                                    // Проинициализируем контейнеры для записи в объект
                                    var dailyTemp: [[String: Double]] = []
                                    var dailyFeelTemp: [[String: Double]] = []
                                    var dailyWeatherDescription: [String] = []
                                    //var dailyWeatherClass: [String] = []
                                    var dailyIconId: [String] = []
                                    
                                    for day in dailyForecast {
//                                        // Код дня в Unix
//                                        guard let epocTime = day["dt"] as? Int else { return }
//                                        // Переведем в дату, должно совпадать с сегодняшним числом
//                                        let date = NSDate(timeIntervalSince1970: TimeInterval(epocTime))
                                        // Массив [Часть дня: Температура]
                                        guard let temp = day["temp"] as? [String: Double] else { return }
                                        // Массив [Часть дня: Как температура ощущается]
                                        guard let tempFeelsLike = day["feels_like"] as? [String: Double] else { return }
                                        // Погода (человеческое описание, массив)
                                        guard let weather = day["weather"] as? [[String: Any]] else { return }
                                        guard let weatherDescription = weather[0]["description"] as? String else { return }
                                        //guard let weatherDescriptionMain = weather[0]["main"] as? String else { return }
                                        guard let weatherIcon = weather[0]["icon"] as? String else { return }
                                        dailyTemp.append(temp)
                                        dailyFeelTemp.append(tempFeelsLike)
                                        dailyWeatherDescription.append(weatherDescription)
                                        //dailyWeatherClass.append(weatherDescriptionMain)
                                        dailyIconId.append(weatherIcon)
                                        
                                    }
                                    // Проверим, все ли удалось найти
                                    if dailyTemp.count == 0 || dailyFeelTemp.count == 0 || dailyWeatherDescription.count == 0 || dailyIconId.count == 0 {
                                        print("ERROR: Empty data for - \(query)")
                                        return
                                    }
                                    
                                    // Инициализируем наш удачно найденный и проанализированный город
                                    // Ввиду ограничений выбранного сервиса для поиска широты и долготы по названию города
                                    // (Google Geocoding API), стало возможным найти погоду на улицах и вблизи торговых центров
                                    // (нет настройки категории поиска)
                                    // (Он найдет почти любой набор букв) - Может баг, может фича.
                                    // Возможно исправить использованием другого сервиса, но искать другой уже нет времени((
                                    self.city = City(name: query, lat: latitude, lng: longitude, temps: dailyTemp, feels: dailyFeelTemp, descriptions: dailyWeatherDescription, icons: dailyIconId)
                                    
                                    // Если пользователь подряд открывает один и тот де город,
                                    // его запрос не будет запоминаться и повторяться в "недавних"
                                    if self.previousRequests.count > 0 && self.previousRequests[0] != query {
                                        // Если в запросе - один из ранее запрошенных городов,
                                        // он будет удален из списка, и поставлен в начало
                                        // Для пользователя он просто "переедет"
                                        if let repeatIndex = self.previousRequests.firstIndex(of: query) { self.previousRequests.remove(at: repeatIndex) }
                                        // В requestsToSave запишем отфильтрованный список
                                        // Необходимо, чтобы значений было не более 10
                                        // Иначе скролить юзер будет очень долго
                                        if self.previousRequests.count > 9 { self.previousRequests = Array(self.previousRequests.prefix(upTo: 9)) }
                                        // Добавим новый запрос
                                        self.previousRequests.insert(query, at: 0)
                                    } else if self.previousRequests.count == 0 {
                                        // Добавим новый запрос
                                        self.previousRequests.insert(query, at: 0)
                                    }
                                    // Переходим на экран с погодой
                                    DispatchQueue.main.async {
                                        // Сохраняем данные в UserDefaults
                                        let defaults = UserDefaults.standard
                                        defaults.set(self.previousRequests, forKey: "previousRequests")
                                        
                                        self.router?.cityWeatherViewController(city: self.city!)
                                    }
                                }
                                catch { fatalError("Weather requesting error: \(error.localizedDescription)") }
                            } else { print("Weather requesting error: \(String(describing: error?.localizedDescription))") }
                        }
                        weatherQuery.resume()
                    } catch { fatalError("Google geocoding error: error while parsing JSON for - \(query)") }
                } else { print("Google geocoding error: \(String(describing: error?.localizedDescription))") }
            }
            locationQuery.resume()
        }
    }
    func insertData() {
        for (id, city) in AppConstants.cityNames.enumerated() {
            let cityToSave = CityCD(context: self.context)
            cityToSave.name = city
            cityToSave.longtitude = AppConstants.cityLongitudes[id]
            cityToSave.latitude = AppConstants.cityLatitudes[id]
            
            for (innerId, placeName) in AppConstants.placeNames[id].enumerated() {
                let sightPlace = SightCD(context: self.context)
                sightPlace.name = placeName
                sightPlace.desc = AppConstants.placeDesc[id][innerId]
                sightPlace.descfull = AppConstants.placeDescfull[id][innerId]
                sightPlace.geo = ["lat": AppConstants.placeCoordinates[id][innerId][0],
                                  "lng": AppConstants.placeCoordinates[id][innerId][1]]
                print("Adding: \(placeName)")
                var urlArray: [URL] = []
                for imageStringURL in AppConstants.placeImageURLStrings[id][innerId] {
                    if let url = URL(string: imageStringURL) {
                        urlArray.append(url)
                    } else {
                        print("Ссылка не подошла - \(imageStringURL)")
                    }
                }
                sightPlace.images = urlArray
                cityToSave.addToSight(sightPlace)
            }
        }
        if self.context.hasChanges {
            do {
                try self.context.save()
                checkIfCitiesExistInCD()
                print("Default sights saved successfully!")
            } catch {
                print("Could not save any of cities")
            }
        }
    }
}
