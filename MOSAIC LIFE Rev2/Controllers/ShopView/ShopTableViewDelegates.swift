//
//  ShopViewController+Delegates.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/22.
//

import UIKit
import CoreData

extension ShopViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sourceName : String = items[categories[indexPath.section]]![indexPath.row].name
        let sourcePt : Int32 = items[categories[indexPath.section]]![indexPath.row].pt
        
        if !self.listView.listTable.isEditing {
            tableView.deselectRow(at: indexPath, animated: false)
            let pt = Int(sourcePt)
            if currentPt < pt * Int(shopRate * 10) / 10 {
                
                return
            }
            currentPt -= pt * Int(shopRate * 10) / 10
            listView.pointLabel.text = String("\(currentPt) pt")
            userDefaults.set(.currentPt, currentPt)
            NotificationCenter.default.post(name: .init(rawValue: "ACTIVITYLOG"), object: nil, userInfo: [
                "Name":sourceName,
                "Point":pt * Int(shopRate * 10) / 10,
                "ObtainedPoint":0,
                "Type":"Shop"
            ])
        } else {
            let alertController = getAlertController(title: "Itemの編集", message: "" , fields: 2, placeHolder: ["Item Name","Point"])
            alertController.textFields![0].text = sourceName
            alertController.textFields![1].text = String(sourcePt)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: updateRecordHandler(alertController: alertController, context: context, indexPath: indexPath))
            
            alertController.addAction(alertAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func updateRecordHandler (alertController: UIAlertController, context: NSManagedObjectContext!, indexPath: IndexPath) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let nameText = alertController.textFields![0].text,
               let ptText = alertController.textFields![1].text {
                if let ptInt32 = Int32(ptText) {
                    self.items[self.categories[indexPath.section]]![indexPath.row].name = nameText
                    self.items[self.categories[indexPath.section]]![indexPath.row].pt = ptInt32
                    do {
                        try self.context.save()
                        self.listView.listTable.reloadData()
                    } catch {
                        self.showAlert(message: "データ保存に失敗しました。")
                        return
                    }
                } else {
                    self.showAlert(message: "不正な文字列です。")
                }
            } else {
                self.showAlert(message: "不正な文字列です。")
            }
        }
        return handler
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let targetTask = items[categories[sourceIndexPath.section]]![sourceIndexPath.row]
        targetTask.category = categories[destinationIndexPath.section]
        items[categories[sourceIndexPath.section]]!.remove(at: sourceIndexPath.row)
        items[categories[destinationIndexPath.section]]!.insert(targetTask, at: destinationIndexPath.row)
        
        for i in 0..<items[categories[destinationIndexPath.section]]!.count {
            items[categories[destinationIndexPath.section]]![i].index = Int16(i)
        }
        
        if items[categories[sourceIndexPath.section]]!.count == 0 {
            categories.remove(at: sourceIndexPath.section)
        } else if sourceIndexPath.section != destinationIndexPath.section {
            for i in 0..<items[categories[sourceIndexPath.section]]!.count {
                items[categories[sourceIndexPath.section]]![i].index = Int16(i)
            }
        }
        
        try! context.save()
        tableView.reloadData()
    }
}

extension ShopViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return categories[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let num = items[categories[section]]?.count {
            return num
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        let task = items[categories[indexPath.section]]?[indexPath.row]
        cell.textLabel?.text = "[\(String(task?.index ?? 99))]\(task?.name ?? "")"
        let pt = items[categories[indexPath.section]]?[indexPath.row].pt ?? 0
        cell.detailTextLabel?.text = String(pt * Int32(shopRate * 10) / 10)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = items[categories[indexPath.section]]![indexPath.row]
            items[categories[indexPath.section]]!.remove(at: indexPath.row)
            if items[categories[indexPath.section]]!.count == 0 {
                items.removeValue(forKey: categories[indexPath.section])
                categories.remove(at: indexPath.section)
            } else {
                for i in 0..<items[categories[indexPath.section]]!.count{
                    items[categories[indexPath.section]]![i].index = Int16(i)
                }
            }
            context.delete(target)
            try! context.save()
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = modeColor
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
}

//extension ShopViewController : UIPickerViewDelegate, UIPickerViewDataSource {
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        if let count = fetchedResultsController.sections?.count {
//            return count + 1
//        } else {
//            return 1
//        }
//    }
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        initializeCategoryOptions()
//        return categoryOptions[row]
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        editingTextField.text = categoryOptions[row]
//    }
//
//    func initializeCategoryOptions() -> Bool {
//        categoryOptions = []
//        if let sections = fetchedResultsController.sections {
//            if sections.count > 0 {
//                for i in 0..<sections.count {
//                    categoryOptions.append(sections[i].name)
//                }
//                categoryOptions.append(newCategory)
//                return true
//            }
//        }
//        categoryOptions.append(newCategory)
//        return false
//    }
//
//    func setPickerView() -> UIPickerView {
//        let pickerView = UIPickerView()
//        pickerView.delegate = self
//        pickerView.dataSource = self
//        pickerView.selectRow(0, inComponent: 0, animated: true)
//        return pickerView
//    }
//
//    func makeToolBarOnPickerView() -> UIToolbar {
//        let toolbar = UIToolbar()
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(decideCategory(_:)))
//        toolbar.setItems([doneButton], animated: true)
//        toolbar.sizeToFit()
//        return toolbar
//    }
//
//    @objc public func decideCategory(_ sender: Any) {
//        editingTextField.endEditing(true)
//    }
//
//}

//extension ShopViewController : NSFetchedResultsControllerDelegate {
//    func createFetchedResultsController() -> NSFetchedResultsController<Shop> {
//        let fetchRequest = Shop.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Shop.name, ascending: true)]
//        let frc = NSFetchedResultsController<Shop>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)
//        frc.delegate = self
//        return frc
//    }
//    
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.listView.listTable.beginUpdates()
//    }
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        self.listView.listTable.endUpdates()
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        let sections = NSIndexSet(index: sectionIndex)
//        switch type {
//        case .insert:
//            self.listView.listTable.insertSections(sections as IndexSet, with: .automatic)
//        case .delete:
//            self.listView.listTable.deleteSections(sections as IndexSet, with: .automatic)
//        default:
//            return
//        }
//    }
//    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            self.listView.listTable.insertRows(at: [newIndexPath!], with: .automatic)
//        case .update:
//            self.listView.listTable.reloadRows(at: [indexPath!], with: .none)
//        case .delete:
//            self.listView.listTable.deleteRows(at: [indexPath!], with: .automatic)
//        case .move:
//            self.listView.listTable.deleteRows(at: [indexPath!], with: .fade)
//            self.listView.listTable.insertRows(at: [newIndexPath!], with: .fade)
//        default:
//            break
//        }
//    }
//}
