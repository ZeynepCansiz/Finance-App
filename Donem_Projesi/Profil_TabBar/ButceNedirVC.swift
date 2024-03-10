//
//  ButceNedirVC.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 10.04.2023.
//

import UIKit

class ButceNedirVC: UIViewController {
    
    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationItem.title = "Bü₺çe Nedir?"
        
        self.textField.text = load(file: "tanitim")
    }
    
   
    func load(file name:String) -> String {

            if let path = Bundle.main.path(forResource: name, ofType: "txt") {

                if let contents = try? String(contentsOfFile: path) {

                    return contents

                } else {

                    print("Error! - This file doesn't contain any text.")
                }

            } else {

                print("Error! - This file doesn't exist.")
            }

            return ""
        }
}
