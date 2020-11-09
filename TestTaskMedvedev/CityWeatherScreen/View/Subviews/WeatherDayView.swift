//
//  WeatherDayView.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 07.11.2020.
//

import Foundation
import UIKit

class WeatherDayView: UIView {
    var icon: UIImage!
    var weatherDescription: String!
    var temperature: Double!
    var temperatureFeelsLike: Double!
    var upperView: UIView!
    var dateString: String!
    
//    private lazy var gradientLayer: CAGradientLayer = {
//        let bgGradient          = CAGradientLayer()
//        bgGradient.frame        = self.bounds
//        bgGradient.colors       = [UIColor.white.cgColor, AppConstants.skyColor.cgColor]
//        bgGradient.startPoint   = CGPoint(x: 0.3, y: 1)
//        bgGradient.endPoint     = CGPoint(x: 1, y: 0.3)
//        bgGradient.cornerRadius = 15
//
//        layer.insertSublayer(bgGradient, at: 0)
//        return bgGradient
//    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = AppConstants.minCornerRadius
        self.backgroundColor = AppConstants.darkColor
//        self.upperView = UIView()
//        upperView.backgroundColor = .white
//        self.addSubview(upperView)
//        upperView.layer.cornerRadius = AppConstants.minCornerRadius
//        upperView.translatesAutoresizingMaskIntoConstraints = false
//        upperView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
//        upperView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -2).isActive = true
//        upperView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 2).isActive = true
//        upperView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
//        backgroundColor = AppConstants.skyColor.withAlphaComponent(0.5)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
//        gradientLayer.frame = self.bounds
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOffset = CGSize(width: 2, height: 5)
//        layer.shadowRadius = 8
//        layer.shadowOpacity = 0.4
    }
    
    convenience init(icon: UIImage, weatherDescription: String, temperature: Double, temperatureFeelsLike: Double, dateString: String) {
        self.init(frame: .zero)
        self.icon = icon
        self.weatherDescription = weatherDescription
        self.temperature = temperature
        self.temperatureFeelsLike = temperatureFeelsLike
        self.dateString = dateString
        
        let dateLabel = UILabel()
        dateLabel.text = dateString
        dateLabel.textColor = .black 
        dateLabel.font = UIFont.boldSystemFont(ofSize: 14)
        dateLabel.textAlignment = .center
        dateLabel.layer.cornerRadius = AppConstants.minCornerRadius
        dateLabel.backgroundColor = .white
        dateLabel.clipsToBounds = true
        dateLabel.layer.zPosition = 5
        self.addSubview(dateLabel)
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 15).isActive = true
        dateLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dateLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = weatherDescription
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        descriptionLabel.textColor = .white
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        self.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.bottomAnchor.constraint(equalTo: dateLabel.topAnchor, constant: -7).isActive = true
        descriptionLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        //descriptionLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        descriptionLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        
        let temperatureLabel = UILabel()
        temperatureLabel.text = "\(String(format: "%.1f", self.temperature)) °C"
        temperatureLabel.font = UIFont.boldSystemFont(ofSize: 25)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        temperatureLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(temperatureLabel)
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.bottomAnchor.constraint(equalTo: descriptionLabel.topAnchor, constant: -7).isActive = true
        temperatureLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        temperatureLabel.heightAnchor.constraint(equalToConstant: 25).isActive = true
        temperatureLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8).isActive = true
        
        let iconView = UIImageView(image: icon)
        iconView.contentMode = .scaleAspectFit
        self.addSubview(iconView)
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
        iconView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -35).isActive = true
        iconView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 35).isActive = true
        iconView.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -10).isActive = true
        

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
