//
//  GiderViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 12.05.2023.
//

import UIKit
import Firebase

class GiderViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var Tutar = ""
    var HarcamaAdi = ""
    var Tarih = Date()
    var indeks = -1 //datanın konumu için
    
    var tapGestureRecognizer = UITapGestureRecognizer()
    @IBOutlet weak var tutarTextField: UITextField!
    @IBOutlet weak var harcamaAdiTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    var imgTag : Int!
    var scTag : Int!
    var selectedValue : Int!
    var btnClicked = false
    var gider :[[String : Any]] = []
    var control = Timer()
    
    var days : [Int] = [28]
    
    var scView:UIScrollView!
    let buttonPadding:CGFloat = 15
    var xOffset:CGFloat = 20
    
    var image = ["flame.circle.fill", "bolt.circle.fill", "network", "drop.circle.fill", "iphone.circle.fill", "ellipsis.circle.fill"]
    var image2 = ["bag.circle.fill", "pawprint.circle.fill", "sofa.fill", "bolt.heart.fill", "cpu.fill", "ellipsis.circle.fill"]
    var image3 = ["netflix", "spotify", "ps", "xbox", "youtube","ellipsis.circle.fill"]
    
    var labelText = ["Doğalgaz","Elektrik","İnternet","Su","Telefon","Diğer"]
    var labelText2 = ["Alışveriş", "Dostlar", "Mobilya", "Sağlık", "Elektronik", "Diğer"]
    var labelText3 = ["Netflix", "Spotify", "Playstation", "Xbox", "Youtube", "Diğer"]
    var imageViewList : [UIImageView] = []
    
    let currentDate = Date()
    let calendar = Calendar.current
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        tutarTextField.text = Tutar
        harcamaAdiTextField.text = HarcamaAdi
        datePicker.date = Tarih
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        if (getDaysInMonth(year: currentYear , month: currentMonth) == 29){
            days.append(29)
        }
        else if (getDaysInMonth(year: currentYear , month: currentMonth) == 30){
            days.append(29)
            days.append(30)
        }
        else if (getDaysInMonth(year: currentYear , month: currentMonth) == 31){
            days.append(29)
            days.append(30)
            days.append(31)
        }
        
        tutarTextField.delegate = self
        harcamaAdiTextField.delegate = self

        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
            
        view.addGestureRecognizer(tapGesture)
        
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton

        
        scView = UIScrollView(frame: CGRect(x: 0, y: 635, width: view.bounds.width, height: 100))
            view.addSubview(scView)

            scView.backgroundColor = hexStringToUIColor(hex: "F2E2E4")
            scView.translatesAutoresizingMaskIntoConstraints = false

            for i in 0 ... 5 {
                                
                let label = UILabel()
                label.tag = i
                label.text = labelText[i]
                label.textAlignment = .center
                label.textColor = .secondaryLabel
                label.font = UIFont.systemFont(ofSize: 12)
                
                let button = UIButton()
                button.tag = i
                button.backgroundColor = UIColor.clear
                button.setBackgroundImage(UIImage(systemName: image[i]), for: .normal)
                button.tintColor = .secondaryLabel
                
                button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)

                button.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding), width: 60, height: 60)
                label.frame = CGRect(x: xOffset, y: CGFloat(buttonPadding) + 58, width: 60, height: 20)

                xOffset = xOffset + 10 + CGFloat(buttonPadding) + button.frame.size.width
                scView.addSubview(button)
                scView.addSubview(label)

            }
            scView.contentSize = CGSize(width: xOffset, height: scView.frame.height)
        
        imageViewList.append(img1)
        imageViewList.append(img2)
        imageViewList.append(img3)
        imageViewList.append(img4)
        
        for (index,imageView) in imageViewList.enumerated() {
            imageView.layer.cornerRadius = (img1?.frame.size.width ?? 0.0) / 2
            imageView.clipsToBounds = true
            imageView.layer.borderWidth = 3.0
            imageView.layer.borderColor = UIColor.clear.cgColor
            imageView.tag = index
            
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))

            imageView.addGestureRecognizer(tapGestureRecognizer)
        }
        let components = calendar.dateComponents([.year, .month], from: currentDate)
        guard let currentYear = components.year, let currentMonth = components.month else {
            return
        }

        var firstDayComponents = DateComponents()
        firstDayComponents.year = currentYear
        firstDayComponents.month = currentMonth
        firstDayComponents.day = 1

        var lastDayComponents = DateComponents()
        lastDayComponents.year = currentYear
        lastDayComponents.month = currentMonth
        lastDayComponents.day = days.last
        
        guard let firstDayOfMonth = calendar.date(from: firstDayComponents) else {
            return
        }
        
        guard let lastDayOfMonth = calendar.date(from: lastDayComponents) else {
            return
        }
        
        datePicker.minimumDate = firstDayOfMonth
        datePicker.maximumDate = lastDayOfMonth

        controlStart()
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true) // Klavyeyi kapat
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return days.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(days[row])"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = pickerView.selectedRow(inComponent: component)
    }
    
    func controlStart()
    {
        control = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(enableFuncion), userInfo: nil, repeats: true)
    }
    
    @objc func enableFuncion()
    {
        if (tutarTextField.text != "" && harcamaAdiTextField.text != "" && (imgTag == 0 || imgTag == 1 || imgTag == 2 || imgTag == 3) && btnClicked == true)
        {
            saveButton.isEnabled = true
        }
        
        else
        {
            saveButton.isEnabled = false
        }
    }
    
        
    @objc func imageViewTapped(_ sender: UITapGestureRecognizer) {
        btnClicked = false
        guard let tappedImageView = sender.view as? UIImageView else { return }
        
        
        for subview in view.subviews {
            if let imageView = subview as? UIImageView {
                if imageView.tag == tappedImageView.tag {
                    imageView.layer.borderColor = hexStringToUIColor(hex: "993135").cgColor
                } else {
                    imageView.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        
        
        for subview in scView.subviews {
            if let button = subview as? UIButton {
                if tappedImageView.tag == 0{
                    imgTag = 0
                    for i in 0...5{
                        if button.tag == i {
                            button.setBackgroundImage(UIImage(systemName: image[i]), for: .normal)
                            button.layer.borderColor = UIColor.clear.cgColor
                            button.tintColor = .secondaryLabel
                        }
                    }
                }
                else if tappedImageView.tag == 1{
                    imgTag = 1
                    for i in 0...5{
                        if button.tag == i {
                            button.setBackgroundImage(UIImage(systemName: image2[i]), for: .normal)
                            button.layer.borderColor = UIColor.clear.cgColor
                            button.tintColor = .secondaryLabel
                        }
                    }
                }
                else if tappedImageView.tag == 2{
                    imgTag = 2
                    for i in 0...5{
                        if button.tag == i {
                            button.layer.cornerRadius = button.frame.width / 2
                            button.layer.masksToBounds = true
                            button.layer.borderWidth = 3.0
                            button.layer.borderColor = UIColor.clear.cgColor
                            button.tintColor = .secondaryLabel
                            if i != 5 {
                                button.setBackgroundImage(UIImage(named: image3[i]), for: .normal)
                            }
                            else{
                                button.setBackgroundImage(UIImage(systemName: image3[i]), for: .normal)
                            }
                        }
                    }
                }
                else if tappedImageView.tag == 3{
                    imgTag = 3
                    if (button.tag == 5) {
                        button.layer.borderColor = hexStringToUIColor(hex: "993135").cgColor
                        button.tintColor = hexStringToUIColor(hex: "993135")
                        }
                        if (button.tag != 5){
                            button.layer.borderColor = UIColor.clear.cgColor
                            button.tintColor = .secondaryLabel
                        }
                        btnClicked = true
                    }
                }
            
            if let label = subview as? UILabel{
                
                if tappedImageView.tag == 0{
                for i in 0...5{
                    if label.tag == i {
                        label.text = labelText[i]
                        }
                    }
                }
                else if tappedImageView.tag == 1{
                for i in 0...5{
                    if label.tag == i {
                        label.text = labelText2[i]
                        }
                    }
                }
                else if tappedImageView.tag == 2{
                for i in 0...5{
                    if label.tag == i {
                        label.text = labelText3[i]
                        }
                    }
                }
            }
        }
    }

    
    @objc func buttonClicked(_ sender: UIButton){
        
        for button in scView.subviews where button is UIButton {
            (button as? UIButton)?.tintColor = .secondaryLabel
            (button as? UIButton)?.layer.borderColor = UIColor.clear.cgColor
            btnClicked = false
            }
        sender.tintColor = hexStringToUIColor(hex: "993135")
        sender.layer.borderColor = hexStringToUIColor(hex: "993135").cgColor
        scTag = sender.tag
        btnClicked = true
        
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
    
    
    @IBAction func saveClicked(_ sender: Any) {
        
        var GiderTipi = ""
        var GiderTürü = ""
        let uid = UUID().uuidString
                
        if (imgTag == 0){
            GiderTipi = "Fatura"
            GiderTürü = labelText[scTag]
        }
        else if(imgTag == 1){
            GiderTipi = "Fiş"
            GiderTürü = labelText2[scTag]
        }
        else if(imgTag == 2){
            GiderTipi = "Üyelik"
            GiderTürü = labelText3[scTag]
        }
        else{
            GiderTipi = "Diğer"
            GiderTürü = "Diğer"
        }
                
        
        if (indeks == -1){
                               
            gider.append(["Miktar" : tutarTextField.text!, "Harcama Adı" : harcamaAdiTextField.text!, "Çeşit" : "GİDER", "Tarih" : datePicker.date,  "GiderTipi" : GiderTipi, "GiderTürü" : GiderTürü, "ID" : uid ])
                    
                    
            db.collection("Finance").document(Auth.auth().currentUser!.uid).setData(
                ["Hareketler" : self.gider]
            ) { err in
                if let err = err {
                    print("ERROR: \(err.localizedDescription)")
                    self.alert(title: "Hata", message: "Daha sonra tekrar deneyiniz")
                }
                else{
                    self.alert(title: "Kayıt işlemi başarılı", message: "Harcamanız sisteme kaydedilmiştir.")
                }
            }
        }
        
        else {
            gider[indeks] = ["Miktar" : tutarTextField.text!, "Harcama Adı" : harcamaAdiTextField.text!, "Çeşit" : "GİDER", "Tarih" : datePicker.date,  "GiderTipi" : GiderTipi, "GiderTürü" : GiderTürü, "ID" : uid ]
            
            db.collection("Finance").document(Auth.auth().currentUser!.uid).setData(
                ["Hareketler" : self.gider]
            ) { err in
                if let err = err {
                    print("ERROR: \(err.localizedDescription)")
                    self.alert(title: "Hata", message: "Daha sonra tekrar deneyiniz")
                }
                else{
                    self.alert(title: "Güncelleme işlemi başarılı", message: "Harcama işleminiz güncellenmiştir.")
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
    
        
    @objc func getData(){
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
                        
        let docRef = Firestore.firestore().collection("Finance").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data()
                if var items = docData?["Hareketler"] as? [[String: Any]] {
                    self.gider = items
                    docRef.setData( ["Hareketler" : self.gider])
                }
            }
        }
    }
  
    func getDaysInMonth(year: Int, month: Int) -> Int? {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: year, month: month)
        guard let date = calendar.date(from: dateComponents) else { return nil }
        let range = calendar.range(of: .day, in: .month, for: date)
        return range?.count
        
    }
    
}
