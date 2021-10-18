//
//  BookDetailViewController.swift
//  BF
//
//  Created by minimani on 2021/10/19.
//

import UIKit
import WebKit

class BookDetailViewController: UIViewController {
    
    var strURL: String?

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // navigation bar custom
//        navigationController?.navigationBar.barTintColor = UIColor(hex: "#B0E0E6ff")

        guard let str = strURL,
              let url = URL(string: str)
        else {return}
        print(str)
        let request = URLRequest(url: url)
        print(webView.isLoading)
        if webView.isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.hidesWhenStopped = true
        }
        webView.load(request)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
