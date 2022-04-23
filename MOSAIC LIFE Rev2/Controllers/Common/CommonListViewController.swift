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
    
    var listView : CommonListView
    
    lazy var editingTextField : UITextField = UITextField()
    
    // MARK: - Model Properties
    
    var context : NSManagedObjectContext! = {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            return context
        } else {
            fatalError("context is nil")
        }
    }()
    
    lazy var userDefaults : UDDataStore = UDDataStore()
    
    var currentPt = 0
    var currentRate = 1
    
//    public var context : NSManagedObjectContext!
    
    var categoryOptions : [String] = []
    let newCategory = "新しいカテゴリを追加"
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        context = nil
        listView = CommonListView()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
//        context = nil
        listView = CommonListView()
        super.init(coder: coder)
    }
    
    // MARK: - LifeCycle Functions
    
    override func loadView() {
        view = listView
    }
    
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
    
    // setEditingをoverrideする事でUIBarButtonItem.Editが押された時の処理を指示する事ができる
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        listView.listTable.setEditing(editing, animated: true)
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
