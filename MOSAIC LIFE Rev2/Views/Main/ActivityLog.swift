//
//  ActivityLog.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/30.
//

import UIKit

public class ActivityLog : UITextView {
    func saveText(){
        let archivedText = try! NSKeyedArchiver.archivedData(withRootObject: self.attributedText!, requiringSecureCoding: false)
        UserDefaults.standard.set(archivedText, forKey: "ACTIVITYLOGTEXT")
    }
    
    func loadText(){
        // テキストログ取得
        if let archivedLog = UserDefaults.standard.object(forKey: "ACTIVITYLOGTEXT") {
            if let unarchivedText = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedLog as! Data) as? NSAttributedString {
                self.attributedText = unarchivedText.mutableCopy() as! NSMutableAttributedString
            } else {
                self.attributedText = NSMutableAttributedString(string: "ログの読み込みに失敗しました。\n")
            }
        // テキストログ取得失敗時
        } else {
            self.attributedText = NSMutableAttributedString(string: "ログ内容が空です。\n")
        }
    }
    
    func addAttributedText(attributedText text:NSMutableAttributedString){
        let finalText : NSMutableAttributedString = self.attributedText?.mutableCopy() as! NSMutableAttributedString
        finalText.insert(text, at: finalText.length)
        self.attributedText = finalText
    }
}
