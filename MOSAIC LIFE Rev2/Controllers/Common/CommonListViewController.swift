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
    
    var items = [String:[Item]]()
    
    lazy var userDefaults : UDDataStore = UDDataStore()
    
    var currentPt = 0
    
    var categories : [String] = []
    
    let newCategory = "新しいカテゴリを追加"
    
    // MARK: - LifeCycle Functions
    
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
    
    override func loadView() {
        view = listView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        listView.listTable.allowsSelectionDuringEditing = true
        let edit = editButtonItem
        edit.tintColor = .white
        navigationItem.rightBarButtonItems?.insert(edit, at: 0) // [1,0]
        
        // Model
        currentPt = userDefaults.fetchInt(key: .currentPt)
        
        // View - value
        listView.pointLabel.text = String("\(currentPt) pt")
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
    
    func fetchItems(modelType: String){
        let request = NSFetchRequest<Item>(entityName: "Item")
        request.predicate = NSPredicate(format: "type == %@", modelType)
        var allItems = [Item]()
        
        do {
            allItems = try context.fetch(request)
        } catch let error as NSError {
            fatalError("Error！: Failed in Fetching Items -> \(error)")
        }
        
        categories = []
        for item in allItems {
            if !categories.contains(item.category){
                categories.append(item.category)
                items[item.category] = [item]
            } else {
                items[item.category]!.append(item)
            }
        }
        categories.sort()
        
        for category in categories {
            // 通常時
            items[category]!.sort(by: {$0.index < $1.index})
            
            // 初期化時
//            for i in 0..<items[category]!.count {
//                items[category]![i].index = Int16(i) // [[0,1,2,3],[0,1,2],[0,1,2,3]...]
//            }
        }
        
        listView.listTable.reloadData()
    }
    
    func addNewItem(context: NSManagedObjectContext!, modelType: String, name: String, pt: Int, category: String) -> Bool {
        let newRecord = Item(context: context)
        newRecord.type = modelType
        newRecord.name = name
        newRecord.pt = Int32(pt)
        newRecord.category = category
        // .index = category内でのindexの最大値+1,もしくは0
        newRecord.index = fetchIndex(modelType: modelType ,category: category)
        do {
            try context.save()
        } catch {
            print("context not saved:\(error.localizedDescription)")
            return false
        }
        if categories.contains(category){
            // categoriesに既にある->既存の配列に追加
            items[category]!.append(newRecord)
        } else {
            // categoriesに無い->カテゴリごと追加
            items[category] = [newRecord]
            categories.append(category)
            categories.sort()
        }
        listView.listTable.reloadData()
        return true
    }
    
    func fetchIndex(modelType: String, category: String) -> Int16 {
        
        if categories.contains(category) == false {
            return Int16(0)
        }
        
        let expressionIndexName = "maxIndex"
        let keyPathExpression = NSExpression(forKeyPath: "index")
        let maxIndexExpression = NSExpression(forFunction: "max:", arguments: [keyPathExpression])
        let maxIndexDescription = NSExpressionDescription()
        maxIndexDescription.name = expressionIndexName
        maxIndexDescription.expression = maxIndexExpression
        maxIndexDescription.resultType = .integer16
        
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Item")
        fetchRequest.resultType = .dictionaryResultType
        let typePredicate = NSPredicate(format: "type == %@", modelType)
        let categoryPredicate = NSPredicate(format: "category == %@", category)
        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typePredicate, categoryPredicate])
        fetchRequest.propertiesToFetch = [maxIndexDescription]
        
        do {
            let results = try context.fetch(fetchRequest)
            if let maxIndex = results.first?.value(forKey: expressionIndexName) as? Int16 {
                return maxIndex + Int16(1)
            } else {
                return Int16(0)
            }
        } catch {
            fatalError("Failed to fetch by index")
        }
        
    }
    
    func insertRecordHandler (alertController: UIAlertController, modelType: String, context: NSManagedObjectContext!) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let name = alertController.textFields![0].text,
               let ptStr = alertController.textFields![1].text,
               let pt = Int(ptStr),
               let category = alertController.textFields![2].text {
                if category != self.newCategory {
                    if !self.addNewItem(context: context, modelType: modelType, name: name, pt: pt, category: category) {
                        self.showAlert(message: "データベースへの追加に失敗しました。")
                        return
                    }
                } else {
                    self.createCategory(modelType: modelType ,name: name, pt: pt)
                    // この後に処理を書いても実行されない
                }
            } else {
                self.showAlert(message: "不正な文字列が含まれています。")
            }
        }
        return handler
    }
    
    func createCategory(modelType: String, name: String, pt: Int) {
        let alertController = getAlertController(title: "カテゴリを追加", message: "カテゴリ名を入力", fields: 1, placeHolder: ["カテゴリ名"])
        
        let alertAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: insertCategoryHandler(alertController: alertController, modelType: modelType, context: context, name: name, pt: pt))
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func insertCategoryHandler (alertController: UIAlertController, modelType: String, context: NSManagedObjectContext!, name: String, pt: Int) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let category = alertController.textFields![0].text {
                if self.categories.contains(category) {
                    self.showAlert(message: "同一名のカテゴリは登録出来ません。")
                    return
                }
                if !self.addNewItem(context: context, modelType: modelType, name: name, pt: pt, category: category){
                    self.showAlert(message: "データベースへの追加に失敗しました。")
                    return
                }
                self.listView.listTable.reloadData()
            } else {
                self.showAlert(message: "カテゴリ名を入力して下さい。")
            }
        }
        return handler
    }
    // FIXME: - 廃止
//    func addNewRecord(model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int, category: String) -> Bool {
//        switch model {
//        case .task:
//            let newRecord = Item(context: context)
//            newRecord.name = name
//            newRecord.pt = Int32(pt)
//            newRecord.category = category
//            newRecord.type = "Task"
//            do {
//                try context.save()
//                print("context saved")
//            } catch {
//                print("context not saved:\(error.localizedDescription)")
//                return false
//            }
//        case .shop:
//            let newRecord = Shop(context: context)
//            newRecord.name = name
//            newRecord.pt = Int32(pt)
//            newRecord.category = category
//            do {
//                try context.save()
//                print("context saved")
//            } catch {
//                print("context not saved:\(error.localizedDescription)")
//                return false
//            }
//        }
//        listView.listTable.reloadData()
//        return true
//    }
//    
//    func insertCategoryHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int) -> ((UIAlertAction) -> Void) {
//        let handler : ((UIAlertAction) -> Void) = { _ in
//            if let category = alertController.textFields![0].text {
//                if !self.addNewRecord(model: model, context: context, name: name, pt: pt, category: category){
//                    self.showAlert(message: "データベースへの追加に失敗しました。")
//                    return
//                }
//                self.listView.listTable.reloadData()
//            } else {
//                self.showAlert(message: "カテゴリ名を入力して下さい。")
//            }
//        }
//        return handler
//    }
}
