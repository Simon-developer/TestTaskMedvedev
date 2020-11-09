//
//  Sights.swift
//  TestTaskMedvedev
//
//  Created by Semyon on 08.11.2020.
//

import Foundation

struct Geo {
    var lat: Double
    var lng: Double
    
    init(lat: Double, lng: Double) {
        self.lat = lat
        self.lng = lng
    }
}
//struct ProgrammedSight {
//    var name: String
//    var images: [URL]
//    var desc: String
//    var descFull: String
//    var geo: Geo
//    
//    init(name: String, images: [String], desc: String, descFull: String, lat: Double, lng: Double) {
//        self.name = name
//        
//        var urlStack: [URL] = []
//        
//        for element in images {
//            guard let url = URL(string: element) else {
//                print("Bad URL: \(element)")
//                continue
//            }
//            urlStack.append(url)
//        }
//        if urlStack.count == 0 {
//            // НЕОБХОДИМО ПРИСВОИТЬ ссылку на заранее подготовленную замещающую картинку
//            // вместо того чтобы устраивать экстренное завершение программы
//            fatalError("No picture for sight \(name)")
//        }
//        self.images = urlStack
//        self.desc = desc
//        self.descFull = descFull
//        self.geo = Geo(lat: lat, lng: lng)
//    }
//}
struct Sight {
    var name: String
    var placeId: String
    var geo: Geo

    init(name: String, placeId: String, lat: Double, lng: Double) {
        self.name = name
        self.placeId = placeId
        self.geo = Geo(lat: lat, lng: lng)
    }
}
