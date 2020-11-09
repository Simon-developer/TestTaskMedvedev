//
//  GradientShadowView.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 08.11.2020.
//

import Foundation
import UIKit

class GradientShadowView: UIView {
    private lazy var gradientLayer: CAGradientLayer = {
        let bgGradient          = CAGradientLayer()
        bgGradient.frame        = self.bounds
        bgGradient.colors       = [UIColor.clear.cgColor, AppConstants.darkColor.withAlphaComponent(0.6).cgColor]
        bgGradient.startPoint   = CGPoint(x: 0.5, y: 0)
        bgGradient.endPoint     = CGPoint(x: 0.5, y: 0.8)

        layer.insertSublayer(bgGradient, at: 0)
        return bgGradient
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = self.bounds
    }
}
