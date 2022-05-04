//
//  ViewController.swift
//  MOSAIC LIFE Rev.
//
//  Created by Toshiki Hanakawa on 2022/04/18.
//

import UIKit

class MainViewController: UIViewController {
    
    private lazy var mainView = MainView()
    
    let userDefaults : UDDataStore = UDDataStore()
    
    lazy var currentPt = userDefaults.fetchInt(key: .currentPt)
    lazy var ptPerHour = userDefaults.fetchInt(key: .ptPerHour)
    
    lazy var currentSpt = userDefaults.fetchInt(key: .spt)
    lazy var sptRank = userDefaults.fetchInt(key: .sptRank)
    lazy var sptCount = userDefaults.fetchInt(key: .sptCount)
    let sptRankData = [ 0:1.0, 1:1.5, 2:2.0, 3:3.0, 4:4.0, 5:5.0 ]
    
    override func loadView() {
        view = mainView
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // View - frame
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // View - monitor
        mainView.taskButton.addTarget(self, action: #selector(goToTask(_:)), for: .touchUpInside)
        mainView.shopButton.addTarget(self, action: #selector(goToShop(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(writeLog(notification:)), name: .init(rawValue: "ACTIVITYLOG"), object: nil)
        
        // ログイン処理
        if DateManager.shared.judgeIsDayChanged() {
            print("DayChanged")
            // ログイン処理-1 : spt処理
            if sptRank != 0 {sptCount -= 1} else {sptCount = 0}
            if sptCount == 0 && sptRank > 0 {
                sptRank -= 1
                sptCount = 2
            }
            resetSpt()
            // ログイン処理-2: ログ初期化
            mainView.activityLog.attributedText = NSMutableAttributedString(string:
                "日付が更新されました。\n" +
                "[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n" +
                "補正レベル: Lv\(sptRank) / 残り\(sptCount)日\n" +
                "----------------------------------------------------\n")
            // ログイン処理-3: ログ保存
//            mainView.activityLog.saveText()
            saveText()
            // ログイン処理-4: ptPerHour初期化
            ptPerHour = 0
            userDefaults.set(.ptPerHour, ptPerHour)
        } else {
//            mainView.activityLog.loadText()
//            mainView.activityLog.attributedText as! NSMutableAttributedString += NSMutableAttributedString(string: "[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n")
            // テキストログ取得
            if let archivedLog = UserDefaults.standard.object(forKey: "ACTIVITYLOGTEXT") {
                if let unarchivedText = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(archivedLog as! Data) as? NSAttributedString {
                    mainView.activityLog.attributedText = unarchivedText.mutableCopy() as! NSMutableAttributedString
                } else {
                    mainView.activityLog.attributedText = NSMutableAttributedString(string: "ログの読み込みに失敗しました。\n[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n")
                }
            // テキストログ取得失敗時
            } else {
                mainView.activityLog.attributedText = NSMutableAttributedString(string: "ログ内容が空です。\n[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n")
            }
        }
        
        print("現在時刻:\(DateManager.shared.fetchCurrentTime(type: .normal))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mainView.ptLabel.text = String(userDefaults.fetchInt(key: .currentPt))
        mainView.activityLog.scrollRangeToVisible(NSRange(location: mainView.activityLog.attributedText.length-1, length: 1))
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillChangeFrameNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func goToTask(_ sender: Any) {
        self.performSegue(withIdentifier: "toTask", sender: self)
    }
    
    @objc private func goToShop(_ sender: Any) {
        self.performSegue(withIdentifier: "toShop", sender: self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if mainView.activityLog.isFirstResponder || mainView.currentSptLabel.isFirstResponder || mainView.addingSptLabel.isFirstResponder {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0 {
                    self.view.frame.origin.y -= keyboardSize.height
                } else {
                    let suggestionHeight = self.view.frame.origin.y + keyboardSize.height
                    self.view.frame.origin.y -= suggestionHeight
                }
            }
        }
    }
    
    @objc func keyboardWillHide() {
        if mainView.activityLog.isFirstResponder || mainView.currentSptLabel.isFirstResponder || mainView.addingSptLabel.isFirstResponder {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y = 0
            }
        }
    }
    
    func resetSpt() -> Void {
        var moneyMultiplier : Double = 1.0
        switch sptRank {
            case 5:
                if sptCount > 2 {
                    currentSpt = 15000 + (sptCount-1)/2 * 3000
                } else {
                    currentSpt = 15000
                }
                moneyMultiplier = 5.0;
            case 4: currentSpt = 12000; moneyMultiplier = 4.0;
            case 3: currentSpt = 9000;  moneyMultiplier = 3.0;
            case 2: currentSpt = 6000;  moneyMultiplier = 2.0;
            case 1: currentSpt = 3000;  moneyMultiplier = 1.5;
            case 0: currentSpt = 0;     moneyMultiplier = 1.0;
            default:currentSpt = 0;
        }
        mainView.currencyButton.setTitle("x\(moneyMultiplier)", for: .normal)
        userDefaults.set(.spt, currentSpt)
        userDefaults.set(.sptRank, sptRank)
        userDefaults.set(.sptCount, sptCount)
    }
    
    @objc func writeLog(notification: NSNotification?) {
        let timeString = DateManager.shared.fetchCurrentTime(type: .hourAndMinute)
        let name = notification?.userInfo!["Name"] as! String
        let point = notification?.userInfo!["Point"] as! Int
        let obtainedPoint = notification?.userInfo!["ObtainedPoint"] as! Int
        let modeType = notification?.userInfo!["Type"] as! String
        
        let presentHour = { () -> Int in
            var hour = Int(DateManager.shared.fetchCurrentTime(type: .hour))!
            if hour < 4 {
                switch hour {
                    case 0: hour = 24
                    case 1: hour = 25
                    case 2: hour = 26
                    case 3: hour = 27
                    default: break
                }
            }
            return hour
        }()
        
        let lastHour = { () -> Int in
            var hour = userDefaults.fetchInt(key: .lastHour)
            if hour < 4 {
                switch hour {
                    case 0: hour = 24
                    case 1: hour = 25
                    case 2: hour = 26
                    case 3: hour = 27
                    default: break
                }
            }
            return hour
        }()
        
        userDefaults.set(.lastHour, presentHour)
        
        ptPerHour = userDefaults.fetchInt(key: .ptPerHour)
        
        // 切り取り線処理
        if presentHour > lastHour {
            addAttributedText(attributedText: NSMutableAttributedString(
                string: "---------↑\(lastHour)-\(presentHour)時合計: \(ptPerHour)pt---------\n"
            ))
            ptPerHour = obtainedPoint
            userDefaults.set(.ptPerHour, obtainedPoint)
        } else {
            ptPerHour += obtainedPoint
            userDefaults.set(.ptPerHour, ptPerHour)
        }
        
        // 書込み処理
        switch modeType{
        case "Task":
            let text = NSMutableAttributedString(
                string: "[\(timeString)] +\(point)pt【x\(userDefaults.fetchInt(key: .taskRate))】: \(name)\n"
            )
            text.addAttribute(.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, text.length))
            addAttributedText(attributedText: text)
        case "Shop":
            let text = NSMutableAttributedString(
                string: "[\(timeString)] -\(point)pt【x\(userDefaults.fetchInt(key: .shopRate))】: \(name)\n"
            )
            text.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, text.length))
            addAttributedText(attributedText: text)
        default:
            break
        }
        addAttributedText(attributedText: NSMutableAttributedString(
            string: "[\(timeString)] 現在: \(userDefaults.fetchInt(key: .currentPt))pts\n"
        ))
        saveText()
        
    }
    
    func addAttributedText(attributedText text:NSMutableAttributedString){
        let finalText : NSMutableAttributedString = mainView.activityLog.attributedText?.mutableCopy() as! NSMutableAttributedString
        finalText.insert(text, at: finalText.length)
        mainView.activityLog.attributedText = finalText
    }
    
    func saveText(){
        let archivedText = try! NSKeyedArchiver.archivedData(withRootObject: mainView.activityLog.attributedText!, requiringSecureCoding: false)
        UserDefaults.standard.set(archivedText, forKey: "ACTIVITYLOGTEXT")
    }
    
}
