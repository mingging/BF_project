//
//  BFTableViewController.swift
//  BF
//
//  Created by minimani on 2021/10/18.
//

import UIKit
import Alamofire
import SwiftyJSON

class BFTableViewController: UITableViewController, UISearchBarDelegate{
    
    let API_KEY = "KakaoAK "
    var books:[[String:Any]]?
    var page = 1
    var author: [Any]?
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        activityIndicator.hidesWhenStopped = true

        tableView.separatorStyle = .none
        tableView.rowHeight = 148
        // 네비게이션바 색상 설정
        navigationController?.navigationBar.barTintColor = UIColor(hex: "#B0E0E6ff")
        // 네비게이션바 border 없애기
        navigationController?.navigationBar.shadowImage = UIImage()
    
        // searchbar border 없애기
        searchBar.backgroundImage = UIImage()
    }

    // MARK: - Table view data source
    
    func search(query: String, page: Int) {
        let strURL = "https://dapi.kakao.com/v3/search/book"
        let parmas: Parameters = ["query":query, "page":page]
        let headers = HTTPHeaders(["Authorization":API_KEY])
        let root = AF.request(strURL, method: .get, parameters: parmas, headers: headers)
        root.responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                self.books = json["documents"].arrayObject as? [[String:Any]]
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.hidesWhenStopped = true
                }
            case .failure(let error):
                if let error = error.errorDescription {
                    print(error)
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text else {return}
        activityIndicator.startAnimating()
        activityIndicator.style = .large
        search(query: query, page: 1)
        
        // 키보드 내리기
        searchBar.resignFirstResponder()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let books = self.books {
            return books.count
        } else {
            return 0
        }
    }
    
    // backgroudn color 지우기
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           let headerView = UIView()
           headerView.backgroundColor = UIColor.clear
           return headerView
       }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        // 셀 선택 막기
        cell.selectionStyle = .none
        
        cell.backgroundColor = UIColor.white
        cell.layer.borderColor = UIColor.black.cgColor
        let mainBackground = cell.viewWithTag(1) as? UIView
        if let mainBackground = mainBackground {
            mainBackground.backgroundColor = .white
            mainBackground.layer.cornerRadius = 10
            
            // view shadow 설정
            // 해당 view의 frame밖에 contents들을 mask처리할 것인지
            mainBackground.layer.masksToBounds = false
            mainBackground.layer.shadowColor = UIColor.black.cgColor
            mainBackground.layer.shadowOffset = CGSize(width: 1, height: 2)
            mainBackground.layer.shadowOpacity = 0.2
            
        }
        
        // 값 넣기
        guard let books = books else {return cell}
        let book = books[indexPath.row]
        
        if let imageURL = book["thumbnail"] as? String, let url = URL(string: imageURL) {
            // 이미지 다운로드
            do {
                let data = try Data(contentsOf: url)
                let thumbnail = cell.viewWithTag(2) as? UIImageView
                thumbnail?.image = UIImage(data: data)
            } catch { print("이미지 다운로드에 실패했습니다.") }
        }
        
        let lblTitle = cell.viewWithTag(3) as? UILabel
        lblTitle?.text = book["title"] as? String
        
        let lblAuthors = cell.viewWithTag(4) as? UILabel
        let tempAuthors = book["authors"] as? [String]
        guard let authors = tempAuthors else {return cell}
        lblAuthors?.text = authors.joined(separator: ", ")
       
        
        let lblPublisher = cell.viewWithTag(5) as? UILabel
        lblPublisher?.text = book["publisher"] as? String
        
        // number formatter
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = -2
        
        let lblPrice = cell.viewWithTag(6) as? UILabel
        let tempPrice = book["price"] as? NSNumber
        guard let price = tempPrice else {return cell}
        lblPrice?.text = numberFormatter.string(from: price)! + "원"
      
        return cell
    }
    
    
    @IBAction func btnPrev(_ sender: UIBarButtonItem) {
        if (page > 0) {
            page -= 1
        } else {
            page = 0
        }
        guard let query = searchBar.text else {return}
        search(query: query, page: page)
    }
    
    @IBAction func btnNext(_ sender: UIBarButtonItem) {
        page += 1
        guard let query = searchBar.text else {return}
        search(query: query, page: page)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destVC = segue.destination as? BookDetailViewController,
              let indexPath = tableView.indexPathForSelectedRow,
              let books = self.books
        else {return}
        
        let book = books[indexPath.row]
        destVC.strURL = book["url"] as? String
    }

}

extension UIColor {
    public convenience init?(hex: String) {
         let r, g, b, a: CGFloat

         if hex.hasPrefix("#") {
             let start = hex.index(hex.startIndex, offsetBy: 1)
             let hexColor = String(hex[start...])

             if hexColor.count == 8 {
                 let scanner = Scanner(string: hexColor)
                 var hexNumber: UInt64 = 0

                 if scanner.scanHexInt64(&hexNumber) {
                     r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                     g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                     b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                     a = CGFloat(hexNumber & 0x000000ff) / 255

                     self.init(red: r, green: g, blue: b, alpha: a)
                     return
                 }
             }
         }

         return nil
     }
}
