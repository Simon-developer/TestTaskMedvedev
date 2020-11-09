//
//  MainViewController.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import GooglePlaces
import UIKit
import Lottie
// import Network

protocol MainViewControllerProtocol: class {
    //var previousRequests: [String] { get set }
    
    func layoutNavBar()
    func layoutPreviousRequests()
    func layoutSearchOptions()
    func refreshPreviousRequestsLayout()
    func layoutAnimation()
    func layoutCitiesInFavour(citiesArray: [CityCD])
    func showAlert(title: String, message: String)
}

class MainViewController: UIViewController {
    // Основные переменные
    var presenter: MainPresenterProtocol!
    //let internetMonitor = NWPathMonitor()
    let internetQueue = DispatchQueue(label: "InternetMonitor")
    
    var animatedManView: AnimationView?
    //private var hasConnectionPath = false
    
    var previousRequestsScrollView: UIScrollView!
    // Переменные визуальных элементов
    var previousRequestsContainer: UIView!
    var previousRequestsTitleLabel: UILabel!
    var searchField: UISearchController!
    var searchOptionsTableView: UITableView!
    
    var citiesInFavourLabel: UILabel!
    var citiesInFavourScrollView: UIScrollView!
    var citiesInFavourContainer: UIView!
    var citiesInFavour: [CityCD]?
    // Constraints
    var searchOptionsTableViewBottomConstraint: NSLayoutConstraint!
    
    lazy var token: GMSAutocompleteSessionToken = {
        let token = GMSAutocompleteSessionToken()
        return token
    }()
    lazy var filter: GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .region
        return filter
    }()
    var fetcher: GMSAutocompleteFetcher!

    private var placesClient: GMSPlacesClient!
    
    var cities: [NSAttributedString] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Настройка модуля автозаполнения
        self.fetcher = GMSAutocompleteFetcher(filter: filter)
        fetcher.delegate = self
        fetcher.provide(token)
//        // Проверка на наличие интернета
//        if hasInternet() == false { showAlert(title: "Отсутствует интернет", message: "Чтобы продолжать работать, включите интернет") }
        presenter.startConfigure()
        // Отслеживание клавиатуры для появления таблицы с вариантами
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(ac, animated: true)
    }
    
//    func startInternetTracking() {
//        guard internetMonitor.pathUpdateHandler == nil else { return }
//        internetMonitor.pathUpdateHandler = { update in
//            if update.status == .satisfied {
//                print("Internet connection on.")
//                self.hasConnectionPath = true
//            } else {
//                print("no internet connection.")
//                self.hasConnectionPath = false
//            }
//        }
//        internetMonitor.start(queue: internetQueue)
//    }
//
//    /// will tell you if the device has an Internet connection
//    /// - Returns: true if there is some kind of connection
//    func hasInternet() -> Bool {
//        return hasConnectionPath
//    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardFrame = keyboardSize.cgRectValue
            let keyboardHeight = keyboardFrame.height
            searchOptionsTableViewBottomConstraint.constant = -keyboardHeight
            view.layoutIfNeeded()
            showOptionsTableView(duration: AppConstants.searchOptionsAppearAnimationDuration)
        }
    }
    @objc func keyboardWillHide(_ notification: Notification) {
        hideOptionsTableView(duration: AppConstants.searchOptionsAppearAnimationDuration)
    }
    @objc func previousRequestButtonTapped(_ sender: UIButton) {
        self.searchField.searchBar.text = sender.currentTitle
        self.presenter.goToSearchResult(query: searchField.searchBar.text!)
    }
    func showOptionsTableView(duration: CGFloat) {
        guard searchOptionsTableView != nil else { return }
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.searchOptionsTableView.transform = .identity
        })
    }
    func hideOptionsTableView(duration: CGFloat) {
        guard searchOptionsTableView != nil else { return }
        UIView.animate(withDuration: TimeInterval(duration), animations: {
            self.searchOptionsTableView.transform = CGAffineTransform(translationX: 0, y: self.view.bounds.height)
        }, completion: { _ in
            self.searchOptionsTableViewBottomConstraint.constant = 0
            self.view.layoutIfNeeded()
        })
    }
    
}
/// LAYOUT задачи
extension MainViewController: MainViewControllerProtocol {    
    func layoutAnimation() {
        self.animatedManView = .init(name: "man")
        animatedManView?.translatesAutoresizingMaskIntoConstraints = false
        animatedManView?.loopMode = .loop
        view.addSubview(animatedManView!)
        animatedManView!.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        animatedManView!.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        animatedManView!.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        animatedManView!.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        animatedManView?.play()
        
        
    }
    func layoutNavBar() {
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
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        title = "Погода"
        
        searchField = UISearchController()
        searchField.searchBar.delegate = self
        searchField.obscuresBackgroundDuringPresentation = false
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).defaultTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let searchBar = searchField.searchBar
        searchBar.searchTextField.leftView?.tintColor = AppConstants.skyColor
        // Установим цвета для кнопок
        searchBar.tintColor = UIColor.white
        searchBar.barTintColor = UIColor.black
        // Установим для поисковой строки фоновый цвет
        if let textfield = searchBar.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = .white
            textfield.textColor = .black
        }
        searchBar.placeholder = "Поиск"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Закрыть"
        // Добавим поисковую строку в навбар
        navigationItem.searchController = searchField

    }
    func layoutPreviousRequests() {
        previousRequestsContainer = UIView()
        //previousRequestsContainer.backgroundColor = .systemRed
        previousRequestsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(previousRequestsContainer)
        previousRequestsContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        previousRequestsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        previousRequestsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        if self.presenter.previousRequests.count == 0 {
            previousRequestsContainer.heightAnchor.constraint(equalToConstant: 70).isActive = true
        } else {
            previousRequestsContainer.heightAnchor.constraint(equalToConstant: 90).isActive = true
        }
        
        previousRequestsTitleLabel = UILabel()
        previousRequestsTitleLabel.text = "Ранее искали:"
        previousRequestsTitleLabel.textAlignment = .left
        previousRequestsTitleLabel.textColor = .black
        previousRequestsTitleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        previousRequestsContainer.addSubview(previousRequestsTitleLabel)
        previousRequestsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        previousRequestsTitleLabel.topAnchor.constraint(equalTo: previousRequestsContainer.topAnchor).isActive = true
        previousRequestsTitleLabel.leadingAnchor.constraint(equalTo: previousRequestsContainer.leadingAnchor, constant: 15).isActive = true
        previousRequestsTitleLabel.trailingAnchor.constraint(equalTo: previousRequestsContainer.trailingAnchor, constant: -15).isActive = true
        previousRequestsTitleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        previousRequestsScrollView = UIScrollView()
        previousRequestsScrollView.showsHorizontalScrollIndicator = false
        previousRequestsScrollView.contentSize = CGSize(width: ((self.presenter.previousRequests.count * 150) + (self.presenter.previousRequests.count * 10) + 15), height: 0)

        previousRequestsContainer.addSubview(previousRequestsScrollView)
        previousRequestsScrollView.translatesAutoresizingMaskIntoConstraints = false
        previousRequestsScrollView.topAnchor.constraint(equalTo: previousRequestsTitleLabel.bottomAnchor).isActive = true
        previousRequestsScrollView.leadingAnchor.constraint(equalTo: previousRequestsContainer.leadingAnchor).isActive = true
        previousRequestsScrollView.trailingAnchor.constraint(equalTo: previousRequestsContainer.trailingAnchor).isActive = true
        previousRequestsScrollView.bottomAnchor.constraint(equalTo: previousRequestsContainer.bottomAnchor).isActive = true
        
        if self.presenter.previousRequests.count == 0 {
            let noPreviousRequestsLabel = UILabel()
            noPreviousRequestsLabel.text = "Предыдущие запросы отсутствуют"
            noPreviousRequestsLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
            
            noPreviousRequestsLabel.textColor = .black
            previousRequestsScrollView.addSubview(noPreviousRequestsLabel)
            noPreviousRequestsLabel.translatesAutoresizingMaskIntoConstraints = false
            noPreviousRequestsLabel.topAnchor.constraint(equalTo: previousRequestsScrollView.topAnchor).isActive = true
            noPreviousRequestsLabel.leadingAnchor.constraint(equalTo: previousRequestsScrollView.leadingAnchor, constant: 15).isActive = true
            
            noPreviousRequestsLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
            noPreviousRequestsLabel.widthAnchor.constraint(equalToConstant: 250).isActive = true
        } else { layoutPreviousRequestsButtons() }
    }
    func layoutCitiesInFavour(citiesArray: [CityCD]) {
        citiesInFavourContainer = UIView()
        //previousRequestsContainer.backgroundColor = .systemRed
        citiesInFavourContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(citiesInFavourContainer)
        citiesInFavourContainer.topAnchor.constraint(equalTo: previousRequestsContainer.bottomAnchor, constant: 15).isActive = true
        citiesInFavourContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        citiesInFavourContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        citiesInFavourContainer.heightAnchor.constraint(equalToConstant: 90).isActive = true
        
        citiesInFavourLabel = UILabel()
        citiesInFavourLabel.text = "Города присутствия:"
        citiesInFavourLabel.textAlignment = .left
        citiesInFavourLabel.textColor = .black
        citiesInFavourLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        citiesInFavourContainer.addSubview(citiesInFavourLabel)
        citiesInFavourLabel.translatesAutoresizingMaskIntoConstraints = false
        citiesInFavourLabel.topAnchor.constraint(equalTo: citiesInFavourContainer.topAnchor).isActive = true
        citiesInFavourLabel.leadingAnchor.constraint(equalTo: citiesInFavourContainer.leadingAnchor, constant: 15).isActive = true
        citiesInFavourLabel.trailingAnchor.constraint(equalTo: citiesInFavourContainer.trailingAnchor, constant: -15).isActive = true
        citiesInFavourLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        citiesInFavourScrollView = UIScrollView()
        citiesInFavourScrollView.showsHorizontalScrollIndicator = false
        citiesInFavourScrollView.contentSize = CGSize(width: ((citiesArray.count * 150) + (citiesArray.count * 10) + 15), height: 0)

        citiesInFavourContainer.addSubview(citiesInFavourScrollView)
        citiesInFavourScrollView.translatesAutoresizingMaskIntoConstraints = false
        citiesInFavourScrollView.topAnchor.constraint(equalTo: citiesInFavourLabel.bottomAnchor).isActive = true
        citiesInFavourScrollView.leadingAnchor.constraint(equalTo: citiesInFavourContainer.leadingAnchor).isActive = true
        citiesInFavourScrollView.trailingAnchor.constraint(equalTo: citiesInFavourContainer.trailingAnchor).isActive = true
        citiesInFavourScrollView.bottomAnchor.constraint(equalTo: citiesInFavourContainer.bottomAnchor).isActive = true
        
        layoutCitiesInFavourButtons(cities: citiesArray)
    }
    func layoutPreviousRequestsButtons() {
        for (position, request) in self.presenter.previousRequests.enumerated() {
            let requestButton = PreviousCityButton(title: request)
            requestButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            requestButton.translatesAutoresizingMaskIntoConstraints = false
            previousRequestsScrollView.addSubview(requestButton)
            requestButton.topAnchor.constraint(equalTo: previousRequestsScrollView.topAnchor).isActive = true
            requestButton.leadingAnchor.constraint(equalTo: previousRequestsScrollView.leadingAnchor, constant: CGFloat(((150 * position) + (10 * position) + 15))).isActive = true
            requestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
            requestButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
            requestButton.titleLabel?.textColor = .black
            requestButton.addTarget(self, action: #selector(previousRequestButtonTapped(_:)), for: .touchUpInside)
        }
    }
    func layoutCitiesInFavourButtons(cities: [CityCD]) {
        for (position, request) in cities.enumerated() {
            if let cityName = request.name {
                let requestButton = PreviousCityButton(title: cityName)
                requestButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
                requestButton.translatesAutoresizingMaskIntoConstraints = false
                citiesInFavourScrollView.addSubview(requestButton)
                requestButton.topAnchor.constraint(equalTo: citiesInFavourScrollView.topAnchor).isActive = true
                requestButton.leadingAnchor.constraint(equalTo: citiesInFavourScrollView.leadingAnchor, constant: CGFloat(((150 * position) + (10 * position) + 15))).isActive = true
                requestButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
                requestButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
                requestButton.titleLabel?.textColor = .black
                requestButton.addTarget(self, action: #selector(previousRequestButtonTapped(_:)), for: .touchUpInside)
            }
        }
    }
    func layoutSearchOptions() {
        guard searchOptionsTableView == nil else { return }
        searchOptionsTableView = UITableView()
        searchOptionsTableView.layer.zPosition = 7
        searchOptionsTableView.backgroundColor = .white
        searchOptionsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchOptionCell")
        searchOptionsTableView.dataSource = self
        searchOptionsTableView.delegate = self
        view.addSubview(searchOptionsTableView)
        searchOptionsTableView.translatesAutoresizingMaskIntoConstraints = false
        searchOptionsTableView.topAnchor.constraint(equalTo: previousRequestsContainer.bottomAnchor, constant: 10).isActive = true
        searchOptionsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        searchOptionsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        searchOptionsTableViewBottomConstraint = searchOptionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        searchOptionsTableViewBottomConstraint.isActive = true
        hideOptionsTableView(duration: 0.0)
    }
    func refreshPreviousRequestsLayout() {
        print("refreshing")
        for subview in previousRequestsContainer.subviews {
            subview.removeFromSuperview()
        }
        previousRequestsScrollView.contentSize = CGSize(width: ((self.presenter.previousRequests.count * 150) + (self.presenter.previousRequests.count * 10) + 15), height: 0)
        layoutPreviousRequests()
    }
}
// MARK: - Делегат таблицы с вариантами поиска
extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cities.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchOptionCell", for: indexPath)
        cell.textLabel?.attributedText = cities[indexPath.row]
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard cities.indices.contains(indexPath.row) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        let query = cities[indexPath.row].string
        searchField.searchBar.resignFirstResponder()
        self.presenter.goToSearchResult(query: query)
    }
}

// MARK: - Делегат поисковой строки
extension MainViewController: UISearchBarDelegate {
    /// При изменении текста отправляем новый текст на обработку модулю автозаполнения
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        fetcher.sourceTextHasChanged(searchText)
    }
    ///
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
                
        guard searchBar.text != nil else { return }
        self.presenter.goToSearchResult(query: searchBar.text!)
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cities = []
        searchOptionsTableView.reloadData()
    }
}
// MARK: - Расширение для работы автозаполнения городов
extension MainViewController: GMSAutocompleteFetcherDelegate {
  func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
    self.cities = []
    for prediction in predictions {
        self.cities.append(prediction.attributedPrimaryText)
    }
    self.searchOptionsTableView.reloadData()
  }

  func didFailAutocompleteWithError(_ error: Error) {
    print(error.localizedDescription)
  }
}
