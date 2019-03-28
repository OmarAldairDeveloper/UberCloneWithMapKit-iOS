//
//  ViewController.swift
//  UberClon
//
//  Created by Omar Aldair Romero Pérez on 3/26/19.
//  Copyright © 2019 Omar Aldair Romero Pérez. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var driverLabel: UILabel!
    @IBOutlet weak var driverSwitch: UISwitch!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signInLabel: UILabel!
    @IBOutlet weak var signInButton: UIButton!
    
    
    // UISettings
    @IBOutlet weak var container: UIView!
    
    
    var isSignUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureUI()
    }

    @IBAction func signUpAction(_ sender: UIButton) {
        
        if let email = emailTextField.text, let password = passwordTextField.text, (email.count > 0 && password.count > 0){
            
            
            if isSignUpMode{
                // Registrarse
                Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                    
                    if let error = (error as NSError?){
                        self.showSimpleAlert(title: "Error", message: self.showErrorType(error: error))
                    }else{
                        
                        if self.driverSwitch.isOn{
                            // Es un conductor
                            let changeRequest = result?.user.createProfileChangeRequest()
                            changeRequest?.displayName = "Driver"
                            changeRequest?.commitChanges(completion: nil)
                            self.performSegue(withIdentifier: "DriverSegue", sender: nil)
                            
                        }else{
                            // Es un pasajero
                            let changeRequest = result?.user.createProfileChangeRequest()
                            changeRequest?.displayName = "Rider"
                            changeRequest?.commitChanges(completion: nil)
                            self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                        }
                        
                    }
                }
            }else{
                // Loguearse
                Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
                    
                    if let error = (error as NSError?){
                        self.showSimpleAlert(title: "Error", message: self.showErrorType(error: error))
                    }else{
                        
                    
                        if let user = result?.user{
                            
                            if user.displayName == "Driver"{
                                // Es un conductor
                                self.performSegue(withIdentifier: "DriverSegue", sender: nil)
                                
                            }else{
                                // Es un pasajero
                                self.performSegue(withIdentifier: "RiderSegue", sender: nil)
                            }
                        }
                        
                        
                    }
                }
            }
            
            
        }else{
            showSimpleAlert(title: "Campos vacíos", message: "Hay campos vacíos")
        }
        
    }
    
    
    
    @IBAction func changeAction(_ sender: UIButton) {
        
        if isSignUpMode{
            driverLabel.isHidden = true
            driverSwitch.isHidden = true
            registerButton.setTitle("Iniciar sesión", for: .normal)
            signInLabel.text = "O regístrate"
            signInButton.setTitle("Registrarse", for: .normal)
            isSignUpMode = false
        }else{
            
            driverLabel.isHidden = false
            driverSwitch.isHidden = false
            registerButton.setTitle("Registrarse", for: .normal)
            signInLabel.text = "O Inicia sesión"
            signInButton.setTitle("Iniciar sesión", for: .normal)
            isSignUpMode = true
            
        }
        
    }
    
    
    // Funciones
    func showSimpleAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true)
        
    }
    
    
    func showErrorType(error: NSError) -> String{
        
        var errorMessage = ""
        if let errorCode = AuthErrorCode(rawValue: error.code){
            
            switch errorCode{
                
            case .emailAlreadyInUse:
                errorMessage = "Email ya en uso"
                break
                
                
            case .invalidEmail:
                errorMessage = "Email inválido"
                break
                
            case .networkError:
                errorMessage = "Error de red"
                break
                
            case .weakPassword:
                errorMessage = "Contraseña demasiado débil"
                break
                
                
            case .wrongPassword:
                errorMessage = "Contraseña incorrecta"
                break
               
            default:
                return "Error"
            }
            
        }
        
        return errorMessage
        
        
        
    }
    
    func configureUI(){
        let mainYellow = UIColor(red: CGFloat(251)/255, green: CGFloat(192)/255, blue: CGFloat(45)/255, alpha: 1)
        
        self.view.backgroundColor = mainYellow
        self.container.layer.cornerRadius = 16
        self.driverSwitch.onTintColor = mainYellow
        self.registerButton.backgroundColor = mainYellow
        self.registerButton.layer.cornerRadius = 20
    }
    
}

