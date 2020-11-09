//
//  SoloSightViewController.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 09.11.2020.
//

import Foundation
import UIKit
import MapKit

protocol SoloSightViewProtocol: class {
    func layoutNavigationBar(sightTitle: String)
    func layoutSoloView(sentImages: [UIImage], sightTitle: String, sightDescFull: String, sightLatitude: Double, sightLongitude: Double)
}
class SoloSightViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    var commonScrollView: UIScrollView!
    var commonInnerView: UIView!
    var commonInnerHeightConstr: NSLayoutConstraint!
    
    var gallery: UIView!

    var placeOnMap: MKMapView!
    var images: [UIImage]?
    
    var presenter: SoloSightPresenterProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = AppConstants.darkColor
        self.commonScrollView = UIScrollView()
        self.commonScrollView.delegate = self
        self.commonScrollView.showsVerticalScrollIndicator = false
        self.commonScrollView.contentSize = CGSize(width: view.frame.width, height: (self.view.frame.height * 3))
        view.addSubview(commonScrollView)
        commonScrollView.translatesAutoresizingMaskIntoConstraints = false
        commonScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        commonScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        commonScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        commonScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.commonInnerView = UIView()
        commonInnerView.translatesAutoresizingMaskIntoConstraints = false
        commonScrollView.addSubview(commonInnerView)
        commonInnerView.topAnchor.constraint(equalTo: commonScrollView.topAnchor).isActive = true
        commonInnerView.leadingAnchor.constraint(equalTo: commonScrollView.leadingAnchor).isActive = true
        commonInnerView.trailingAnchor.constraint(equalTo: commonScrollView.trailingAnchor).isActive = true
        commonInnerView.bottomAnchor.constraint(equalTo: commonScrollView.bottomAnchor).isActive = true
        self.commonInnerHeightConstr = commonInnerView.heightAnchor.constraint(equalTo: view.heightAnchor)
        self.commonInnerHeightConstr.isActive = true
        self.commonInnerHeightConstr.priority = UILayoutPriority(250)
        commonInnerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        
        
        
        self.presenter.startConfigure()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.placeOnMap.removeAnnotations(placeOnMap.annotations)
        super.viewWillDisappear(true)
    }
    @objc func scrollChanged(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .down {
            let location = sender.location(in: view)
            print(location.y)
            self.gallery.transform = CGAffineTransform(scaleX: 0, y: 1*(1 / 100))
        }
    }
    @objc func backButtonTapHandler(_ sender: UIBarButtonItem) {
        self.presenter.goBackToSightsScreen()
    }
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
extension SoloSightViewController: SoloSightViewProtocol {
    
    func layoutNavigationBar(sightTitle: String) {
        title = sightTitle
        
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
    func layoutSoloView(sentImages: [UIImage], sightTitle: String, sightDescFull: String, sightLatitude: Double, sightLongitude: Double) {
        self.images = sentImages
        
        if self.commonInnerView != nil {
            for subview in commonInnerView.subviews {
                subview.removeFromSuperview()
            }
        } else { return }
        
        gallery = GalleryView(imagesArray: sentImages)
        gallery.layer.zPosition = 7
        commonInnerView.addSubview(gallery)
        gallery.translatesAutoresizingMaskIntoConstraints = false
        gallery.topAnchor.constraint(equalTo: commonInnerView.topAnchor).isActive = true
        gallery.leadingAnchor.constraint(equalTo: commonInnerView.leadingAnchor).isActive = true
        gallery.trailingAnchor.constraint(equalTo: commonInnerView.trailingAnchor).isActive = true
        gallery.heightAnchor.constraint(equalToConstant: 300).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.text = sightTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 0
        commonInnerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: gallery.bottomAnchor, constant: 15).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: commonInnerView.leadingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: commonInnerView.trailingAnchor, constant: -15).isActive = true
        
        let descfullLabel = UILabel()
        descfullLabel.text = sightDescFull
        descfullLabel.numberOfLines = 0
        //descfullLabel.inset
        descfullLabel.font = UIFont.preferredFont(forTextStyle: .body)
        descfullLabel.textColor = .white
        commonInnerView.addSubview(descfullLabel)
        descfullLabel.translatesAutoresizingMaskIntoConstraints = false
        descfullLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15).isActive = true
        descfullLabel.leadingAnchor.constraint(equalTo: commonInnerView.leadingAnchor, constant: 15).isActive = true
        descfullLabel.trailingAnchor.constraint(equalTo: commonInnerView.trailingAnchor, constant: -15).isActive = true
        //descfullLabel.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        let onMapLabel = UILabel()
        onMapLabel.text = "На карте"
        onMapLabel.font = UIFont.boldSystemFont(ofSize: 20)
        onMapLabel.textColor = .white
        onMapLabel.textAlignment = .left
        onMapLabel.numberOfLines = 0
        commonInnerView.addSubview(onMapLabel)
        onMapLabel.translatesAutoresizingMaskIntoConstraints = false
        onMapLabel.topAnchor.constraint(equalTo: descfullLabel.bottomAnchor, constant: 20).isActive = true
        onMapLabel.leadingAnchor.constraint(equalTo: commonInnerView.leadingAnchor, constant: 15).isActive = true
        onMapLabel.trailingAnchor.constraint(equalTo: commonInnerView.trailingAnchor, constant: -15).isActive = true
        
        // Миникарта города
        self.placeOnMap = MKMapView()
        commonInnerView.addSubview(placeOnMap)
        placeOnMap.translatesAutoresizingMaskIntoConstraints = false
        
        let placeCoordinate = CLLocationCoordinate2D(latitude: sightLatitude, longitude: sightLongitude)
        let placeMapAnnotation = CityMapAnnotation(coordinate: placeCoordinate, title: sightTitle)
        // Добавляем метку города на карту
        placeOnMap.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        placeOnMap.addAnnotation(placeMapAnnotation)
        placeOnMap.setRegion(placeMapAnnotation.region, animated: true)
        
        // Располагаем миникарту на экране
        NSLayoutConstraint.activate([
            placeOnMap.topAnchor.constraint(equalTo: onMapLabel.bottomAnchor, constant: 10),
            placeOnMap.leadingAnchor.constraint(equalTo: commonInnerView.leadingAnchor),
            placeOnMap.trailingAnchor.constraint(equalTo: commonInnerView.trailingAnchor),
            placeOnMap.heightAnchor.constraint(equalToConstant: 240),
            placeOnMap.bottomAnchor.constraint(equalTo: commonInnerView.bottomAnchor)
        ])
    }
    

    
}
extension SoloSightViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
//        let xOffset = scrollView.contentOffset.x
//
//        var currentPage = 0
//
//        if xOffset > 100 {
//            if self.gallery != nil {
//                if let scroller = self.gallery.subviews.first as? UIScrollView {
//                    do {
//                        try scroller.scrollTo(horizontalPage: (currentPage + 1), animated: true)
//                    } catch {
//                        print("Not there")
//                    }
//                }
//            }
//        }
//        if xOffset < -100 {
//            if self.gallery != nil {
//                if let scroller = self.gallery.subviews.first as? UIScrollView {
//                    do {
//                        try scroller.scrollTo(horizontalPage: (currentPage - 1), animated: true)
//                    } catch {
//                        print("Not there")
//                    }
//                }
//            }
//        }
        if yOffset < 0 {
            if self.gallery != nil {
                self.gallery.transform = CGAffineTransform(scaleX: (1 + (0.007 * abs(yOffset))), y: (1 + (0.007 * abs(yOffset))))
            }
        } else if yOffset == 0 {
            if self.gallery != nil {
                gallery.transform = .identity
            }
        } else if yOffset > 0 {
            if self.gallery != nil {
                gallery.transform = CGAffineTransform(translationX: 0, y: -yOffset)
                
            }
        }
        
        
    }
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {

    }
}
