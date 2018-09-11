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
  
  private let SIGNUP_URL = "https://cloud-tracker.herokuapp.com/signup"
  private let LOGIN_URL = "https://cloud-tracker.herokuapp.com/login"
  private let ACCESS_MEAL_URL = "https://cloud-tracker.herokuapp.com/users/me/meals"
  private let RATE_URL = "/rate"
  private let PHOTO_URL = "/photo"
  
  private let TOKEN_KEY = "token"
  private let TITLE_KEY = "title"
  private let CALORIES_KEY = "calories"
  private let DESCRIPTION_KEY = "description"
  private let MEAL_KEY = "meal"
  private let ID_KEY = "id"
  private let RATING_KEY = "rating"
  private let IMAGE_PATH_KEY = "imagePath"
  private let IMGUR_CLIENT_ID = "887c27b7d390539"
  private let IMGUR_URL = "https://api.imgur.com/3/upload"
  private let IMAGE_KEY = "image"
  private let DATA_KEY = "data"
  private let LINK_KEY = "link"
  private let PHOTO_KEY = "photo"
  
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
    
    post(data: postData, toEndpoint: SIGNUP_URL) { (data, error) -> (Void) in
      //do something with the data
      print("handle signup api data from signupUser()")
      
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      if let token = json?[self.TOKEN_KEY] as? String {
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
    
    post(data: postData, toEndpoint: LOGIN_URL) { (data, error) -> (Void) in
      //do something with the data
      print("handle login api data from loginUser()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      if let token = json?[self.TOKEN_KEY] as? String {
        print("username \(username), token is \(token)")
        self.savedToken = token
        completion(token, error)
      }
    }
  }
  
  
  func saveMeal(meal: Meal, completion: @escaping (Error?)->(Void)){
    let postData:[String: Any] = [
      TITLE_KEY: meal.name,
      CALORIES_KEY: meal.calories,
      DESCRIPTION_KEY: meal.mealDescription
    ]
    post(data: postData, toEndpoint: ACCESS_MEAL_URL) { (data, error) -> (Void) in
      //do something with the data
      print("handle login api data from saveMealURL()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }
      if let mealJson = json?[self.MEAL_KEY] as? [String: Any] {
        if let mealId = mealJson[self.ID_KEY] as? Int
        {
          //save the new meal ID
          print("meal id is \(mealId)")
          meal.id = mealId
          
          //save meal reating first
          self.saveMealRating(meal: meal, completion: { (error) -> (Void) in
            if let photo = meal.photo {
              //then try to post the image
              self.postImage(image: photo, completion: { (link, error) -> (Void) in
                guard let link = link else{
                  completion(error)
                  return
                }
                //lastly, save the image url
                self.saveMealImageURL(meal: meal, url: link, completion: { (error) -> (Void) in
                  completion(error)
                })
              })
            }
          })

        }
      }
    }
    
  }
  
  
  func saveMealRating(meal: Meal, completion: @escaping (Error?)->(Void)){
    let saveMealRatingURL = ACCESS_MEAL_URL + "/" + meal.id.description + RATE_URL
    let postData:[String: Any] = [
      RATING_KEY: meal.rating,
    ]
    post(data: postData, toEndpoint: saveMealRatingURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle api data from saveMealRatingURL()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }
      if let mealJson = json?[self.MEAL_KEY] as? [String: Any] {
        if let mealRating = mealJson[self.RATING_KEY] as? Int
        {
          // rating is set
          print("meal rating is \(mealRating)")
          
          completion(nil)
        }
      }
    }
    
  }
  
  
  func saveMealImageURL(meal: Meal, url: String, completion: @escaping (Error?)->(Void)){
    let saveMealRatingURL = ACCESS_MEAL_URL + "/" + meal.id.description + PHOTO_URL
    let postData = [PHOTO_KEY: url]
    post(data: postData, toEndpoint: saveMealRatingURL) { (data, error) -> (Void) in
      //do something with the data
      print("handle api data from saveMealImageURL()")
      guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }
      if let mealJson = json?[self.MEAL_KEY] as? [String: Any] {
        if let mealURL = mealJson[self.IMAGE_PATH_KEY] as? String
        {
          // rating is set
          print("meal url is \(mealURL)")
          
          completion(nil)
        }
      }
    }
    
  }
  
  func getAllMeal(completion: @escaping ([Meal]?, Error?)->(Void)){
    get(toEndpoint: ACCESS_MEAL_URL) { (data, error) -> (Void) in
      var result:[Meal] = [Meal]()
      print("handle api data from getAllMeal()")
      guard let data = data, let array = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
        print("data returned is not json, or not valid")
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }
      
      if let array = array {
        for element in array{
          let mealID = element[self.ID_KEY] as? Int ?? 0
          let calories = element[self.CALORIES_KEY] as? Int ?? 0
          let description = element[self.DESCRIPTION_KEY] as? String ?? ""
          let title = element[self.TITLE_KEY] as? String ?? ""
          let rating = element[self.RATING_KEY] as? Int ?? 0
          let imagePath = element[self.IMAGE_PATH_KEY] as? String ?? ""
          
          if let meal = Meal(id: mealID, userId: self.savedToken!, name: title, photo: nil, rating: rating, calories: calories, mealDescription: description){
            result.append(meal)
          }
        }
      }
      
      completion(result, nil)
    }
    
  }
  
  
  func postImage(image: UIImage, completion: @escaping  (String?, Error?)->(Void)){

    let url = URL(string: IMGUR_URL)!
    let request = NSMutableURLRequest(url: url)
    let imageData = UIImageJPEGRepresentation(image, 0.1)
    let base64String = imageData?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    
    let postData = [IMAGE_KEY: base64String]
    
    guard let postJSON = try? JSONSerialization.data(withJSONObject: postData, options: []) else {
      print("could not serialize json")
      return
    }
    
    request.httpBody = postJSON
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Client-ID \(IMGUR_CLIENT_ID)", forHTTPHeaderField: "Authorization")
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
      guard let result = json[self.DATA_KEY] as? [String: Any],
        let imageURL = result[self.LINK_KEY] as? String else{
        completion(nil, CloudTrackerAPIError.invalidJSON)
        return
      }

      completion(imageURL, nil)
      
    }
    
    task.resume()
    
  }
  
  func delete(mealID:Int, completion: @escaping  (Error?)->(Void)){
    
    let url = URL(string: ACCESS_MEAL_URL + "/\(mealID)")!
    let request = NSMutableURLRequest(url: url)

    request.httpMethod = "DELETE"
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
        completion(CloudTrackerAPIError.requestError)
        return
      }
      
      guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as! Dictionary<String, Any> else {
        print("data returned is not json, or not valid")
        completion(CloudTrackerAPIError.invalidJSON)
        return
      }

      guard response.statusCode == 200 else {
        // handle error
        print("an error occurred \(String(describing: json["error"]))")
        completion(CloudTrackerAPIError.badCredentials)
        return
      }
      
      // do something with the json object
      completion(nil)
      
    }
    
    task.resume()
    
  }
}
