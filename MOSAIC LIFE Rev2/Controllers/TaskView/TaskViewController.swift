//
//  TaskViewController.swift
//  MOSAIC LIFE Rev.
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import UIKit
import CoreData

class TaskViewController : CommonListViewController {
    
    // MARK: - View Properties
    
    let modeColor : UIColor = .systemTeal
    
    var tasks = [String:[Task]]()
    
    // MARK: - Model Properties
    
    // MARK: - LifeCycle Functions
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listView = TaskView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        listView = TaskView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        listView.listTable.delegate = self
        listView.listTable.dataSource = self
        listView.listTable.allowsSelectionDuringEditing = true
        listView.rateSegmentControl.selectedSegmentIndex = userDefaults.fetchInt(key: .taskRate)-1
        
        // View - monitor
        listView.rateSegmentControl.addTarget(self, action: #selector(whenRateChanged(_:)), for: .valueChanged)
        
        // Model
        currentPt = userDefaults.fetchInt(key: .currentPt)
        currentRate = userDefaults.fetchInt(key: .taskRate)
        
        // View - value
        listView.pointLabel.text = String("\(currentPt) pt")
        
        fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncBarAppearance(modeColor)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = getAlertController(title: "Taskの追加", message: "Task名と獲得pt、カテゴリを入力", fields: 3, placeHolder: ["Task Name", "Points", "Section"])
        
        let categorySelectPickerView = setPickerView()
        let toolbar = makeToolBarOnPickerView()
        editingTextField = alertController.textFields![2]
        
        alertController.textFields![2].inputAccessoryView = toolbar
        alertController.textFields![2].inputView = categorySelectPickerView
        alertController.textFields![2].text = categories.count == 0 ? newCategory : categories[0]
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: insertRecordHandler(alertController: alertController, model: .task, context: context))
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func whenRateChanged(_ sender: Any) {
        currentRate = listView.rateSegmentControl.selectedSegmentIndex+1
        listView.listTable.reloadData()
        userDefaults.set(.taskRate, currentRate)
    }
    
    // MARK: - Model Control Functions
    
    private func fetchTasks() {
        let request = NSFetchRequest<Task>(entityName: "Task")
        var allTasks = [Task]()
        
        do {
            allTasks = try context.fetch(request)
        } catch let error as NSError {
            fatalError("Error！: Failed in Fetching Tasks -> \(error)")
        }
        
        categories = []
        for task in allTasks {
            if !categories.contains(task.category!){
                categories.append(task.category!)
                tasks[task.category!] = [task]
            } else {
                tasks[task.category!]!.append(task)
            }
        }
        categories.sort()
        
        for category in categories {
            // 通常時
            // tasks[category]!.sort(by: {$0.index < $1.index})
            
            // 初期化時
            for i in 0..<tasks[category]!.count {
                tasks[category]![i].index = Int16(i) // [[0,1,2,3],[0,1,2],[0,1,2,3]...]
            }
        }
        
        listView.listTable.reloadData()
    }
    
//    func initializeCategoryOptions(){
//        categoryDictionary = [:]
//        for task in tasks {
//            if categoryDictionary[task.category!] == nil {
//                categoryDictionary[task.category!] = 1
//            } else {
//                categoryDictionary[task.category!]! += 1
//            }
//        }
//        categories = categoryDictionary.sorted{$0.0 < $1.0}.map{$0.0}
//        initiazliedCategoriesCount += 1
//        print("カテゴリ初期化回数+1 合計:\(initiazliedCategoriesCount)")
//    }
    
//    func targetTask(_ indexPath: IndexPath) -> Task {
//        var filteredTasks = tasks.filter{$0.category == categories[indexPath.section]}
//        filteredTasks.sort(by: {$0.name! < $1.name!})
//        return filteredTasks[indexPath.row]
//    }
    
    override func addNewRecord(model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int, category: String) -> Bool {
        let newRecord = Task(context: context)
        newRecord.name = name
        newRecord.pt = Int32(pt)
        newRecord.category = category
        // .index = category内でのindexの最大値+1,もしくは0
        newRecord.index = fetchIndex(category: category)
        do {
            try context.save()
        } catch {
            print("context not saved:\(error.localizedDescription)")
            return false
        }
        if var categoryArray = tasks[category]{
            categoryArray.append(newRecord)
        } else {
            tasks[category] = [newRecord]
            categories.append(category)
            categories.sort()
        }
        listView.listTable.reloadData()
        return true
    }
    
    func fetchIndex(category: String) -> Int16 {
        
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
        
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.predicate = NSPredicate(format: "category == %@", category)
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
    
    func insertRecordHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let name = alertController.textFields![0].text,
               let ptStr = alertController.textFields![1].text,
               let pt = Int(ptStr),
               let category = alertController.textFields![2].text {
                if category != self.newCategory {
                    if !self.addNewRecord(model: model, context: context, name: name, pt: pt, category: category) {
                        self.showAlert(message: "データベースへの追加に失敗しました。")
                        return
                    }
                } else {
                    self.createCategory(name: name, pt: pt)
                    // この後に処理を書いても実行されない
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
    
    override func insertCategoryHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!, name: String, pt: Int) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let category = alertController.textFields![0].text {
                if self.categories.contains(category) {
                    self.showAlert(message: "同一名のカテゴリは登録出来ません。")
                    return
                }
                if !self.addNewRecord(model: model, context: context, name: name, pt: pt, category: category){
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
}
