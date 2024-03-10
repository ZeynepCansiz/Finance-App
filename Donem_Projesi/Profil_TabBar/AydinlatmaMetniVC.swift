//
//  AydinlatmaMetniVC.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 19.04.2023.
//

import UIKit

class AydinlatmaMetniVC: UIViewController {

    @IBOutlet weak var textField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
        self.tabBarController?.tabBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
        
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationItem.title = "AYDINLATMA METNİ"
        
        self.textField.text = load(file: "aydinlatma_metni")

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
    

    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0))
    }
    
}
