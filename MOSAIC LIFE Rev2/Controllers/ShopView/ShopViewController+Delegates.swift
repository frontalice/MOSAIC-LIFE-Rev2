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
        
        let sourceName : String = fetchedResultsController.object(at: indexPath).name ?? ""
        let sourcePt : Int32 = fetchedResultsController.object(at: indexPath).pt
        
        if !self.listView.listTable.isEditing {
            let pt = Double(sourcePt)
            if currentPt < Int(pt * shopRate) {
                return
            }
            currentPt -= Int(pt * shopRate)
            listView.pointLabel.text = String("\(currentPt) pt")
            tableView.deselectRow(at: indexPath, animated: false)
            userDefaults.set(.currentPt, currentPt)
            NotificationCenter.default.post(name: .init(rawValue: "ACTIVITYLOG"), object: nil, userInfo: [
                "Name":sourceName,
                "Point":Int(pt * shopRate),
                "ObtainedPoint":0,
                "Type":"Shop"
            ])
        } else {
            let alertController = getAlertController(title: "Itemの編集", message: "" , fields: 2, placeHolder: ["Item Name","Point"])
            alertController.textFields![0].text = sourceName
            alertController.textFields![1].text = String(sourcePt)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: updateRecordHandler(alertController: alertController, model: .shop, context: context, indexPath: indexPath))
            
            alertController.addAction(alertAction)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func updateRecordHandler (alertController: UIAlertController, model: ModelEnum, context: NSManagedObjectContext!, indexPath: IndexPath) -> ((UIAlertAction) -> Void) {
        let handler : ((UIAlertAction) -> Void) = { _ in
            if let nameText = alertController.textFields![0].text,
               let ptText = alertController.textFields![1].text {
                if let ptInt32 = Int32(ptText) {
                    self.fetchedResultsController.object(at: indexPath).name = nameText
                    self.fetchedResultsController.object(at: indexPath).pt = ptInt32
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
}

extension ShopViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections?[section].name ?? ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            fatalError("Error!: No sections in fetchedResultsController")
        }
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "")
        let object = fetchedResultsController.object(at: indexPath)
        let pt = Int(Double(object.pt) * shopRate)
        cell.textLabel?.text = object.name
        cell.detailTextLabel?.text = String(pt)
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = fetchedResultsController.object(at: indexPath)
            context.delete(target)
            try! context.save()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = modeColor
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = .white
    }
}

extension ShopViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let count = fetchedResultsController.sections?.count {
            return count + 1
        } else {
            return 1
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        initializeCategoryOptions()
        return categoryOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        editingTextField.text = categoryOptions[row]
    }
    
    func initializeCategoryOptions() -> Bool {
        categoryOptions = []
        if let sections = fetchedResultsController.sections {
            if sections.count > 0 {
                for i in 0..<sections.count {
                    categoryOptions.append(sections[i].name)
                }
                categoryOptions.append(newCategory)
                return true
            }
        }
        categoryOptions.append(newCategory)
        return false
    }
    
    func setPickerView() -> UIPickerView {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.selectRow(0, inComponent: 0, animated: true)
        return pickerView
    }
    
    func makeToolBarOnPickerView() -> UIToolbar {
        let toolbar = UIToolbar()
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(decideCategory(_:)))
        toolbar.setItems([doneButton], animated: true)
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc public func decideCategory(_ sender: Any) {
        editingTextField.endEditing(true)
    }
    
}

extension ShopViewController : NSFetchedResultsControllerDelegate {
    func createFetchedResultsController() -> NSFetchedResultsController<Shop> {
        let fetchRequest = Shop.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Shop.name, ascending: true)]
        let frc = NSFetchedResultsController<Shop>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)
        frc.delegate = self
        return frc
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.listView.listTable.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.listView.listTable.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let sections = NSIndexSet(index: sectionIndex)
        switch type {
        case .insert:
            self.listView.listTable.insertSections(sections as IndexSet, with: .automatic)
        case .delete:
            self.listView.listTable.deleteSections(sections as IndexSet, with: .automatic)
        default:
            return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            self.listView.listTable.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            self.listView.listTable.reloadRows(at: [indexPath!], with: .none)
        case .delete:
            self.listView.listTable.deleteRows(at: [indexPath!], with: .automatic)
        case .move:
            self.listView.listTable.deleteRows(at: [indexPath!], with: .fade)
            self.listView.listTable.insertRows(at: [newIndexPath!], with: .fade)
        default:
            break
        }
    }
}
