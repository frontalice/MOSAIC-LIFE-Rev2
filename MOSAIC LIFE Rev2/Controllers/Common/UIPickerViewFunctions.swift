//
//  UIPickerViewFunctions.swift
//  MOSAIC LIFE Rev2
//

import UIKit

extension CommonListViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count+1
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var source = categories
        source.append(newCategory)
        return source[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var source = categories
        source.append(newCategory)
        editingTextField.text = source[row]
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
