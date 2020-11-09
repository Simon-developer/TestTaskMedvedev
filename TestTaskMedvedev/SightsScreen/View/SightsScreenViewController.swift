//
//  SightsScreenViewController.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 08.11.2020.
//

import Foundation
import UIKit

protocol SightsScreenViewProtocol: class {
    func layoutNavigationBar()
    func layoutWebSights(preloaded: [Sight])
    func layoutHardTypedSights(preloaded: [SightCD])
}
class SightsScreenViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var presenter: SightsScreenPresenterProtocol!
    var tableView: UITableView!
    var preloadedPlaces: [Any]!
    var sightType: GoSightseeingButtonType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.presenter.startConfigure()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    @objc func backButtonTapHandler(_ sender: UIBarButtonItem) {
        self.presenter.goBackToCityWeatherView()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
extension SightsScreenViewController: SightsScreenViewProtocol {
    func layoutNavigationBar() {
        title = "Достопримечательности"
        
        let navBarAppearance = UINavigationBarAppearance()
        //navBarAppearance.configureWithOpaqueBackground()
        // Цвет текста навбара
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        // Фоновый цвет
        navBarAppearance.backgroundColor = AppConstants.skyColor
        // В обоих форматах один и тот же вид навбара
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        // Цвет статус бара на белый
        self.navigationController?.navigationBar.barStyle = .black
        // Большой заголовок
        self.navigationController?.navigationBar.prefersLargeTitles = false
        
        let backBarButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapHandler(_:)))
        backBarButton.tintColor = .white
        backBarButton.image?.withTintColor(.white)
        navigationItem.leftBarButtonItem = backBarButton
    }
    func layoutWebSights(preloaded: [Sight]) {
        self.preloadedPlaces = preloaded
        self.sightType = .webSights
        
        layoutTable()
    }
    func layoutHardTypedSights(preloaded: [SightCD]) {
        self.preloadedPlaces = preloaded
        self.sightType = .hardTypedSights
        
        layoutTable()
    }
    func layoutTable() {
        self.tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.bounces = true
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        
        switch self.sightType {
        case .hardTypedSights:
            tableView.register(HardSightTableViewCell.self, forCellReuseIdentifier: "hardSightCell")
            tableView.rowHeight = 270
        case .webSights:
            tableView.register(WebSightTableViewCell.self, forCellReuseIdentifier: "webSightCell")
            tableView.rowHeight = 150
        default:
            print("ERROR: sightType.noSights has reached, or sightType was nil.")
        }
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
}

extension SightsScreenViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.preloadedPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch self.sightType {
        
        case .hardTypedSights:
            let cell = tableView.dequeueReusableCell(withIdentifier: "hardSightCell", for: indexPath) as! HardSightTableViewCell
            if let sightCoerced = preloadedPlaces[indexPath.row] as? SightCD {
                cell.sightName = sightCoerced.name
                cell.desc      = sightCoerced.desc
                if let geoCoerced = sightCoerced.geo {
                    cell.longitude = geoCoerced["lng"]
                    cell.latitude  = geoCoerced["lat"]
                } else { fatalError("ERROR cell configure") }
                if let imageLink = sightCoerced.images {
                    cell.imageURL = imageLink[0]
                } else { fatalError("ERROR cell configure") }
                
                cell.loadImage()
                cell.layoutName()
                
            }
            return cell
        
        case .webSights:
            let cell = tableView.dequeueReusableCell(withIdentifier: "webSightCell", for: indexPath) as! WebSightTableViewCell
            if let sightCoerced = preloadedPlaces[indexPath.row] as? Sight {
                cell.sightName = sightCoerced.name
                cell.longitude = sightCoerced.geo.lng
                cell.latitude  = sightCoerced.geo.lat
                cell.loadImage()
                cell.layoutName()
                
            }
            return cell
        
        default: fatalError("ERROR")
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch self.sightType {
        case .hardTypedSights:
            
            tableView.deselectRow(at: indexPath, animated: true)
            let sight = preloadedPlaces[indexPath.row] as! SightCD
            self.presenter.openSoloSightScreen(sight: sight)
            
        
        case .webSights:
            tableView.deselectRow(at: indexPath, animated: true)
        default: fatalError("ERROR")
        }
    }
}
