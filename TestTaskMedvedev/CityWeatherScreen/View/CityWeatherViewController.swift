//
//  CityWeatherViewController.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 07.11.2020.
//

import Foundation
import UIKit
import MapKit

protocol CityWeatherViewProtocol: class {
    
    func layoutNavigationBar()
    func layoutCityView(city: City, cityMapAnnotation: CityMapAnnotation)
    func layoutWeatherDays(views: [WeatherDayView])
    func layoutIfCityIsHardTyped()
    func layoutGoSightseeingButton(type: GoSightseeingButtonType)
}
class CityWeatherViewController: UIViewController {
    
    var presenter: CityWeatherPresenterProtocol!
    var cityMapView: MKMapView!
    var forecastLabel: UILabel!
    var locationManager: CLLocationManager!
    var weatherScrollView: UIScrollView!
    
    //var goSightSeeingButtonGradientBg: UIView!
    var goSightseeingButton: UIButton!
    var hardTypedView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.presenter.startConfigure()

    }
    override func viewWillDisappear(_ animated: Bool) {
        self.cityMapView.removeAnnotations(cityMapView.annotations)
        super.viewWillDisappear(true)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.goSightseeingButton == nil { return }
        UIView.animate(withDuration: 0.6, animations: {
            self.goSightseeingButton.transform = .identity
        })
    }
    @objc func backButtonTapHandler(_ sender: UIBarButtonItem) {
        print("Went to main")
        self.presenter.goBackToMain()
    }
}
extension CityWeatherViewController: CityWeatherViewProtocol {
    func layoutNavigationBar() {
        let backBarButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapHandler(_:)))
        backBarButton.tintColor = .white
        backBarButton.image?.withTintColor(.white)
        UIBarButtonItem.appearance().tintColor = .white
        navigationItem.leftBarButtonItem = backBarButton
        
        let navBarAppearance = UINavigationBarAppearance()
        //navBarAppearance.configureWithOpaqueBackground()
        // Цвет текста навбара
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // Фоновый цвет
        navBarAppearance.backgroundColor = AppConstants.skyColor
        // В обоих форматах один и тот же вид навбара
        //navigationController?.navigationBar.standardAppearance = navBarAppearance
        //navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        // Цвет статус бара на белый
        //self.navigationController?.navigationBar.barStyle = .black
        // Большой заголовок
        self.navigationController?.navigationBar.prefersLargeTitles = false
        

    }
    
    func layoutCityView(city: City, cityMapAnnotation: CityMapAnnotation) {
        title = city.name

        // Миникарта города
        self.cityMapView = MKMapView()
        view.addSubview(cityMapView)
        cityMapView.translatesAutoresizingMaskIntoConstraints = false
        
        // Добавляем метку города на карту
        cityMapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        cityMapView.addAnnotation(cityMapAnnotation)
        cityMapView.setRegion(cityMapAnnotation.region, animated: true)
        
        // Располагаем миникарту на экране
        NSLayoutConstraint.activate([
            cityMapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            cityMapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cityMapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cityMapView.heightAnchor.constraint(equalToConstant: 170)
        ])
        
        // Блок с подписью
        self.forecastLabel = UILabel()
        forecastLabel.text = "Прогноз на неделю"
        forecastLabel.textColor = .black
        forecastLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        view.addSubview(forecastLabel)
        forecastLabel.translatesAutoresizingMaskIntoConstraints = false
        forecastLabel.topAnchor.constraint(equalTo: cityMapView.bottomAnchor, constant: 10).isActive = true
        forecastLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15).isActive = true
        forecastLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        forecastLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    func layoutIfCityIsHardTyped() {
        self.hardTypedView = UIView()
        hardTypedView!.layer.borderWidth = 2
        hardTypedView!.layer.cornerRadius = AppConstants.minCornerRadius
        hardTypedView!.layer.borderColor = UIColor.systemGreen.cgColor
        view.addSubview(hardTypedView!)
        hardTypedView!.translatesAutoresizingMaskIntoConstraints = false
        hardTypedView!.topAnchor.constraint(equalTo: cityMapView.bottomAnchor, constant: 15).isActive = true
        hardTypedView!.widthAnchor.constraint(equalToConstant: 170).isActive = true
        hardTypedView!.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        hardTypedView!.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let hardTypedLabel = UILabel()
        hardTypedLabel.text = "\"Город присутствия\""
        hardTypedLabel.textColor = .systemGreen
        hardTypedLabel.font = UIFont.boldSystemFont(ofSize: 13)
        hardTypedLabel.textAlignment = .center
        hardTypedLabel.translatesAutoresizingMaskIntoConstraints = false
        hardTypedView!.addSubview(hardTypedLabel)
        hardTypedLabel.topAnchor.constraint(equalTo: hardTypedView!.topAnchor, constant: 5).isActive = true
        hardTypedLabel.leadingAnchor.constraint(equalTo: hardTypedView!.leadingAnchor, constant: 5).isActive = true
        hardTypedLabel.trailingAnchor.constraint(equalTo: hardTypedView!.trailingAnchor, constant: -5).isActive = true
        hardTypedLabel.bottomAnchor.constraint(equalTo: hardTypedView!.bottomAnchor, constant: -5).isActive = true
    }
    func layoutWeatherDays(views: [WeatherDayView]) {
        weatherScrollView = UIScrollView()
        weatherScrollView.clipsToBounds = false
        weatherScrollView.showsHorizontalScrollIndicator = false
        weatherScrollView.contentSize = CGSize(width: ((views.count * 150) + (10 * views.count) + 15), height: 0)
        view.addSubview(weatherScrollView)
        weatherScrollView.translatesAutoresizingMaskIntoConstraints = false
        weatherScrollView.topAnchor.constraint(equalTo: forecastLabel.bottomAnchor, constant: 10).isActive = true
        weatherScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        weatherScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        weatherScrollView.heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        for (position, element) in views.enumerated() {
            weatherScrollView.addSubview(element)
            element.translatesAutoresizingMaskIntoConstraints = false
            element.topAnchor.constraint(equalTo: weatherScrollView.topAnchor).isActive = true
            element.leadingAnchor.constraint(equalTo: weatherScrollView.leadingAnchor, constant: CGFloat(((150 * position) + (10 * position) + 15))).isActive = true
            element.heightAnchor.constraint(equalToConstant: 160).isActive = true
            element.widthAnchor.constraint(equalToConstant: 150).isActive = true
        }
    }
    func layoutGoSightseeingButton(type: GoSightseeingButtonType) {
        var showButton = false
        var buttonTitle = ""
        
        switch type {
        case .webSights:
            showButton = true
            buttonTitle = "Загрузить достопримечательности"
        case .hardTypedSights:
            showButton = true
            buttonTitle = "Достопримечательности"
        case .noSights:
            showButton = false
        }
        
        goSightseeingButton = UIButton()
        
        if showButton == false { return }
        goSightseeingButton.backgroundColor = AppConstants.skyColor
        goSightseeingButton.layer.cornerRadius = AppConstants.minCornerRadius
        goSightseeingButton.setTitle(buttonTitle, for: .normal)
        goSightseeingButton.titleLabel?.textColor = UIColor.white
        goSightseeingButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        goSightseeingButton.transform = CGAffineTransform(translationX: 0, y: 150)
        goSightseeingButton.addTarget(self, action: #selector(goToSights(_:)), for: .touchUpInside)
        view.addSubview(goSightseeingButton)
        goSightseeingButton.translatesAutoresizingMaskIntoConstraints = false
        goSightseeingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        goSightseeingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        goSightseeingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        goSightseeingButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    @objc func goToSights(_ sender: UIButton) {
        self.presenter.goToSightsScreen()
    }
}
extension CityWeatherViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let cityAnnotation = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            cityAnnotation.animatesWhenAdded = true
            cityAnnotation.markerTintColor = .systemTeal
            cityAnnotation.titleVisibility = .adaptive
            
            return cityAnnotation
        }
        return nil
    }
}
