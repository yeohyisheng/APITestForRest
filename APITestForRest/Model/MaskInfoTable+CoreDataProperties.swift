//
//  MaskInfoTable+CoreDataProperties.swift
//  
//
//  Created by yeoh on 26/09/2022.
//
//

import Foundation
import CoreData


extension MaskInfoTable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MaskInfoTable> {
        return NSFetchRequest<MaskInfoTable>(entityName: "MaskInfoTable")
    }

    @NSManaged public var address: String?
    @NSManaged public var county: String?
    @NSManaged public var cunli: String?
    @NSManaged public var id: String?
    @NSManaged public var mask_adult: Int32
    @NSManaged public var mask_child: Int32
    @NSManaged public var name: String?
    @NSManaged public var phone: String?
    @NSManaged public var town: String?

}
