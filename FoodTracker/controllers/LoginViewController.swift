// Copyright (c) 2017 Lighthouse Labs. All rights reserved.
// 
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical or
// instructional purposes related to programming, coding, application development,
// or information technology.  Permission for such use, copying, modification,
// merger, publication, distribution, sublicensing, creation of derivative works,
// or sale is expressly withheld.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

class LoginViewController: UIViewController {
  
  @IBOutlet weak var usernameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  private var savedToken = ""
  private let usernameKey = "username"
  private let passwordKey = "password"
  private let tokenKey = "token"

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

  override func viewDidAppear(_ animated: Bool) {
    attemptToAutoLogin()
    
  }
  
  
  func attemptToAutoLogin() {
    //check user default for saved user information
    guard let username = UserDefaults.standard.value(forKey: usernameKey ) as? String,
      let password = UserDefaults.standard.value(forKey: passwordKey) as? String,
      let token = UserDefaults.standard.value(forKey: tokenKey) as? String else{
        //try to login
        print("No user default username and password")
        return
    }
    usernameTextField.text = username
    passwordTextField.text = password
    savedToken = token
  }

  func showLoginErrorAlert(message: String) {
    //show alert if there is an error
    let alert = UIAlertController(title: "Login error", message: message, preferredStyle: .alert)
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    
    self.present(alert, animated: true)
  }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
  
  func validUsernamePassword() -> Bool{
    if let username = usernameTextField.text, username.contains(" "){
      showLoginErrorAlert(message: "User name can't contain spaces!")
      return false
    }
    
    if let password = passwordTextField.text, password.count < 6
    {
      showLoginErrorAlert(message: "Password length has to be longer than 6 characters!")
      return false
    }
    
    return true
  }

  // MARK: - IB Actions

  @IBAction func loginUser(_ sender: Any) {
    if validUsernamePassword() {
      
      guard let username =  usernameTextField.text,
        let password = passwordTextField.text else {
          return
      }

    
      //try first time, then try to sign up on the server
      
      if savedToken == ""{
        CloudTrackerManager.shared.signupUser(username: username, password: password, completion: { (token, error) -> (Void) in
          
          if error != nil {
            DispatchQueue.main.async {
              self.showLoginErrorAlert(message: "Problem signing up the user!  Try again later. ")
            }
            return
          }
          
          //save credentials in userdefault
          UserDefaults.standard.set(username, forKey: self.usernameKey)
          UserDefaults.standard.set(password, forKey: self.passwordKey)
          UserDefaults.standard.set(token, forKey: self.tokenKey)
        })
          
      }
      else{
      
        CloudTrackerManager.shared.loginUser(username: username, password: password, completion: { (token, error) -> (Void) in
          
          if error != nil {
            
            DispatchQueue.main.async {
                self.showLoginErrorAlert(message: "Problem logging in!  Try again later. ")
            }

            return
          }
          
          //save credentials in userdefault
          UserDefaults.standard.set(username, forKey: self.usernameKey)
          UserDefaults.standard.set(password, forKey: self.passwordKey)
          UserDefaults.standard.set(token, forKey: self.tokenKey)
          
          self.performSegue(withIdentifier: "segueToMainScreen", sender: self)
        })
      }
      
      

      
    }
  }
}

