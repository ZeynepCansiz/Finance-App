//
//  ProfileEditingVC.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 19.04.2023.
//

import UIKit
import Firebase


class ProfileEditingVC: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var mailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    let user = Auth.auth().currentUser
    var control = Timer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        control = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableFuncion), userInfo: nil, repeats: true)
        
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        nameTextField.autocorrectionType = UITextAutocorrectionType.no
        surnameTextField.autocorrectionType = UITextAutocorrectionType.no
        PasswordTextField.autocorrectionType = UITextAutocorrectionType.no
        mailTextField.autocorrectionType = UITextAutocorrectionType.no
        
        
        let docRef = db.collection("Users").document(user!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                let fotograf = document.get("GorselURL")
                self.imageView.image = UIImage(data: fotograf as! Data)
                let Ad = document.get("Ad") as! String
                self.nameTextField.text = Ad
                let Soyad = document.get("Soyad") as! String
                self.surnameTextField.text = Soyad
                let Mail = document.get("Mail") as! String
                self.mailTextField.text = Mail
                let Telefon = document.get("Telefon") as! String
                self.phoneTextField.text = Telefon

            } else {
                print("Document does not exist")
            }
        }
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gorselSec))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
    
    @objc func gorselSec()
    {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.editedImage] as? UIImage
        self.dismiss(animated: true)
    }
        
    @objc func enableFuncion() 
    {
        if (PasswordTextField.text != "")
        {
            saveButton.isEnabled = true
        }
        
        else
        {
            saveButton.isEnabled = false
        }

    }
    
    
    @IBAction func SaveClicked(_ sender: Any) {
        
        if(mailTextField.text != "" && isValidEmail(mailTextField.text!) != true){
            alert(title: "hata", message: "mail")
        }
        else{
            
            let credential = EmailAuthProvider.credential(withEmail: (user?.email)!, password: PasswordTextField.text!)
            
            user?.reauthenticate(with: credential)
        { data,error  in
            if error != nil {
                print("ERR" + error!.localizedDescription)
                self.alert(title: "Hata", message: "Kullanıcı doğrulanamadı, bilgilerinizi kontrol edip tekrar deneyiniz.")
            } else {
                
                self.user?.updateEmail(to: self.mailTextField.text!)
                
                db.collection("Users").document(self.user!.uid).updateData([
                    "Ad": self.nameTextField.text!,
                    "Soyad": self.surnameTextField.text!,
                    "Mail": self.mailTextField.text!.lowercased(),
                    "GorselURL": self.imageView.image?.jpegData(compressionQuality: 0.5)!
                ]) { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                        self.alert(title: "Hata", message: "Bilgilerinizi kontrol edip tekrar deneyiniz.")
                        
                    } else{
                    }
                }
                
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
                
                self.alert(title: "Tebrikler", message: "Değişiklikler kaydedildi.")
            }
        }
    }
    }
    
    
    func alert (title: String, message: String){
        let uyari = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Tamam", style: .default)
        uyari.addAction(okButton)
        self.present(uyari, animated: true)
        
    }
    
    func isValidEmail(_ email: String) -> Bool //Email'in geçerli olup olmadığı kontrolü
    {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
}
