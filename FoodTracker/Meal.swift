//
//  Meal.swift
//  FoodTracker
//
//  Created by Bennett on 2018-09-07.
//  Copyright © 2018 Bennett. All rights reserved.
//

import Foundation
import UIKit
import os.log
import Parse

//MARK: Properties
struct PropertyKey {
  static let name = "name"
  static let photo = "photo"
  static let rating = "rating"
}

class Meal : PFObject, PFSubclassing {
  static func parseClassName() -> String {
    return "Meals"
  }
  
  
  //MARK: Types
  
  @NSManaged var name: String
  @NSManaged var pfPhoto: PFFile?
//  var photo: UIImage? {
//    set {
//            self.photo = newValue
//      if newValue != nil {
//
//        if let imageData = UIImagePNGRepresentation(newValue!){
//          pfPhoto = PFFile(data: imageData)
//          }
//        }
//      }
//    get {
//      return self.photo
//    }
//  }
  @NSManaged var rating: Int
  
  //MARK: Archiving Paths
  
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
  
  init?(name: String, pfPhoto: PFFile, rating: Int) {
    super.init()
    // The name must not be empty
    guard !name.isEmpty else {
      return nil
    }
    
    // Initialize stored properties.
    self.name = name
    self.pfPhoto = pfPhoto
    self.rating = rating

  }
  override init() {
    super.init()
  }
}
