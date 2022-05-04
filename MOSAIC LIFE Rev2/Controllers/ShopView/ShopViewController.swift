//
//  ShopViewController.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/22.
//

import UIKit
import CoreData

class ShopViewController : CommonListViewController {
    
    // MARK: - View Properties
    
    let modeColor : UIColor = .systemGreen
    
    // MARK: - Model Properties
    
    lazy var fetchedResultsController: NSFetchedResultsController<Shop> = createFetchedResultsController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listView = ShopView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        listView = ShopView()
    }
    
    // MARK: - LifeCycle Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        listView.listTable.delegate = self
        listView.listTable.dataSource = self
        listView.listTable.allowsSelectionDuringEditing = true
        
        // Model
        currentPt = userDefaults.fetchInt(key: .currentPt)
        currentRate = 1
        
        // View - value
        listView.pointLabel.text = String("\(currentPt) pt")
        
        fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncBarAppearance(modeColor)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = getAlertController(title: "Itemの追加", message: "Item名と消費pt、カテゴリを入力", fields: 3, placeHolder: ["Item Name", "Points", "Section"])
        
        let categorySelectPickerView = setPickerView()
        let toolbar = makeToolBarOnPickerView()
        editingTextField = alertController.textFields![2]
        
        alertController.textFields![2].inputAccessoryView = toolbar
        alertController.textFields![2].inputView = categorySelectPickerView
        alertController.textFields![2].text = categoryOptions[0]
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: insertRecordHandler(alertController: alertController, model: .shop, context: context))
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Model Control Functions
    private func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("Error！: Failed in Fetching Tasks -> \(error)")
        }
        listView.listTable.reloadData()
        initializeCategoryOptions()
        print(categoryOptions)
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
        
        let alertAction : UIAlertAction = UIAlertAction(title: "OK", style: .default, handler: insertCategoryHandler(alertController: alertController, model: .shop, context: context, name: name, pt: pt))
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
}
