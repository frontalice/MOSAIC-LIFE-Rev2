//
//  TaskListViewController.swift
//  MOSAIC LIFE Rev.
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import UIKit
import CoreData

extension TaskViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sourceName : String = items[categories[indexPath.section]]![indexPath.row].name
        let sourcePt : Int32 = items[categories[indexPath.section]]![indexPath.row].pt
        
        if !self.listView.listTable.isEditing {
            currentPt += Int(sourcePt) * taskRate
            listView.pointLabel.text = String("\(currentPt) pt")
            tableView.deselectRow(at: indexPath, animated: false)
            userDefaults.set(.currentPt, currentPt)
            NotificationCenter.default.post(name: .init(rawValue: "ACTIVITYLOG"), object: nil, userInfo: [
                "Name":sourceName,
                "Point":Int(sourcePt) * taskRate,
                "ObtainedPoint":Int(sourcePt),
                "Type":"Task"
            ])
        } else {
            let alertController = getAlertController(title: "Taskの編集", message: "" , fields: 2, placeHolder: ["Task Name","Point"])
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

extension TaskViewController : UITableViewDataSource {
    
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
        cell.detailTextLabel?.text = String(pt * Int32(taskRate))
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


