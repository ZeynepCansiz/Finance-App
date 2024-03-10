//
//  SignInViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 16.03.2023.
//

import UIKit
import Firebase

class SignInViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var AlanKodu: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var secondPassword: UITextField!
    @IBOutlet weak var genderButton: UISegmentedControl!
    @IBOutlet weak var signButton: UIButton!
    var control = Timer()
    var code_controller : Bool!
    var telefonlar : [String] = []
    
    @IBOutlet weak var smsYolla: UIButton!
    @IBOutlet weak var smsTextField: UITextField!
    
//    HATA MESAJLARINI TÜRKÇEYE ÇEVİR -- Örnek uygulamalarda buna dikkat edilmemiş
    
    override func viewWillAppear(_ animated: Bool) {
        telefon()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlStart()
        nameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        nameTextField.autocorrectionType = UITextAutocorrectionType.no
        surnameTextField.borderStyle = UITextField.BorderStyle.roundedRect
        surnameTextField.autocorrectionType = UITextAutocorrectionType.no
        AlanKodu.borderStyle = UITextField.BorderStyle.roundedRect
        phoneTextField.borderStyle = UITextField.BorderStyle.roundedRect
        smsTextField.borderStyle = UITextField.BorderStyle.roundedRect
        emailTextField.borderStyle = UITextField.BorderStyle.roundedRect
        emailTextField.autocorrectionType = UITextAutocorrectionType.no
        passwordTextField.borderStyle = UITextField.BorderStyle.roundedRect
        secondPassword.borderStyle = UITextField.BorderStyle.roundedRect
        
//        imageView?.layer.cornerRadius = (imageView?.frame.size.width ?? 0.0) / 2
//        imageView?.clipsToBounds = true
//        imageView?.layer.borderWidth = 3.0
//        imageView?.layer.borderColor = UIColor.white.cgColor

    }
    
    func controlStart()
    {
        control = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableFuncion), userInfo: nil, repeats: true)
    }
    
    @objc func enableFuncion() //Bütün alanlar doluysa kaydol butonu enable oluyor
    {
        if (nameTextField.text != "" && surnameTextField.text != "" && AlanKodu.text != "" && phoneTextField.text != "" && smsTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" && secondPassword.text != "" )
        {
            signButton.isEnabled = true
        }
        
        else
        {
            signButton.isEnabled = false
        }

    }
    
    func alert (title: String, message: String) //Kaydol butonuna basıldığında mesaj veriliyor
    {
        let uyari = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Tamam", style: .default)
        uyari.addAction(okButton)
        self.present(uyari, animated: true)
    }
    
    func isValidEmail(_ email: String) -> Bool //Email'in doğru olup olmadığı kontrolü
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    
    @IBAction func genderClicked(_ sender: Any)
    {
        if(genderButton.selectedSegmentIndex == 0)
        {
            imageView.image = UIImage(named: "female")
        }
        else
        {
            imageView.image = UIImage(named: "male")
        }
    }
    
    @IBAction func SignClicked(_ sender: Any)
    {
        if(passwordTextField.text != secondPassword.text)
        {
            alert(title: "Hata", message: "Şifreler uyuşmuyor")
        }
        
        else if(isValidEmail(emailTextField.text!) == false)
        {
            alert(title: "Hata", message: "Geçerli bir e-mail adresi giriniz")
        }
        else if(passwordTextField.text!.count < 6 || secondPassword.text!.count < 6)
        {
            alert(title: "Hata", message: "6 karakterden daha az uzunlukta şifre oluşturamazsınız")
        }
        
        else //Kullanıcı Kayıt Ediliyor
        {
            
            self.verifyCode(smsCode: self.smsTextField.text!) { success in
                guard success else
                {
                    self.code_controller = false
                    self.alert(title: "Hata", message: "Doğrulama kodu hatalı")
                    return
                }
                self.code_controller = true
                
                Auth.auth().createUser(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authDataResult, Error in
                if (Error != nil)
                {
                    self.alert(title: "Hata", message: Error!.localizedDescription)
                }
                else
                {
                    let storage = Storage.storage()
                    let storageRef = Storage.storage().reference()
                    let mediaFolder = storageRef.child("media")
                    
                    if let data = self.imageView.image?.jpegData(compressionQuality: 0.5){
                        let imageRef = mediaFolder.child(Auth.auth().currentUser!.uid)
                        imageRef.putData(data) { StorageMetadata, error in
                            if error != nil{
                                print("Error:" + error!.localizedDescription)
                                self.alert(title: "Hata", message: "Görsel yüklenemedi, daha sonra tekrar deneyiniz.")
                                
                            }
                            else{
                                imageRef.downloadURL { url, error in
                                    if error == nil {
                                        let imageUrl = url?.absoluteString
                                        print(imageUrl!)
                                    }
                                }
                            }
                        }
                    }
                    
                    db.collection("Users").document(Auth.auth().currentUser!.uid).setData([
                        "Ad": self.nameTextField.text!,
                        "Soyad": self.surnameTextField.text!,
                        "Mail": self.emailTextField.text!,
                        "Telefon": self.AlanKodu.text! + self.phoneTextField.text!,
                        "GorselURL": self.imageView.image?.jpegData(compressionQuality: 0.5)
                    ]) { err in
                        if let err = err {
                            print("ERROR writing document: \(err)")
                        } else {
                            
                        }
                    }
                    
                    let alert = UIAlertController(title: "Tebrikler", message: "Kayıt işlemi başarılı", preferredStyle: .alert)

                    alert.addAction(UIAlertAction(title: "Giriş ekranına dön", style: .default, handler: { (action) in
                        self.performSegue(withIdentifier: "toFirstVC", sender: self)
                    
                    }))
                    self.present(alert, animated: true)
                    
                }
                    
                }
                
            }
        }
    }

    
    @IBAction func smsClicked(_ sender: Any) {

        let phoneNumber = AlanKodu.text! + phoneTextField.text!
        
        if(self.telefonlar.contains(phoneNumber))
        {
            self.alert(title: "Hata", message: "Telefon numarası kullanılmaktadır!")
            return
        }

        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) {
            verificationID, error in
              if let error = error {
                  if(self.AlanKodu.text == "")
                  {
                      self.alert(title: "Hata", message: "Alan kodunu giriniz")
                  }
                  else if(self.phoneTextField.text == "" )
                  {
                      self.alert(title: "Hata", message: "Telefon numarasını giriniz")
                  }
                  else if(self.phoneTextField.text!.count > 11 || self.phoneTextField.text!.count < 10)
                  {
                      self.alert(title: "Hata", message: "Telefon numarasını düzeltiniz")
                  }
                  else
                  {
                      self.alert(title: "ERROR", message: error.localizedDescription)
                  }
                return
              }

            self.smsTextField.isEnabled = true
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
        
    }

    
    public func verifyCode(smsCode: String, completion: @escaping (Bool) -> Void)
    {
        let verificationIDD = UserDefaults.standard.string(forKey: "authVerificationID")
        guard verificationIDD != nil else {
            completion(false)
            return
        }

        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationIDD!,
            verificationCode: smsCode)

        Auth.auth().signIn(with: credential) {result, error in
            guard result != nil, error == nil else {
                completion(false)
                return
            }
            
            completion(true)
        }

    }
    
    @objc func telefon(){
        let usersCollection = db.collection("Users")

        usersCollection.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching documents: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("Bulunamadı")
                return
            }
            
            self.telefonlar.removeAll()
            for document in documents {
                let phoneNumber = document.data()["Telefon"] as? String
                self.telefonlar.append(phoneNumber!)
            }
            print(self.telefonlar)
        }
    }
        
    

}


