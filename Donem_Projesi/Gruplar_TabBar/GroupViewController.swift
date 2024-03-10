//
//  GroupViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 28.04.2023.
//

import UIKit
import Contacts
import ContactsUI

class GroupViewController: UIViewController, CNContactPickerDelegate {

    @IBOutlet weak var newMessageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    @IBAction func newMessageButtonClicked(_ sender: Any) {
        let vc = CNContactPickerViewController()
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("\n\n \(contact)")
    }
    

}
