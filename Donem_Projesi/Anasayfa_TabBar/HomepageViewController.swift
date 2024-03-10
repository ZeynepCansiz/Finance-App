//
//  HomepageViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 15.03.2023.
//


import UIKit
import Firebase
import Foundation

class HomepageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dolarLabel: UILabel!
    @IBOutlet weak var euroLabel: UILabel!

    let button = UIButton()
    var data: [Any] = []
    var newArray : [Int] = []

    override func viewWillAppear(_ animated: Bool) {
        getData()
        getExchangeRates(for: "USD", label: dolarLabel)
        getExchangeRates(for: "EUR", label: euroLabel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
        self.tabBarController?.tabBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")

        button.addTarget(self, action: #selector(self.refresh), for: .touchUpInside)
        view.addSubview(button)
        
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
        
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let calendar = Calendar.current
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NotesCell
       
        if let map = data[indexPath.row] as? [String: Any],
            let kategori = map["Kategori"] as? String,
            let odeme = map["SonOdemeTarihi"] as? Timestamp,
            let not = map["Not"] as? String {
            
            
            let components = calendar.dateComponents([.day], from: Date(), to: odeme.dateValue())
            let dayCount = components.day
            
            if(dayCount!>=0 && dayCount!<=3){
                
                let kategori_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.orange, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0) ]
                let yeni_kategori = NSAttributedString(string: kategori, attributes: kategori_ozellik)
                
                let not_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.orange ]
                let yeni_not = NSAttributedString(string: not, attributes: not_ozellik)
                
                let spaceString = NSAttributedString(string: "\n")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateString = dateFormatter.string(from: (odeme.dateValue()))
                
                let tarih = [ NSAttributedString.Key.foregroundColor: UIColor.orange, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0) ]
                let yeni_tarih = NSAttributedString(string: "Son ödeme tarihi: " + dateString , attributes: tarih)
                
                let text = NSMutableAttributedString()
                text.append(yeni_kategori)
                text.append(spaceString)
                text.append(yeni_not)
                text.append(spaceString)
                text.append(yeni_tarih)
                
                cell.notlar.attributedText = text
            }
            
            
            else if (newArray.contains(indexPath.row)){
                
                let kategori_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0) ]
                let yeni_kategori = NSAttributedString(string: kategori, attributes: kategori_ozellik)
                
                let not_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.red ]
                let yeni_not = NSAttributedString(string: not, attributes: not_ozellik)
                
                let spaceString = NSAttributedString(string: "\n")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateString = dateFormatter.string(from: (odeme.dateValue()))
                
                let tarih = [ NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0) ]
                let yeni_tarih = NSAttributedString(string: "Son ödeme tarihi: " + dateString , attributes: tarih)
                
                let text = NSMutableAttributedString()
                text.append(yeni_kategori)
                text.append(spaceString)
                text.append(yeni_not)
                text.append(spaceString)
                text.append(yeni_tarih)
                
                cell.notlar.attributedText = text
            }
            else{
                let kategori_ozellik = [ NSAttributedString.Key.foregroundColor: hexStringToUIColor(hex: "993135"), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20.0) ]
                let yeni_kategori = NSAttributedString(string: kategori, attributes: kategori_ozellik)
                
                let not_ozellik = [ NSAttributedString.Key.foregroundColor: UIColor.black ]
                let yeni_not = NSAttributedString(string: not, attributes: not_ozellik)
                
                let spaceString = NSAttributedString(string: "\n")
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                let dateString = dateFormatter.string(from: (odeme.dateValue()))
                
                let tarih = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18.0) ]
                let yeni_tarih = NSAttributedString(string: "Son ödeme tarihi: " + dateString , attributes: tarih)
                
                let text = NSMutableAttributedString()
                text.append(yeni_kategori)
                text.append(spaceString)
                text.append(yeni_not)
                text.append(spaceString)
                text.append(yeni_tarih)
                
                cell.notlar.attributedText = text
                }
            }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete{
            
            data.remove(at: indexPath.row)
            
            let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let notID = document.get("NotID") as! String
                    
                    let docRef = Firestore.firestore().collection("Notes").document(notID).setData(
                        ["Not" : self.data]
                    )
      
                }
            }
        }
                    
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }

    
    
    @objc func getData(){
                
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        db.settings = settings
        
        let docRef = db.collection("Users").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let notID = document.get("NotID") as! String
                
                let docRef = Firestore.firestore().collection("Notes").document(notID)
                
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let docData = document.data()
                        if var items = docData?["Not"] as? [[String: Any]] {
                            for (index,item) in items.enumerated() {
                                if let name = item["SonOdemeTarihi"] as? Timestamp {
                                            
                                    let sonOdemeTarihi = name.dateValue()
                                    let result = sonOdemeTarihi.compare(Date())
                                    
                                    if (result == .orderedAscending){
                                        self.newArray.append(index)
                                    }
                                }
                                else{
                                    print("girmedi")
                                }
                            }
                            
                            self.data = items
//                            self.data = newArray //Auto Delete
                            docRef.setData( ["Not" : self.data])
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    

    func getExchangeRates(for currency: String, label: UILabel) {
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(currency)"
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                if let error = error {
                    print("Hata: \(error)")
                    return
                }
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                        if let rates = json?["rates"] as? [String: Double], let exchangeRate = rates["TRY"] {
                            DispatchQueue.main.async {
                                label.text = "\(exchangeRate) ₺"
                            }
                        }
                    } catch {
                        print("JSON dönüşüm hatası: \(error)")
                    }
                }
            }
            task.resume()
        } else {
            print("Geçersiz URL")
        }
    }
    
    
    @objc func refresh()
        {
            performSegue(withIdentifier: "toTaskVC", sender: nil)
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
            alpha: CGFloat(1.0)
        )
    }

}
