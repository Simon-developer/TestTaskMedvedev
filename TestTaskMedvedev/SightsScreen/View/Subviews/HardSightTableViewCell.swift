//
//  HardSightTableViewCell.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 09.11.2020.
//

import UIKit

class HardSightTableViewCell: UITableViewCell {
    var innerContentView: UIView!
    
    var sightName: String!
    var desc: String!
    var longitude: Double!
    var latitude:  Double!
    var imageURL: URL!
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
        innerContentView.layer.shadowColor = UIColor.black.cgColor
        innerContentView.layer.shadowRadius = 5
        innerContentView.layer.shadowOpacity = 0.4
        innerContentView.layer.shadowOffset = .zero
        innerContentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(innerContentView)
        innerContentView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10).isActive = true
        innerContentView.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -10).isActive = true
        innerContentView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 15).isActive = true
        innerContentView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -15).isActive = true
        
        innerContentView.layer.cornerRadius = AppConstants.minCornerRadius
        
        self.backgroundColor = .white
        
    }
    func layoutName() {
        
        let descLabel = UILabel()
        descLabel.textColor = .white
        descLabel.layer.zPosition = 5
        descLabel.text = desc
        descLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        descLabel.adjustsFontSizeToFitWidth = true
        descLabel.numberOfLines = 2
        descLabel.textAlignment = .left
        innerContentView.addSubview(descLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        descLabel.bottomAnchor.constraint(equalTo: self.innerContentView.bottomAnchor, constant: -10).isActive = true
        descLabel.trailingAnchor.constraint(equalTo: self.innerContentView.trailingAnchor, constant: -15).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: self.innerContentView.leadingAnchor, constant: 15).isActive = true
        descLabel.heightAnchor.constraint(equalToConstant: 45).isActive = true
        
        let bgWhiteView = UIView()
        bgWhiteView.backgroundColor = AppConstants.skyColor
        bgWhiteView.layer.zPosition = 5
        bgWhiteView.translatesAutoresizingMaskIntoConstraints = false
        bgWhiteView.layer.shadowColor = UIColor.black.cgColor
        bgWhiteView.layer.shadowRadius = 5
        bgWhiteView.layer.shadowOpacity = 0.6
        self.innerContentView.addSubview(bgWhiteView)
        bgWhiteView.bottomAnchor.constraint(equalTo: descLabel.topAnchor, constant: -10).isActive = true
        bgWhiteView.widthAnchor.constraint(equalTo: self.innerContentView.widthAnchor, multiplier: 0.75).isActive = true
        bgWhiteView.leadingAnchor.constraint(equalTo: self.innerContentView.leadingAnchor, constant: -3).isActive = true
        bgWhiteView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.text = sightName
        titleLabel.layer.zPosition = 6
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .left
        innerContentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: bgWhiteView.topAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: bgWhiteView.trailingAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: bgWhiteView.leadingAnchor, constant: 18).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: bgWhiteView.bottomAnchor).isActive = true
    }
    func layoutImage(image: UIImage) {
        let imageView = UIImageView()
        imageView.layer.zPosition = 2
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        self.innerContentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.innerContentView.topAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: self.innerContentView.heightAnchor, multiplier: 0.6).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.innerContentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: self.innerContentView.trailingAnchor).isActive = true
        
        imageView.layer.cornerRadius = AppConstants.minCornerRadius
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        imageView.clipsToBounds = true
        
    }
    
    func loadImage() {
        guard let finalURL = imageURL else { fatalError("ERROR: error in google api link") }

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
