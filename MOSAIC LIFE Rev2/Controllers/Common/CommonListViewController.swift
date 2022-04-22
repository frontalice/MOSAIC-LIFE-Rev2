//
//  CommonListViewController.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/21.
//

import Foundation
import UIKit
import CoreData

class CommonListViewController : UIViewController {
    
    // MARK: - View Properties
    
    lazy var editingTextField : UITextField = UITextField()
    
    // MARK: - Model Properties
    
    lazy var userDefaults : UDDataStore = UDDataStore()
    
    var currentPt = 0
    var currentRate = 1
    
    public var context : NSManagedObjectContext! = {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            return context
        } else {
            fatalError("context is nil")
        }
    }()
    
    var categoryOptions : [String] = []
    let newCategory = "新しいカテゴリを追加"
    
    // MARK: - LifeCycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        let edit = editButtonItem
        edit.tintColor = .white
        navigationItem.rightBarButtonItems?.insert(edit, at: 0) // [1,0]
        
        // Model
        // ここには書かない
        
        // View - value
        // ここには書かない
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - View Control Functions
    func syncBarAppearance(_ color : UIColor){
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = color
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - Model Control Functions
    
    func addNewRecord(model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int, category: String) -> Bool {
        switch model {
        case .task:
            let newRecord = Task(context: context)
            newRecord.name = name
            newRecord.pt = Int32(pt)
            newRecord.category = category
            do {
                try context.save()
                print("context saved")
            } catch {
                print("context not saved:\(error.localizedDescription)")
                return false
            }
            return true
        case .shop:
            let newRecord = Shop(context: context)
            newRecord.name = name
            newRecord.pt = Int32(pt)
            newRecord.category = category
            do {
                try context.save()
                print("context saved")
            } catch {
                print("context not saved:\(error.localizedDescription)")
                return false
            }
            return true
        }
    }
    
    func insertRecordHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let name = alertController.textFields![0].text,
               let ptStr = alertController.textFields![1].text,
               let category = alertController.textFields![2].text {
                if let pt = Int(ptStr) {
                    if category != self.newCategory {
                        if !self.addNewRecord(model: model, context: context, name: name, pt: pt, category: category) {
                            self.showAlert(message: "データベースへの追加に失敗しました。")
                        }
                    } else {
                        self.createCategory(name: name, pt: pt)
                    }
                } else {
                    self.showAlert(message: "不正な文字列が含まれています。")
                }
            } else {
                self.showAlert(message: "不正な文字列が含まれています。")
            }
        }
        return handler
    }
    
    func createCategory(name: String, pt: Int) {
        let alertController = getAlertController(title: "カテゴリを追加", message: "カテゴリ名を入力", fields: 1, placeHolder: ["カテゴリ名"])
        
        let alertAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: insertCategoryHandler(alertController: alertController, model: .task, context: context, name: name, pt: pt))
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func insertCategoryHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let category = alertController.textFields![0].text {
                if !self.addNewRecord(model: model, context: context, name: name, pt: pt, category: category){
                    self.showAlert(message: "データベースへの追加に失敗しました。")
                }
            } else {
                self.showAlert(message: "カテゴリ名を入力して下さい。")
            }
        }
        return handler
    }
}
