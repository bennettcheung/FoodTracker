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
  private let tokenKey = "token"
  
  
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
        completion(token, error)
      }
      
      
      
    }
    
    return
  }
  
}
