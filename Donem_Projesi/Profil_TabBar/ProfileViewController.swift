//
//  ProfileViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 15.03.2023.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let user = Auth.auth().currentUser
        let docRef = db.collection("Users").document(user!.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let fotograf = document.get("GorselURL")
                self.imageView.image = UIImage(data: fotograf as! Data)
            } else {
                print("Document does not exist")
            }
        }
        
    }
        
    @IBAction func appStoreClicked(_ sender: Any) {
        if let url = URL(string: "https://www.apple.com/tr/app-store/") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func exitClicked(_ sender: Any) {
        do
        {
            try Auth.auth().signOut()
            performSegue(withIdentifier: "toViewController", sender: nil)
        }
        catch
        {
            print("ERROR")
        }
    }

}
