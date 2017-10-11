//
//  User+CoreDataProperties.swift
//  MessangerFirebase
//
//  Created by Phoenix on 30.09.17.
//  Copyright © 2017 Phoenix_Dev. All rights reserved.
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User");
    }

    @NSManaged public var name: String?
    @NSManaged public var email: String?
    @NSManaged public var profileImage: String?

}
