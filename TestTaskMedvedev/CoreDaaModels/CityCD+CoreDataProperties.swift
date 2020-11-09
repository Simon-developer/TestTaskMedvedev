//
//  CityCD+CoreDataProperties.swift
//  
//
//  Created by Semyon on 08.11.2020.
//
//

import Foundation
import CoreData


extension CityCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityCD> {
        return NSFetchRequest<CityCD>(entityName: "CityCD")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longtitude: Double
    @NSManaged public var name: String?
    @NSManaged public var sight: NSSet?

}

// MARK: Generated accessors for sight
extension CityCD {

    @objc(addSightObject:)
    @NSManaged public func addToSight(_ value: SightCD)

    @objc(removeSightObject:)
    @NSManaged public func removeFromSight(_ value: SightCD)

    @objc(addSight:)
    @NSManaged public func addToSight(_ values: NSSet)

    @objc(removeSight:)
    @NSManaged public func removeFromSight(_ values: NSSet)

}
