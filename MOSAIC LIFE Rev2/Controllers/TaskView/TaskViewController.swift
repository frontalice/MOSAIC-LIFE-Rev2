//
//  TaskViewController.swift
//  MOSAIC LIFE Rev.
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import UIKit
import CoreData

class TaskViewController : UIViewController {
    
    // MARK: - View Properties
    lazy var taskView = TaskView()
    
    lazy var editingTextField : UITextField = UITextField()
    
    let modeColor : UIColor = .systemTeal
    
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
    
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = createFetchedResultsController()
    
    var categoryOptions : [String] = []
    let newCategory = "新しいカテゴリを追加"
    
    // MARK: - LifeCycle Functions
    override func loadView() {
        view = taskView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        taskView.taskListView.delegate = self
        taskView.taskListView.dataSource = self
        taskView.taskListView.allowsSelectionDuringEditing = true
        let edit = editButtonItem
        edit.tintColor = .white
        navigationItem.rightBarButtonItems?.insert(edit, at: 0)
        
        // Model
        currentPt = userDefaults.fetchInt(.currentPt)
        currentRate = taskView.modeControl.selectedSegmentIndex+1
        
        // View - value
        taskView.ptLabel.text = String("\(currentPt) pt")
        // 非同期処理しようとするとreloadData()がメインスレッドにしか置けないとか言われて強制終了するのでとりあえず一番最後に置く
        fetchTasks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        syncBarAppearance(modeColor)
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = getAlertController(title: "Taskの追加", message: "Task名と獲得pt、カテゴリを入力", fields: 3, placeHolder: ["Task Name", "Points", "Section"])
        
        let categorySelectPickerView = setPickerView()
        let toolbar = makeToolBarOnPickerView()
        editingTextField = alertController.textFields![2]
        
        alertController.textFields![2].inputAccessoryView = toolbar
        alertController.textFields![2].inputView = categorySelectPickerView
        alertController.textFields![2].text = categoryOptions[0]
        
        let alertAction = UIAlertAction(title: "OK", style: .default) {(action: UIAlertAction) -> Void in
            if let name = alertController.textFields![0].text,
               let ptStr = alertController.textFields![1].text,
               let category = alertController.textFields![2].text {
                if let pt = Int(ptStr) {
                    if category != self.newCategory {
                        if Task.addNewTask(context: self.context, name: name, pt: pt, category: category){
//                            self.taskView.taskListView.reloadData()
                        } else {
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
        } // AlertActionここまで
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc public func decideCategory(_ sender: Any) {
        editingTextField.endEditing(true)
    }
    
    func createCategory(name: String, pt: Int) {
        let alertController = getAlertController(title: "カテゴリを追加", message: "カテゴリ名を入力", fields: 1, placeHolder: ["カテゴリ名"])
        
        let alertAction : UIAlertAction = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) -> Void in
            if let category = alertController.textFields![0].text {
                if Task.addNewTask(context: self.context, name: name, pt: pt, category: category){
                    self.taskView.taskListView.reloadData()
                } else {
                    self.showAlert(message: "データベースへの追加に失敗しました。")
                }
            } else {
                self.showAlert(message: "カテゴリ名を入力して下さい。")
            }
        }
        
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // setEditingをoverrideする事でUIBarButtonItem.Editが押された時の処理を指示する事ができる
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        print("EditButton Tapped: editing->\(self.taskView.taskListView.isEditing)")
        self.taskView.taskListView.setEditing(editing, animated: true)
    }
    
    // MARK: - View Control Functions
    private func syncBarAppearance(_ color : UIColor){
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            // NavigationBarの背景色の設定
            appearance.backgroundColor = color
            // NavigationBarのタイトルの文字色の設定
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    }
    
    // MARK: - Model Control Functions
    private func fetchTasks() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalError("Error！: Failed in Fetching Tasks -> \(error)")
        }
        taskView.taskListView.reloadData()
        initializeCategoryOptions()
        print(categoryOptions)
    }
    
}
