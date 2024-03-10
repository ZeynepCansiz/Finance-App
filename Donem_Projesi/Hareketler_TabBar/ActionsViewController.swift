//
//  ActionsViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 15.03.2023.
//

import UIKit
import Firebase

class ActionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // API EKLE
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var label: UILabel!
    var data: [Any] = []
    var data_son1Ay : [Any] = []
    var data_son3Ay : [Any] = []
    var data_son1Yıl : [Any] = []
    var son1Ay = false
    var son3Ay = false
    var son1Yıl = false
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
        
        if (son1Ay == true){
            
            self.data_son1Ay.removeAll()

            let calendar = Calendar.current
            let today = Date()
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: today) else { return }

            let docRef = db.collection("Finance").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let docData = document.data()
                    if var items = docData?["Hareketler"] as? [[String: Any]] {
                        for item in items {
                            if let tarih = item["Tarih"] as? Timestamp {
                                let sonOdemeTarihi = tarih.dateValue()
                                if sonOdemeTarihi >= oneMonthAgo && sonOdemeTarihi <= today{
                                    self.data_son1Ay.append(item)
                                    }
                            }
                            else{
                                print("girmedi")
                            }
                        }
                    }
                }
            }
        }
        
        else if (son3Ay == true){
            
            self.data_son3Ay.removeAll()

            let calendar = Calendar.current
            let today = Date()
            guard let threeMonthAgo = calendar.date(byAdding: .month, value: -3, to: today) else { return }

            let docRef = db.collection("Finance").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let docData = document.data()
                    if var items = docData?["Hareketler"] as? [[String: Any]] {
                        for item in items {
                            if let tarih = item["Tarih"] as? Timestamp {
                                let sonOdemeTarihi = tarih.dateValue()
                                if sonOdemeTarihi >= threeMonthAgo && sonOdemeTarihi <= today{
                                    self.data_son3Ay.append(item)
                                    }
                            }
                            else{
                                print("girmedi")
                            }
                        }
                    }
                }
            }
        }
        
        else if (son1Yıl == true){
            
            self.data_son1Yıl.removeAll()

            let calendar = Calendar.current
            let today = Date()
            guard let oneYearsAgo = calendar.date(byAdding: .year, value: -1, to: today) else { return }

            let docRef = db.collection("Finance").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let docData = document.data()
                    if var items = docData?["Hareketler"] as? [[String: Any]] {
                        for item in items {
                            if let tarih = item["Tarih"] as? Timestamp {
                                let sonOdemeTarihi = tarih.dateValue()
                                if sonOdemeTarihi >= oneYearsAgo && sonOdemeTarihi <= today{
                                    self.data_son1Yıl.append(item)
                                    }
                            }
                            else{
                                print("girmedi")
                            }
                        }
                    }
                }
            }
        }
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        tableView.delegate = self
        tableView.dataSource = self
        
        
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
        self.tabBarController?.tabBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(son1Ay == true){
            return data_son1Ay.count
        }
        else if(son3Ay == true){
            return data_son3Ay.count
        }
        else if (son1Yıl == true){
            return data_son1Yıl.count
        }
        else{
            return data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ActionsCell
        
        if(son1Ay == true){
            data = data_son1Ay
            label.text = "Son 1 Ay"
        }else if(son3Ay == true){
            data = data_son3Ay
            label.text = "Son 3 Ay"
        }else if(son1Yıl == true){
            data = data_son1Yıl
            label.text = "Son 1 Yıl"
        }else{
            label.text = "Tüm Hareketleriniz"
        }
        
        if let map = data[ data.count - indexPath.row - 1] as? [String: Any],
           let tür = map["Çeşit"] as? String {
            
            if (tür == "GİDER"){
                
                if let ad = map["Harcama Adı"] as? String,
                let tip = map["GiderTipi"] as? String,
                let tür = map["GiderTürü"] as? String,
                let miktar =  map["Miktar"] as? String,
                let tarih = map["Tarih"] as? Timestamp
                {
                    let ad_ozellik = [ NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "B01A10"), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0) ]
                    let yeni_ad = NSAttributedString(string: ad, attributes: ad_ozellik)
                                    
                    let spaceString = NSAttributedString(string: "\n")
                    
                    var yazı = tip + " / " + tür
                    let yazı_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0) ]
                    let yeni_yazı = NSAttributedString(string: yazı, attributes: yazı_ozellik)
                    
                    var yazı_2 = " türünde " + miktar + "₺  tutarında harcama yapıldı"
                    let yazı2_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0) ]
                    let yeni_yazı2 = NSAttributedString(string: yazı_2, attributes: yazı2_ozellik)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let dateString = dateFormatter.string(from: tarih.dateValue())
                    let tarih = NSAttributedString(string: dateString, attributes: yazı2_ozellik)
       
                    let text = NSMutableAttributedString()
                    text.append(yeni_ad)
                    text.append(spaceString)
                    text.append(yeni_yazı)
                    text.append(yeni_yazı2)
                    text.append(spaceString)
                    text.append(spaceString)
                    text.append(tarih)
                                    
                    cell.label.attributedText = text
                }
            }
            
            if (tür == "GELİR"){
                
                if let ad = map["Gelir Getiren Kurum"] as? String,
                let tip = map["GelirTipi"] as? String,
                let miktar =  map["Miktar"] as? String,
                let tarih = map["Tarih"] as? Timestamp
                {
                    
                    let ad_ozellik = [ NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "499B4F"), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0) ]
                    let yeni_ad = NSAttributedString(string: ad, attributes: ad_ozellik)
                                    
                    let spaceString = NSAttributedString(string: "\n")
                    
                    let yazı_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0) ]
                    let yeni_yazı = NSAttributedString(string: tip, attributes: yazı_ozellik)
                    
                    var yazı_2 = " türünde " + miktar + "₺  tutarında gelir elde edildi."
                    let yazı2_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18.0) ]
                    let yeni_yazı2 = NSAttributedString(string: yazı_2, attributes: yazı2_ozellik)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    let dateString = dateFormatter.string(from: tarih.dateValue())
                    let tarih = NSAttributedString(string: dateString, attributes: yazı2_ozellik)

                    let text = NSMutableAttributedString()
                    text.append(yeni_ad)
                    text.append(spaceString)
                    text.append(yeni_yazı)
                    text.append(yeni_yazı2)
                    text.append(spaceString)
                    text.append(spaceString)
                    text.append(tarih)

                    cell.label.attributedText = text
                }
            }
        }
        return cell
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let indexPath = tableView.indexPathForSelectedRow
        
        if segue.identifier == "toGiderVC" {
            if let destinationVC = segue.destination as? GiderViewController {
                if let map = data[ data.count - indexPath!.row - 1] as? [String: Any],
                   let tür = map["Çeşit"] as? String{
                    if (tür == "GİDER"){
                        
                        if let ad = map["Harcama Adı"] as? String,
//                           let tip = map["GiderTipi"] as? String,
//                           let tür = map["GiderTürü"] as? String,
                           let miktar =  map["Miktar"] as? String,
                           let tarih = map["Tarih"] as? Timestamp{
                            destinationVC.Tutar = miktar
                            destinationVC.HarcamaAdi = ad
                            destinationVC.Tarih = tarih.dateValue()
//                            destinationVC.GiderTipi = tip
//                            destinationVC.GiderTürü = tür
                            destinationVC.indeks = data.count - indexPath!.row - 1
                            
                        }
                    }
                }
            }
        }
        
        else if segue.identifier == "toGelirVC" {
            if let destinationVC = segue.destination as? GelirViewController {
                if let map = data[ data.count - indexPath!.row - 1] as? [String: Any]
                {
                    if let ad = map["Gelir Getiren Kurum"] as? String,
                    let tip = map["GelirTipi"] as? String,
                    let miktar =  map["Miktar"] as? String,
                    let tarih = map["Tarih"] as? Timestamp{
                    destinationVC.GelirMiktarı = miktar
                    destinationVC.GelirAdı = ad
                    destinationVC.Tarih = tarih.dateValue()
                    destinationVC.GelirTipi = tip
                    destinationVC.indeks = data.count - indexPath!.row - 1
                            
                    }
                }
            }
        }
    }

        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let map = data[ data.count - indexPath.row - 1] as? [String: Any],
        let tür = map["Çeşit"] as? String{
            if (tür == "GİDER"){
                performSegue(withIdentifier: "toGiderVC", sender: nil)
                
            }
            else if (tür == "GELİR"){
                performSegue(withIdentifier: "toGelirVC", sender: nil)
                
            }
        }
    }
    
    
    @IBAction func listButtonClicked(_ sender: Any) {
        alert(title: "", message: "Hangi zaman aralığında listeleme yapmak istiyorsunuz?")
    }
    
    @objc func getData(){
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let docRef = db.collection("Finance").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let docData = document.data()
                        if var items = docData?["Hareketler"] as? [[String: Any]] {
                            self.data = items
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func alert (title: String, message: String){
        let uyari = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let iptal = UIAlertAction(title: "İptal", style: .cancel)
        let tumHareketler = UIAlertAction(title: "Tüm Hareketler", style: .default)
        { _ in
                        
            self.son1Ay = false
            self.son3Ay = false
            self.son1Yıl = false
            
            self.getData()
            
            self.viewWillAppear(true)
        }
        let son1 = UIAlertAction(title: "Son 1 Ay", style: .default)
        { _ in
            
            self.son1Ay = true
            self.son3Ay = false
            self.son1Yıl = false
            self.viewWillAppear(true)
        }
        
        let son3 = UIAlertAction(title: "Son 3 Ay", style: .default)
        { _ in

            self.son1Ay = false
            self.son3Ay = true
            self.son1Yıl = false
            self.viewWillAppear(true)
        }
        
        let son1Yıl = UIAlertAction(title: "Son 1 Yıl", style: .default)
        { _ in

            self.son1Ay = false
            self.son3Ay = false
            self.son1Yıl = true
            self.viewWillAppear(true)
        }
        uyari.addAction(son1)
        uyari.addAction(son3)
        uyari.addAction(son1Yıl)
        uyari.addAction(tumHareketler)
        uyari.addAction(iptal)
        
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
    
}
