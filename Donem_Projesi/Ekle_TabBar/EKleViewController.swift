//
//  EKleViewController.swift
//  Donem_Projesi
//
//  Created by Zeynep Cansız on 10.05.2023.
//

import UIKit
import Firebase

class EKleViewController: UIViewController {

    @IBOutlet weak var gelirLabel: UILabel!
    @IBOutlet weak var giderLabel: UILabel!
    private let circularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
    private let progressLabel = UILabel()

    var gelir = 0.0
    var gider = 0.0
    var oran = 0.0

    override func viewWillAppear(_ animated: Bool) {
        getData()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        circularProgressView.center = view.center
        view.addSubview(circularProgressView)

        progressLabel.textAlignment = .center
        progressLabel.textColor = hexStringToUIColor(hex: "993135")
        progressLabel.font = UIFont.systemFont(ofSize: 25)
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        NSLayoutConstraint.activate([
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func getData(){

        let docRef = db.collection("Finance").document(Auth.auth().currentUser!.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let docData = document.data()
                if var items = docData?["Hareketler"] as? [[String: Any]] {
                    self.gelir = 0.0
                    self.gider = 0.0
                    self.oran = 0.0
                    for item in items {
                        if let çeşit = item["Çeşit"] as? String {
                            if çeşit == "GELİR"{
                                if var miktar = item["Miktar"] as? String{
                                    if miktar.contains(","){
                                        let yeniMiktar = miktar.replacingOccurrences(of: ",", with: ".")
                                        miktar = yeniMiktar
                                    }

                                    if let sayi = Double(miktar) {
                                        self.gelir += sayi
                                    } else {
                                        print("Geçersiz sayı")
                                    }
                                }
                            }
                            else if çeşit == "GİDER"{
                                if var miktar = item["Miktar"] as? String{
                                    if miktar.contains(","){
                                        let yeniMiktar = miktar.replacingOccurrences(of: ",", with: ".")
                                        miktar = yeniMiktar
                                    }

                                    if let sayi = Double(miktar) {
                                        self.gider += sayi
                                    } else {
                                        print("Geçersiz sayı")
                                    }
                                }
                            }
                        }
                        else{
                            print("girmedi")
                        }
                    }
                }

                let eldeKalan = self.gelir - self.gider

                let progress: Double = eldeKalan / self.gelir
                let formattedProgress = max(min(progress, 1.0), 0.0)
//                let progressPercentage = Int(formattedProgress * 100)

                DispatchQueue.main.async {
                    let gelirString = String(format: "%.2f", self.gelir)
                    let giderString = String(format: "%.2f", self.gider)
                    let eldeKalanString = String(format: "%.2f", eldeKalan)

                    self.gelirLabel.text = gelirString + " ₺"
                    self.giderLabel.text = giderString + " ₺"
                    self.circularProgressView.setProgress(Float(formattedProgress))
                    self.progressLabel.text = eldeKalanString + " ₺"
                }
            }
        }
    }

    class CircularProgressView: UIView {

        private let progressLayer = CAShapeLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupProgressLayer()
        }

        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            setupProgressLayer()
        }

        private func setupProgressLayer() {
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            let startAngle = -CGFloat.pi / 2
            let endAngle = 2 * CGFloat.pi + startAngle

            let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: startAngle, endAngle: endAngle, clockwise: true)

            progressLayer.path = circularPath.cgPath
            progressLayer.strokeColor = hexStringToUIColor(hex: "993135").cgColor
            progressLayer.lineWidth = 10
            progressLayer.fillColor = UIColor.clear.cgColor
            progressLayer.strokeEnd = 0
            progressLayer.lineCap = .round

            layer.addSublayer(progressLayer)
        }

        func setProgress(_ progress: Float) {
            progressLayer.strokeEnd = CGFloat(progress)
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
