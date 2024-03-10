//
//  GelirViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 12.05.2023.
//

import UIKit
import Firebase

class GelirViewController: UIViewController,UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var GelirMiktarı = ""
    var GelirAdı = ""
    var Tarih = Date()
    var GelirTipi = ""
    var indeks = -1
    
    @IBOutlet weak var MiktarTextField: UITextField!
    @IBOutlet weak var AdTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var saveButton: UIButton!
    var control = Timer()
    var selectedValue : Int!
    var gelir :[[String : Any]] = []
    let currentDate = Date()
    let calendar = Calendar.current
    
    var days = [28]
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        MiktarTextField.text = GelirMiktarı
        AdTextField.text = GelirAdı
        datePicker.date = Tarih
        if (GelirTipi == "Freelance"){
            imageViewTapped1()
        }
        else if (GelirTipi == "Kira"){
            imageViewTapped2()
        }
        else if (GelirTipi == "Maaş"){
            imageViewTapped3()
        }
        else if (GelirTipi == "Diğer"){
            imageViewTapped4()
        }
        
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
                
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        MiktarTextField.delegate = self
        AdTextField.delegate = self
 
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tapGesture)
                
        self.navigationController?.view.tintColor = UIColor.secondaryLabel

        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
                
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
        
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped1))
        img1.addGestureRecognizer(tapGesture1)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped2))
        img2.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped3))
        img3.addGestureRecognizer(tapGesture3)
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped4))
        img4.addGestureRecognizer(tapGesture4)
        
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
        if (MiktarTextField.text != "" && AdTextField.text != "" && (img1.tintColor != .secondaryLabel || img2.tintColor != .secondaryLabel || img3.tintColor != .secondaryLabel || img4.tintColor != .secondaryLabel) )
        {
            saveButton.isEnabled = true
        }
        
        else
        {
            saveButton.isEnabled = false
        }
        
    }
    
    
    @objc func imageViewTapped1() {
        img1.tintColor = hexStringToUIColor(hex: "993135")
        img2.tintColor = .secondaryLabel
        img3.tintColor = .secondaryLabel
        img4.tintColor = .secondaryLabel
    }
    @objc func imageViewTapped2() {
        img2.tintColor = hexStringToUIColor(hex: "993135")
        img1.tintColor = .secondaryLabel
        img3.tintColor = .secondaryLabel
        img4.tintColor = .secondaryLabel
    }
    @objc func imageViewTapped3() {
        img3.tintColor = hexStringToUIColor(hex: "993135")
        img1.tintColor = .secondaryLabel
        img2.tintColor = .secondaryLabel
        img4.tintColor = .secondaryLabel
    }
    @objc func imageViewTapped4() {
        img4.tintColor = hexStringToUIColor(hex: "993135")
        img1.tintColor = .secondaryLabel
        img2.tintColor = .secondaryLabel
        img3.tintColor = .secondaryLabel
    }
    
    @IBAction func KaydetClicked(_ sender: Any) {
        
        let uid = UUID().uuidString
        var GelirTipi = ""
        if (img1.tintColor == hexStringToUIColor(hex: "993135")){
            GelirTipi = "Freelance"
        }
        else if(img2.tintColor == hexStringToUIColor(hex: "993135")){
            GelirTipi = "Kira"
        }
        else if(img3.tintColor == hexStringToUIColor(hex: "993135")){
            GelirTipi = "Maaş"
        }
        else{
            GelirTipi = "Diğer"
        }
        
        if (indeks == -1){
            gelir.append(["Miktar" : MiktarTextField.text!, "Çeşit" : "GELİR" , "Gelir Getiren Kurum" : AdTextField.text!, "Tarih" : datePicker.date, "GelirTipi" : GelirTipi, "ID" : uid])
            db.collection("Finance").document(Auth.auth().currentUser!.uid).setData(
                ["Hareketler" : self.gelir]
            ) { err in
                if let err = err {
                    print("ERROR: \(err.localizedDescription)")
                    self.alert(title: "Hata", message: "Daha sonra tekrar deneyiniz")
                }
                else{
                    self.alert(title: "Kayıt işlemi başarılı", message: "Kazancınız sisteme kaydedilmiştir.")
                }
            }
        }
        
        else {
            gelir[indeks] = ["Miktar" : MiktarTextField.text!, "Çeşit" : "GELİR" , "Gelir Getiren Kurum" : AdTextField.text!, "Tarih" : datePicker.date, "GelirTipi" : GelirTipi, "ID" : uid]
            
            db.collection("Finance").document(Auth.auth().currentUser!.uid).setData(
                ["Hareketler" : self.gelir]
            ) { err in
                if let err = err {
                    print("ERROR: \(err.localizedDescription)")
                    self.alert(title: "Hata", message: "Daha sonra tekrar deneyiniz")
                }
                else{
                    self.alert(title: "Güncelleme işlemi başarılı", message: "Gelir işleminiz güncellenmiştir.")
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
    
    @objc func getData(){
                
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
                
        let docRef = Firestore.firestore().collection("Finance").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data()
                if var items = docData?["Hareketler"] as? [[String: Any]] {
                    self.gelir = items
                    docRef.setData( ["Hareketler" : self.gelir])
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

