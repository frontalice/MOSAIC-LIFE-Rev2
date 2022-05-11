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
        scrollRangeToVisible(NSRange(location: attributedText.length-1, length: 1))
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
    
    func archiveText(){
        if let archivedLog = UserDefaults.standard.object(forKey: "ACTIVITYLOGTEXT") {
            if let logText = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedLog as! Data) as? NSAttributedString {
                
                // ログをドキュメントフォルダにtxtファイルで保存
                guard let dirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
                    print("Failed to Archive: DocumentDirectory was not found.")
                    return
                }
                
                let createDate = "\(DateManager.shared.fetchCurrentTime(type: .year))\(DateManager.shared.fetchCurrentTime(type: .month))\(DateManager.shared.fetchCurrentTime(type: .day))"
                let fileURL = dirURL.appendingPathComponent("\(createDate).txt")
                FileManager.default.createFile(atPath: fileURL.path, contents: logText.string.data(using: .utf8))
                
                // 古いファイルを消去
                if let files = try? FileManager.default.contentsOfDirectory(atPath: dirURL.path) {
                    if files.count >= 30 {
                        let targetURL = dirURL.appendingPathComponent(files.last!)
                        guard let _ = try? FileManager.default.removeItem(at: targetURL) else {
                            print("Failed to delete a file.")
                            return
                        }
                        print("FileDelete Successed.")
                    }
                } else {
                    print("Failed to delete a file: DocumentDirectory was not found.")
                }
                
            } else {
                print("Failed to Archive: Unarchiver could not unarchive.")
            }
        } else {
            print("Failed to Archive: LogText was not found.")
        }
    }
    
    func addPlaneText(planeText text:String){
        let convertedText = NSMutableAttributedString(string: text)
        addAttributedText(attributedText: convertedText)
    }
    
    func addAttributedText(attributedText text:NSMutableAttributedString){
        let finalText : NSMutableAttributedString = self.attributedText?.mutableCopy() as! NSMutableAttributedString
        finalText.insert(text, at: finalText.length)
        self.attributedText = finalText
        saveText()
    }
}
