//
//  GalleryView.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 09.11.2020.
//

import Foundation
import UIKit

class GalleryView: UIView {
    var imagesArray: [UIImage]?
    var photoScrollView: UIScrollView!
    var pageController: UIPageControl?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    convenience init(imagesArray: [UIImage]) {
        self.init(frame: .zero)
        self.imagesArray = imagesArray
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    override func didMoveToSuperview() {
        self.photoScrollView = UIScrollView()
        self.photoScrollView.delegate = self
        photoScrollView.isPagingEnabled = true
        photoScrollView.showsHorizontalScrollIndicator = false
        photoScrollView.delegate = self
        photoScrollView.contentSize = CGSize(width: (CGFloat(self.imagesArray!.count) * self.frame.width), height: 0)
        //(UISwipeGestureRecognizer(target: self, action: #selector(scrollChange(_:))))
        self.addSubview(photoScrollView)
        self.addGestureRecognizer(UISwipeGestureRecognizer(target: self, action: #selector(scrollChange(_:))))
        photoScrollView.translatesAutoresizingMaskIntoConstraints = false
        photoScrollView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        photoScrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        photoScrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        photoScrollView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        for position in 0..<imagesArray!.count {
            let tmpImgView =  UIImageView()
            tmpImgView.image = imagesArray![position]
            tmpImgView.contentMode = .scaleAspectFill
            tmpImgView.clipsToBounds = true
            photoScrollView.addSubview(tmpImgView)
            tmpImgView.translatesAutoresizingMaskIntoConstraints = false
            tmpImgView.topAnchor.constraint(equalTo: photoScrollView.topAnchor).isActive = true
            tmpImgView.leadingAnchor.constraint(equalTo: photoScrollView.leadingAnchor, constant: (CGFloat(position) * self.frame.width)).isActive = true
            tmpImgView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
            tmpImgView.heightAnchor.constraint(equalTo: photoScrollView.heightAnchor).isActive = true
        }
        
//        pageController = UIPageControl()
//        pageController.numberOfPages = imagesArray!.count
//        pageController.currentPage = 0
//
////        pageController.addTarget(self, action: #selector(pageControllerTapHandler(sender:)), for: .touchUpInside)
////        self.addSubview(pageController)
////        self.bringSubviewToFront(pageController)
////        pageController.translatesAutoresizingMaskIntoConstraints = false
////        pageController.topAnchor.constraint(equalTo: self.topAnchor, constant: 15).isActive = true
////        pageController.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
////        pageController.heightAnchor.constraint(equalToConstant: 45).isActive = true
    }
    @objc func scrollChange(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            swipedLeft()
        } else if sender.direction == .right {
            swipedRight()
        }
    }
    func swipedLeft() {
        guard photoScrollView != nil else {
            print("nil")
            return
        }
        let pageIndex = round(self.photoScrollView.contentOffset.x / self.frame.width)
        if (imagesArray!.count - 1) > Int(pageIndex) {
            photoScrollView.scrollTo(horizontalPage: (Int(pageIndex) + 1), animated: true)
        }
    }

    func swipedRight() {
        guard photoScrollView != nil else {
            print("nil")
            return
        }
        let pageIndex = round(self.photoScrollView.contentOffset.x / self.frame.width)
        if Int(pageIndex) > 0 {
            photoScrollView.scrollTo(horizontalPage: (Int(pageIndex) - 1), animated: true)
        }
    }
    
    @objc func pageControllerTapHandler(sender: UIPageControl) {
        photoScrollView.scrollTo(horizontalPage: sender.currentPage, animated: true)
    }
}
extension GalleryView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //let pageIndex = round(scrollView.contentOffset.x / self.frame.width)
        //pageController.currentPage = Int(pageIndex)
    }
}
