//
//  MealViewController.swift
//  FoodTracker
//
//  Created by Bennett on 2018-09-07.
//  Copyright © 2018 Bennett. All rights reserved.
//

import UIKit
import os.log


class MealViewController: UIViewController  {
  /*
   This value is either passed by `MealTableViewController` in `prepare(for:sender:)`
   or constructed as part of adding a new meal.
   */
  var meal: Meal?
  var userToken:String = ""
  
  //MARK: Properties
  
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var ratingControl: RatingControl!
  @IBOutlet weak var descriptionTextField: UITextField!
  @IBOutlet weak var caloriesTextField: UITextField!
  @IBOutlet weak var saveButton: UIBarButtonItem!

  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    nameTextField.delegate = self

    if let meal = meal {
      navigationItem.title = meal.name
      nameTextField.text   = meal.name
      photoImageView.image = meal.photo
      ratingControl.rating = meal.rating
    }
    
    // Enable the Save button only if the text field has a valid Meal name.
    updateSaveButtonState()
    
  }
  

  @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
    
    nameTextField.resignFirstResponder()
    let imagePickerController = UIImagePickerController()
    imagePickerController.sourceType = .photoLibrary
    imagePickerController.delegate = self
    present(imagePickerController, animated: true, completion: nil)
  }
}

  //MARK: UITextFieldDelegate
extension MealViewController : UITextFieldDelegate{
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    // Hide the keyboard.
    textField.resignFirstResponder()
    return true
  }
  
  func textFieldDidEndEditing(_ textField: UITextField) {
    updateSaveButtonState()
    navigationItem.title = textField.text
  }
  func textFieldDidBeginEditing(_ textField: UITextField) {
    // Disable the Save button while editing.
    saveButton.isEnabled = false
  }
}
//MARK: UIImagePickerControllerDelegate

extension MealViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    // Dismiss the picker if the user canceled.
    dismiss(animated: true, completion: nil)
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
      fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
    }
    // Set photoImageView to display the selected image.
    photoImageView.image = selectedImage
    
    // Dismiss the picker.
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: Navigation
  // This method lets you configure a view controller before it's presented.
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
    super.prepare(for: segue, sender: sender)
    
    // Configure the destination view controller only when the save button is pressed.
    guard let button = sender as? UIBarButtonItem, button === saveButton else {
      os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
      return
    }
    


  }
  
  //MARK: Navigation
  @IBAction func save(_ sender: UIBarButtonItem){
    let name = nameTextField.text ?? ""
    let photo = photoImageView.image
    let rating = ratingControl.rating
    let description = descriptionTextField.text ?? ""
    let calories = Int(caloriesTextField.text ?? "0") ?? 0
    
    // Set the meal to be passed to MealTableViewController after the unwind segue.
    meal = Meal(id: 0, userId: userToken, name: name, photo: photo, rating: rating, calories: calories, mealDescription: description)
    
    if let meal = meal{
      CloudTrackerManager.shared.saveMeal(meal: meal, completion: { (error) -> (Void) in
        //handle error
        if (error != nil){
          print("Error occured")
          return
        }
        self.performSegue(withIdentifier: "segueBackToMealList", sender: self)
      })
    }
    
  }
  
  
  @IBAction func cancel(_ sender: UIBarButtonItem) {
    // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
    let isPresentingInAddMealMode = presentingViewController is UINavigationController
    
    if isPresentingInAddMealMode {
      dismiss(animated: true, completion: nil)
    }
    else if let owningNavigationController = navigationController{
      owningNavigationController.popViewController(animated: true)
    }
    else {
      fatalError("The MealViewController is not inside a navigation controller.")
    }
  }
  
  //MARK: Private Methods
  
  private func updateSaveButtonState() {
    // Disable the Save button if the text field is empty.
    let text = nameTextField.text ?? ""
    saveButton.isEnabled = !text.isEmpty
  }
}
