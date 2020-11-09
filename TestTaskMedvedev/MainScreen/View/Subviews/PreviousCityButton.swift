//
//  PreviousCityButton.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 06.11.2020.
//

import Foundation
import UIKit

class PreviousCityButton: UIButton {
    
    var buttonTitle: String!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(title: String) {
        self.init(frame: .zero)
        self.buttonTitle = title
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
        self.setTitle(buttonTitle, for: .normal)
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.layer.cornerRadius = 15
    }
    private lazy var gradientLayer: CAGradientLayer = {
        let bgGradient          = CAGradientLayer()
        bgGradient.frame        = self.bounds
        bgGradient.colors       = [UIColor.systemTeal.cgColor, AppConstants.skyColor.cgColor]
        bgGradient.startPoint   = CGPoint(x: 0, y: 0.5)
        bgGradient.endPoint     = CGPoint(x: 1, y: 0.5)
        bgGradient.cornerRadius = 15
        
        layer.insertSublayer(bgGradient, at: 0)
        return bgGradient
    }()
}
