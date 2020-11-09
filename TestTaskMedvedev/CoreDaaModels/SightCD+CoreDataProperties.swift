//
//  SightCD+CoreDataProperties.swift
//  
//
//  Created by Semyon on 08.11.2020.
//
//

import Foundation
import CoreData


extension SightCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SightCD> {
        return NSFetchRequest<SightCD>(entityName: "SightCD")
    }

    @NSManaged public var desc: String?
    @NSManaged public var descfull: String?
    @NSManaged public var geo: [String: Double]?
    @NSManaged public var images: [URL]?
    @NSManaged public var name: String?
    @NSManaged public var place: CityCD?

}
