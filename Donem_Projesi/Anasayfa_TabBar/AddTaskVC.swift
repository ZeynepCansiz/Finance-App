//
//  AddTaskVC.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 29.04.2023.
//

import UIKit
import DropDown
import Firebase

class AddTaskVC: UIViewController {
    
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var img5: UIImageView!
    @IBOutlet weak var kurumTextField: UITextField!
    @IBOutlet weak var kategoriTextField: UITextField!
    @IBOutlet weak var ucretTextField: UITextField!
    @IBOutlet weak var dateField: UIDatePicker!
    @IBOutlet weak var saveButton: UIButton!
    var notlar :[[String : Any]] = []
    var control = Timer()
    
    let menu : DropDown = {
        let menu = DropDown()
        menu.dataSource = [
            "Eğlence",
            "Sağlık",
            "Ulaşım",
            "Gıda",
            "Diğer"
        ]
        
        let images = [
            "party.popper.fill",
            "bolt.heart.fill",
            "car",
            "fork.knife.circle.fill",
            "rectangle.and.pencil.and.ellipsis",
        ]
        
        
        menu.cellNib = UINib(nibName: "DropDownCell", bundle: nil)
        menu.customCellConfiguration = {index, title, cell in
            guard let cell = cell as? MyCell else {
                return
            }
            cell.myImageView.image = UIImage(systemName: images[index])
            cell.myImageView.image!.withRenderingMode(.alwaysTemplate)
            cell.myImageView.tintColor = .secondaryLabel
        }
        
        return menu
    }()
    
    
    override func viewDidLoad() {
    
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let notID = document.get("NotID") as! String

                let docRef = db.collection("Notes").document(notID)
                docRef.getDocument { (document, error) in
                  if let document = document, document.exists {
                    let data = document.data()
                    if let arrayData = data?["Not"] as? [[String: Any]] {

                        if document.data() != nil {

                            for mapData in arrayData {
                                self.notlar.append(mapData)
                            }
                        }else{
                            print("sıkıntı")
                        }

                    }
                  } else {
                    print("Belge bulunamadı: \(error?.localizedDescription ?? "Hata yok")")
                  }
                }
            }
        }
        
        controlStart()
        self.navigationController?.view.tintColor = UIColor.secondaryLabel
        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        img1?.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
        img1?.clipsToBounds = true
        img1?.layer.borderWidth = 3.0
        img1?.layer.borderColor = UIColor.clear.cgColor
        
        img2?.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
        img2?.clipsToBounds = true
        img2?.layer.borderWidth = 3.0
        img2?.layer.borderColor = UIColor.clear.cgColor
        
        img3?.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
        img3?.clipsToBounds = true
        img3?.layer.borderWidth = 3.0
        img3?.layer.borderColor = UIColor.clear.cgColor
        
        img4?.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
        img4?.clipsToBounds = true
        img4?.layer.borderWidth = 3.0
        img4?.layer.borderColor = UIColor.clear.cgColor
        
        img5?.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
        img5?.clipsToBounds = true
        img5?.layer.borderWidth = 3.0
        img5?.layer.borderColor = UIColor.white.cgColor
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didClicked))
        kategoriTextField.addGestureRecognizer(gesture)
        menu.anchorView = kategoriTextField
        menu.selectionAction = {
            index, title in
            self.kategoriTextField.text = title
            
        }
        
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(tap_1))
        img1.isUserInteractionEnabled = true
        img1.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(tap_2))
        img2.isUserInteractionEnabled = true
        img2.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(tap_3))
        img3.isUserInteractionEnabled = true
        img3.addGestureRecognizer(tap3)
        let tap4 = UITapGestureRecognizer(target: self, action: #selector(tap_4))
        img4.isUserInteractionEnabled = true
        img4.addGestureRecognizer(tap4)
        let tap5 = UITapGestureRecognizer(target: self, action: #selector(tap_5))
        img5.isUserInteractionEnabled = true
        img5.addGestureRecognizer(tap5)
        
        self.dateField.minimumDate = Date() + 24*60*60

    }
    
    func controlStart()
    {
        control = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableFuncion), userInfo: nil, repeats: true)
    }
    
    @objc func enableFuncion()
    {
        if (kurumTextField.text != "" && kategoriTextField.text != "" && ucretTextField.text != "")
        {
            saveButton.isEnabled = true
        }
        
        else
        {
            saveButton.isEnabled = false
        }
        
    }
    
    @objc func didClicked(){
        menu.show()
    }
    
    @objc func tap_1(){
        kurumTextField.text = "Netflix"    }
    @objc func tap_2(){
        kurumTextField.text = "Spotify"    }
    @objc func tap_3(){
        kurumTextField.text = "Playstation"    }
    @objc func tap_4(){
        kurumTextField.text = "Xbox"    }
    @objc func tap_5(){
        kurumTextField.text = "Youtube"    }
    
    
    @IBAction func saveClicked(_ sender: Any) {
        
        let formatter = DateFormatter()
        formatter.calendar = dateField.calendar
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let dateString = formatter.string(from: dateField.date)
                
        var note = kurumTextField.text! + " kurumuna " + ucretTextField.text! + "₺ tutarında ödemeniz mevcuttur."
        
        notlar.append(["Not" : note, "Kategori" : kategoriTextField.text!, "SonOdemeTarihi" : dateField.date, "KayıtTarihi" : Date()])
        
        let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let notID = document.get("NotID") as! String
                db.collection("Notes").document(notID).setData(
                    ["Not" : self.notlar]
                )
                self.alert(title: "Kayıt işlemi başarılı", message: "Notunuz ay sonuna kadar panelinizde görünecektir.")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    func alert (title: String, message: String){
        let uyari = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Tamam", style: .default)
        uyari.addAction(okButton)
        self.present(uyari, animated: true)
        
    }
    
    
    
}
