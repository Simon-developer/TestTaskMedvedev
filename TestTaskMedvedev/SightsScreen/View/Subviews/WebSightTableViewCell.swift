//
//  WebSightTableViewCell.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 09.11.2020.
//

import UIKit
import MapKit

class WebSightTableViewCell: UITableViewCell {
    var innerContentView: UIView!
    var sightName: String!
    var longitude: Double!
    var latitude:  Double!
    //var placeImage: UIImage!
    
    var placeImage: UIImage?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in innerContentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.innerContentView = UIView()
        innerContentView.backgroundColor = AppConstants.darkColor
        innerContentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(innerContentView)
        innerContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        innerContentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        innerContentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        innerContentView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
        innerContentView.layer.cornerRadius = AppConstants.minCornerRadius
        
        
        
        contentView.backgroundColor = .white
        
    }
//    convenience init(name: String, longitude: Double, latitude: Double, reuseIdentifier: String?) {
//        self.init()
//        self.sightName = name
//        self.longitude = longitude
//        self.latitude  = latitude
//        
//        self.loadImage()
//    }
    func layoutName() {
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.layer.zPosition = 5
        titleLabel.text = sightName
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.layer.shadowColor = UIColor.black.cgColor
        titleLabel.layer.shadowOffset = CGSize(width: -2, height: 2)
        titleLabel.layer.shadowRadius = 7
        titleLabel.layer.shadowOpacity = 0.85
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .right
        innerContentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: self.innerContentView.topAnchor, constant: 15).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: self.innerContentView.widthAnchor, multiplier: 0.7).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.innerContentView.trailingAnchor, constant: -15).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: self.innerContentView.bottomAnchor).isActive = true
    }
    func layoutImage(image: UIImage) {
        let imageView = UIImageView()
        imageView.layer.zPosition = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        self.innerContentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.innerContentView.topAnchor, constant: 3).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.innerContentView.bottomAnchor, constant: -3).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.innerContentView.leadingAnchor, constant: 3).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.innerContentView.trailingAnchor,constant: -3).isActive = true
        
        imageView.layer.cornerRadius = AppConstants.minCornerRadius - 2
        imageView.clipsToBounds = true
    }
    
    func loadImage() {
        let imageURL: String = "https://maps.googleapis.com/maps/api/streetview?size=600x300&location=\(self.latitude!),\(self.longitude!)&key=\(AppConstants.googleApiKey)"
        
        guard let finalURL = URL(string: imageURL) else { fatalError("ERROR: error in google api link") }

        let session = URLSession(configuration: .default)
        
        session.dataTask(with: finalURL) { (data, response, error) in
            if error == nil &&  data != nil {
                if let _ = response as? HTTPURLResponse {
                    if let imageData = data {
                        
                        let image = UIImage(data: imageData)
                        DispatchQueue.main.async {
                            if image != nil {
                                self.layoutImage(image: image!)
                            }
                        }
                        
                    } else {
                        print("ERROR: Couldn't get image")
                    }
                } else {
                    print("ERROR: Couldn't get image")
                }
            } else if let foundError = error {
                print("ERROR: during picture download \(foundError.localizedDescription)")
            }
        }.resume()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
