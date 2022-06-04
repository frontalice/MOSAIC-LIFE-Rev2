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
    let checkedImage = UIImage(systemName: "checkmark.square")
    let emptyImage = UIImage(systemName: "square")
    
    // MARK: - Model Properties
    
    // MARK: - LifeCycle Functions
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        listView = ShopView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        listView = ShopView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View - frame
        modeColor = .systemGreen
        
        // View - monitor
        listView.checkBox.addTarget(self, action: #selector(toggleCheckBox(_:)), for: .touchUpInside)
        
        // Model
        listView.listTable.delegate = self
        listView.listTable.dataSource = self
        
        // View - value
        
        fetchItems(modelType: "Shop")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        syncBarAppearance(modeColor)
        if isChecked {
            listView.checkBox.setImage(checkedImage, for: .normal)
        } else {
            listView.checkBox.setImage(emptyImage, for: .normal)
        }
        listView.rateLabel.text = "x\(shopRate)"
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        let alertController = getAlertController(title: "Itemの追加", message: "Item名と消費pt、カテゴリを入力", fields: 3, placeHolder: ["Item Name", "Points", "Section"])
        
        let categorySelectPickerView = setPickerView()
        let toolbar = makeToolBarOnPickerView()
        editingTextField = alertController.textFields![2]
        
        alertController.textFields![2].inputAccessoryView = toolbar
        alertController.textFields![2].inputView = categorySelectPickerView
        alertController.textFields![2].text = categories.count == 0 ? newCategory : categories[0]
        
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: insertRecordHandler(alertController: alertController, modelType: "Shop", context: context))
        
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func toggleCheckBox(_ sender: Any) {
        if isChecked {
            // チェックを外す
            listView.checkBox.setImage(emptyImage, for: .normal)
        } else {
            // チェックをつける
            listView.checkBox.setImage(checkedImage, for: .normal)
        }
        listView.listTable.reloadData()
        isChecked.toggle()
    }
    
    // MARK: - Model Control Functions
}
