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
        modeColor = .systemTeal
        listView.rateSegmentControl.selectedSegmentIndex = userDefaults.fetchInt(key: .taskRate)-1
        
        // View - monitor
        listView.rateSegmentControl.addTarget(self, action: #selector(whenRateChanged(_:)), for: .valueChanged)
        
        // Model
        listView.listTable.delegate = self
        listView.listTable.dataSource = self
        
        // View - value
        
        fetchItems(modelType: "Task")
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
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: insertRecordHandler(alertController: alertController, modelType: "Task", context: context))
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func whenRateChanged(_ sender: Any) {
        taskRate = listView.rateSegmentControl.selectedSegmentIndex+1
        listView.listTable.reloadData()
        userDefaults.set(.taskRate, taskRate)
    }
    
    // MARK: - Model Control Functions
}
