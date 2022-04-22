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
    lazy var taskView = TaskView()
    
    let modeColor : UIColor = .systemTeal
    
    // MARK: - Model Properties
    
    lazy var fetchedResultsController: NSFetchedResultsController<Task> = createFetchedResultsController()
    
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
        
        // Model
        currentPt = userDefaults.fetchInt(.currentPt)
        currentRate = taskView.modeControl.selectedSegmentIndex+1
        
        // View - value
        taskView.ptLabel.text = String("\(currentPt) pt")
        
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
        alertController.textFields![2].text = categoryOptions[0]
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: insertRecordHandler(alertController: alertController, model: .task, context: context))
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    // setEditingをoverrideする事でUIBarButtonItem.Editが押された時の処理を指示する事ができる
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.taskView.taskListView.setEditing(editing, animated: true)
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
