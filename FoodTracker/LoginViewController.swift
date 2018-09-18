//
//  LoginViewController.swift
//  FoodTracker
//
//  Created by Bennett on 2018-09-18.
//  Copyright © 2018 Bennett. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var usernameTextField: UITextField!
  
  override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  @IBAction func signup(_ sender: Any) {
    
    // initialize a user object
    let newUser = PFUser()
    
    // set user properties
    newUser.username = usernameTextField.text
    newUser.email = emailTextField.text
    newUser.password = passwordTextField.text
    
    // call sign up function on the object
    newUser.signUpInBackground { (success: Bool, error: Error?) in
      if let error = error {
        print(error.localizedDescription)
      } else {
        print("User Registered successfully")
        // manually segue to logged in view
      }
    }
  }
  
  @IBAction func login(_ sender: Any) {
    
    let username = usernameTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    
    PFUser.logInWithUsername(inBackground: username, password: password) { (user: PFUser?, error: Error?) in
      if let error = error {
        print("User log in failed: \(error.localizedDescription)")
      } else {
        print("User logged in successfully")
        // display view controller that needs to shown after successful login
        self.performSegue(withIdentifier: "segueToMain", sender: self)
      }
    }
  }
}
