//
//  CloudTrackerManager.swift
//  FoodTracker
//
//  Created by Bennett on 2018-09-10.
//  Copyright © 2018 Bennett. All rights reserved.
//

import UIKit

enum CloudTrackerAPIError: Error {
  case badURL
  case requestError
  case invalidJSON
  case badCredentials
}

class CloudTrackerManager {
  
  
  static let shared = CloudTrackerManager()
  
  private let signupEndpointURL = "https://cloud-tracker.herokuapp.com/signup"
  private let loginEndpointURL = "https://cloud-tracker.herokuapp.com/login"
  private let accessMealURL = "https://cloud-tracker.herokuapp.com/users/me/meals"
  private let rateURL = "/rate"
  
  private let tokenKey = "token"
  private let titleKey = "title"
  private let caloriesKey = "calories"
  private let descriptionKey = "description"
  private let mealKey = "meal"
  private let idKey = "id"
  private let ratingKey = "rating"
  
  private var savedToken:String?
  
  func post(data: [String: Any], toEndpoint: String, completion: @escaping  (Data?, Error?)->(Void)){
    guard let postJSON = try? JSONSerialization.data(withJSONObject: data, options: []) else {
      print("could not serialize json")
      return
    }
    
    let url = URL(string: toEndpoint)!
    let request = NSMutableURLRequest(url: url)
    request.httpBody = postJSON
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if let savedToken = savedToken{
      request.addValue(savedToken, forHTTPHeaderField: "token")
    }
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
      
      guard let data = data else {
        print("no data returned from server \(String(describing: error?.localizedDescription))")
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("no response returned from server \(String(describing: error))")
        completion(nil, CloudTrackerAPIError.requestError)
        return
      }
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      
      guard response.statusCode == 200 else {
        // handle error
        print("an error occurred \(String(describing: json["error"]))")
        completion(nil, CloudTrackerAPIError.badCredentials)
        return
      }
      
      // do something with the json object
      completion(data, nil)
      
    }
    
    task.resume()
    
  }
  
  func get(toEndpoint: String, completion: @escaping  (Data?, Error?)->(Void)){

    let url = URL(string: toEndpoint)!
    let request = NSMutableURLRequest(url: url)
    
    request.httpMethod = "GET"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    if let savedToken = savedToken{
      request.addValue(savedToken, forHTTPHeaderField: "token")
    }
    let task = URLSession.shared.dataTask(with: request as URLRequest) { (data: Data?, response: URLResponse?, error: Error?) in
      
      guard let data = data else {
        print("no data returned from server \(String(describing: error?.localizedDescription))")
        return
      }
      
      guard let response = response as? HTTPURLResponse else {
        print("no response returned from server \(String(describing: error))")
        completion(nil, CloudTrackerAPIError.requestError)
        return
      }
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]] else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      
      guard response.statusCode == 200 else {
        // handle error
        print("an error occurred mac")
        completion(nil, CloudTrackerAPIError.badCredentials)
        return
      }
      
      // do something with the json object
      completion(data, nil)
      
    }
    
    task.resume()
  }
  
  func signupUser(username: String, password: String , completion: @escaping  (String?, Error?)->(Void)) -> Void {
    let postData:[String: Any] = [
      "username": username,
      "password": password
    ]
    
    post(data: postData, toEndpoint: signupEndpointURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle signup api data from signupUser()")
      
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      if let token = json?[self.tokenKey] as? String {
        print("\(username) - Token is \(token)")
        self.savedToken = token
        completion(token, error)
        return
      }
      
    }

  }

  func loginUser(username: String, password: String, completion: @escaping  (String?, Error?)->(Void)) -> Void {
    let postData:[String: Any] = [
      "username": username,
      "password": password
    ]
    
    post(data: postData, toEndpoint: loginEndpointURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle login api data from loginUser()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      if let token = json?[self.tokenKey] as? String {
        print("username \(username), token is \(token)")
        self.savedToken = token
        completion(token, error)
      }
    }
  }
  
  
  func saveMeal(meal: Meal, completion: @escaping (Error?)->(Void)){
    let postData:[String: Any] = [
      titleKey: meal.name,
      caloriesKey: meal.calories,
      descriptionKey: meal.mealDescription
    ]
    post(data: postData, toEndpoint: accessMealURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle login api data from saveMealURL()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }
      if let mealJson = json?[self.mealKey] as? [String: Any] {
        if let mealId = mealJson[self.idKey] as? Int
        {
          //save the new meal ID
          print("meal id is \(mealId)")
          meal.id = mealId
          self.saveMealRating(meal: meal, completion: completion)
        }
      }
    }
    
  }
  
  
  func saveMealRating(meal: Meal, completion: @escaping (Error?)->(Void)){
    let saveMealRatingURL = accessMealURL + "/" + meal.id.description + rateURL
    let postData:[String: Any] = [
      ratingKey: meal.rating,
    ]
    post(data: postData, toEndpoint: saveMealRatingURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle api data from saveMealRatingURL()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }
      if let mealJson = json?[self.mealKey] as? [String: Any] {
        if let mealRating = mealJson[self.ratingKey] as? Int
        {
          // rating is set
          print("meal rating is \(mealRating)")
          
          completion(nil)
        }
      }
    }
    
  }
  
  func getAllMeal(completion: @escaping ([Meal]?, Error?)->(Void)){
    get(toEndpoint: accessMealURL) { (data, error) -> (Void) in
      var result:[Meal] = [Meal]()
      print("handle api data from getAllMeal()")
      guard let data = data, let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      
      if let array = array {
        for element in array{
          let mealID = element[self.idKey] as? Int ?? 0
          let calories = element[self.caloriesKey] as? Int ?? 0
          let description = element[self.descriptionKey] as? String ?? ""
          let title = element[self.titleKey] as? String ?? ""
          let rating = element[self.ratingKey] as? Int ?? 0
          
          if let meal = Meal(id: mealID, userId: self.savedToken!, name: title, photo: nil, rating: rating, calories: calories, mealDescription: description){
            result.append(meal)
          }
        }
      }
      
      completion(result, nil)
    }
    
  }
}
