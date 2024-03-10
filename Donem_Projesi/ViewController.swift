//
//  ViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 27.02.2023.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    let button = UIButton()
    var control = 0
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signButton: UIButton!
    @IBOutlet weak var forgotPasswordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.borderStyle = UITextField.BorderStyle.roundedRect
        passwordTextField.borderStyle = UITextField.BorderStyle.roundedRect
        emailTextField.autocorrectionType = UITextAutocorrectionType.no
        button.setImage(UIImage(named: "eyes_off"), for: .normal)
        button.frame = CGRect(x: 352, y: 455, width: 33, height: 25)
        button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        view.addSubview(button)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.gray], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
    
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapFunction))
        forgotPasswordLabel.isUserInteractionEnabled = true
        forgotPasswordLabel.addGestureRecognizer(tap)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if (emailTextField.text == "")
        {
            alert(title: "Hata", message: "E-mail alanını doldurunuz.")
        }
        else
        {
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { Error in
                if Error != nil
                {
                    self.alert(title: "Hata", message: Error!.localizedDescription)
                    return
                }
                self.alert(title: "E-mail gönderildi", message: "Lütfen maillerinizi kontrol ediniz")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let tabBarController = segue.destination as? UITabBarController
        tabBarController?.selectedIndex = 2
    }
    
    func alert (title: String, message: String)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Tamam", style: .default)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
    
    
    @objc func refresh()//şifre labelının nasıl gözükmesi gerektiği ayarlanıyor
    {
        if(control == 0)
        {
            passwordTextField.isSecureTextEntry = false
            button.setImage(UIImage(named: "eyes_on"), for: .normal)
            control = 1
        }
        else if (control == 1)
        {
            passwordTextField.isSecureTextEntry = true
            button.setImage(UIImage(named: "eyes_off"), for: .normal)
            control = 0
        }

    }
    
    
    @IBAction func loginClick(_ sender: Any) {
        
        if emailTextField.text == "" || passwordTextField.text == ""
        {
            alert(title: "Hata", message: "E-mail / Parola giriniz")
        }
        else
        {
            Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { authDataResult, error in
                if error != nil
                {
                    self.alert(title: "Hata", message: error!.localizedDescription)
                }
                else
                {
                    self.performSegue(withIdentifier: "toDetailVC", sender: nil)
                }
            }
        }
        
    }
    
        
    @IBAction func signClick(_ sender: Any) {
        performSegue(withIdentifier: "toSignInVC", sender: nil)
    }
    

}


