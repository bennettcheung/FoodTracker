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

//MARK: Properties
struct PropertyKey {
  static let name = "name"
  static let photo = "photo"
  static let rating = "rating"
}

class Meal : NSObject, NSCoding{
  
  //MARK: Types
  var id: Int
  var userId: String
  var name: String
  var photo: UIImage?
  var rating: Int
  var calories: Int
  var mealDescription: String
  
  //MARK: Archiving Paths
  
  static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
  static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
  
  init?(id: Int, userId: String, name: String, photo: UIImage?, rating: Int, calories: Int, mealDescription: String) {
    
    // The name must not be empty
    guard !name.isEmpty else {
      return nil
    }
    
    // Initialize stored properties.
    self.id = id
    self.userId = userId
    self.name = name
    self.photo = photo
    self.rating = rating
    self.calories = calories
    self.mealDescription = mealDescription
  }
  
  //MARK: NSCoding
  func encode(with aCoder: NSCoder) {
    aCoder.encode(name, forKey: PropertyKey.name)
    aCoder.encode(photo, forKey: PropertyKey.photo)
    aCoder.encode(rating, forKey: PropertyKey.rating)
  }
  
  required convenience init?(coder aDecoder: NSCoder) {
    
    // The name is required. If we cannot decode a name string, the initializer should fail.
    guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
      os_log("Unable to decode the name for a Meal object.", log: OSLog.default, type: .debug)
      return nil
    }
    
    // Because photo is an optional property of Meal, just use conditional cast.
    let photo = aDecoder.decodeObject(forKey: PropertyKey.photo) as? UIImage
    
    let rating = aDecoder.decodeInteger(forKey: PropertyKey.rating)
    
    // Must call designated initializer.
    self.init(id: 0, userId: "nouserid", name: name, photo: photo, rating: rating, calories: 0, mealDescription: "")
    
  }
}
