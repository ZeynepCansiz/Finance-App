import UIKit
import Foundation

class ExchangeRateTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var exchangeRates: [String] = []
    var base : [String] = []
    var rate : [String] = []
    var currency : [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
        self.tabBarController?.tabBar.barTintColor = hexStringToUIColor(hex: "F2E2E4")
    
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        
        self.navigationController?.view.tintColor = UIColor.secondaryLabel
        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        api()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ExchangeRatesCell
        cell.textLabel?.text = exchangeRates[indexPath.row]
 
        return cell
    }
    
    func api() {
                
        let url = "https://api.apilayer.com/fixer/latest?symbols=TRY%2CUSD%2CJPY%2CGBP%2CAUD%2CCAD%2CCHF%2CCNY%2CSEK%2CNZD%2CMXN%2CSGD%2CHKD%2CNOK%2CKRW%2CRUB%2CBRL%2CINR%2CZAR%2CSAR%2CDKK%2CAED%2CPLN%2CHUF&base=EUR"
        guard let apiURL = URL(string: url) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: apiURL)
        request.httpMethod = "GET"
        request.addValue("u0AHenJdyImrqma3ge3slGeVhqDWKB1c  ", forHTTPHeaderField: "apikey")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let data = data else {
                print("Empty data")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let rates = json["rates"] as? [String: Double], let base = json["base"] as? String {
                        for (currency, rate) in rates {
                            let exchangeRate = "1 \(base) \t\t = \t\t \(rate) \(currency)"
                            self.exchangeRates.append(exchangeRate)
                            self.base.append(base)
                            self.rate.append(String(rate))
                            self.currency.append(currency)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }
        
        task.resume()
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
