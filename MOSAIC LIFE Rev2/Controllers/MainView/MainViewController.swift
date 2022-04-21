//
//  ViewController.swift
//  MOSAIC LIFE Rev.
//
//  Created by Toshiki Hanakawa on 2022/04/18.
//

import UIKit

class MainViewController: UIViewController {
    
    private lazy var mainView = MainView()
    
    override func loadView() {
        view = mainView
    }
    
    lazy var userDefaults : UDDataStore = UDDataStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        mainView.taskButton.addTarget(self, action: #selector(goToTask(_:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mainView.ptLabel.text = String(userDefaults.fetchInt(.currentPt))
    }
    
    @objc private func goToTask(_ sender: Any) {
        self.performSegue(withIdentifier: "toTask", sender: self)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case "toTask":
//
//        case "toShop":
//
//        default:
//            return
//        }
//    }
    
}

