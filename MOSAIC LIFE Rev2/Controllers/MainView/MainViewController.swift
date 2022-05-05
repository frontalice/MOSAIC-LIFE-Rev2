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
    
    // MARK: - LIFECYCLE
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
            mainView.activityLog.attributedText = NSMutableAttributedString(
                string: "日付が更新されました。\n" +
                        "[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n" +
                        "補正レベル: Lv\(sptRank) / 残り\(sptCount)日\n" +
                        "----------------------------------------------------\n"
            )
            // ログイン処理-3: ログ保存
            mainView.activityLog.saveText()
            // ログイン処理-4: ptPerHour初期化
            ptPerHour = 0
            userDefaults.set(.ptPerHour, ptPerHour)
        } else {
            mainView.activityLog.loadText()
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "ロード完了\n[\(DateManager.shared.fetchCurrentTime(type: .hourAndMinute))] 現在: \(String(currentPt))pts\n"
            ))
            mainView.currencyButton.setTitle("x\(sptRankData[sptRank] ?? 1.0)", for: .normal)
            mainView.currentSptLabel.text = String(currentSpt)
        }
        
        // View - frame
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        // View - monitor
        mainView.taskButton.addTarget(self, action: #selector(goToTask(_:)), for: .touchUpInside)
        mainView.shopButton.addTarget(self, action: #selector(goToShop(_:)), for: .touchUpInside)
        mainView.currencyButton.addTarget(self, action: #selector(setSptOptions(_:)), for: .touchUpInside)
        mainView.currentSptLabel.addTarget(self, action: #selector(currentSptEdited(_:)), for: .editingDidEnd)
        mainView.addingSptLabel.addTarget(self, action: #selector(addingSptEdited(_:)), for: .editingDidEnd)
        mainView.angerEffectButton.addTarget(self, action: #selector(angerEffectButtonTapped(_:)), for: .touchUpInside)
        mainView.exploreEffectButton.addTarget(self, action: #selector(exploreEffectButtonTapped(_:)), for: .touchUpInside)
        mainView.heartEffectButton.addTarget(self, action: #selector(heartEffectButtonTapped(_:)), for: .touchUpInside)
        NotificationCenter.default.addObserver(self, selector: #selector(writeLog(notification:)), name: .init(rawValue: "ACTIVITYLOG"), object: nil)
        
        print("現在時刻:\(DateManager.shared.fetchCurrentTime(type: .normal))")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        mainView.ptLabel.text = String(userDefaults.fetchInt(key: .currentPt))
        mainView.activityLog.scrollRangeToVisible(NSRange(location: mainView.activityLog.attributedText.length-1, length: 1))
        mainView.currencyButton.setTitle("x\(sptRankData[sptRank] ?? 1.0)", for: .normal)
        
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
    
    // MARK: - TARGET FUNCTIONS
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
    
    @objc func setSptOptions(_ sender: Any){
        let alertController = getAlertController(title: "SptOption", message: "", fields: 2, placeHolder: ["Rank","Count"])
        alertController.textFields![0].text = String(sptRank)
        alertController.textFields![1].text = String(sptCount)
        let alertAction = UIAlertAction(title: "OK", style: .default){ (_) -> Void in
            if let rank = Int(alertController.textFields![0].text!),
               let count = Int(alertController.textFields![1].text!){
                if rank >= 0 && rank <= 5 && count > 0 {
                    self.sptRank = rank
                    if rank != 5 && count > 2 {
                        self.sptCount = 2
                        self.userDefaults.set(.sptCount, 2)
                    }
                    self.sptCount = count
                    self.resetSpt()
                } else {
                    self.showAlert(message: "不正な入力値です。")
                }
            }
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func currentSptEdited(_ sender: Any){
        if let spt = Int(mainView.currentSptLabel.text!) {
            currentSpt = spt
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "現在Spt: \(currentSpt)spt\n"
            ))
            mainView.activityLog.saveText()
            judgeSptRank()
        }
    }
    
    @objc func addingSptEdited(_ sender: Any){
        if let spt = Int(mainView.addingSptLabel.text!){
            currentSpt += spt
            userDefaults.set(.spt, currentSpt)
            judgeSptRank()
            mainView.currentSptLabel.text = String(currentSpt)
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "現在Spt: \(currentSpt)spt (+\(spt))\n"
            ))
            mainView.activityLog.saveText()
        }
        mainView.addingSptLabel.text = "add..."
    }
    
    @objc func angerEffectButtonTapped(_ sender: Any){
        effectButtonTapped(num: 0, button: sender as! UIButton, effect: mainView.effectSympols[0][0])
    }
    
    @objc func exploreEffectButtonTapped(_ sender: Any){
        effectButtonTapped(num: 1, button: sender as! UIButton, effect: mainView.effectSympols[1][0])
    }
    
    @objc func heartEffectButtonTapped(_ sender: Any){
        effectButtonTapped(num: 2, button: sender as! UIButton, effect: mainView.effectSympols[2][0])
    }

    
    // MARK: - OTHER FUNCTIONS
    
    func resetSpt() -> Void {
        var moneyMultiplier : Double
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
            default:currentSpt = 0;     moneyMultiplier = 1.0;
        }
        mainView.currencyButton.setTitle("x\(moneyMultiplier)", for: .normal)
        mainView.currentSptLabel.text = String(currentSpt)
        userDefaults.set(.spt, currentSpt)
        userDefaults.set(.sptRank, sptRank)
        userDefaults.set(.sptCount, sptCount)
    }
    
    func judgeSptRank() {
        var tempRank = 0
        var moneyMultiplier : Double = 1.0
        var overCounter = 0
        
        if      currentSpt >= 15000 {
            overCounter = (currentSpt - 15000) / 3000
            tempRank = 5; moneyMultiplier = 5.0
        }
        else if currentSpt >= 12000 { tempRank = 4; moneyMultiplier = 4.0}
        else if currentSpt >= 9000  { tempRank = 3; moneyMultiplier = 3.0}
        else if currentSpt >= 6000  { tempRank = 2; moneyMultiplier = 2.0}
        else if currentSpt >= 3000  { tempRank = 1; moneyMultiplier = 1.5}
        else                        { tempRank = 0; moneyMultiplier = 1.0}
        
        if tempRank != sptRank {
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "補正レベルが変動しました: \(sptRank) -> \(tempRank) [x\(moneyMultiplier)]\n"
            ))
            mainView.activityLog.saveText()
            
            sptRank = tempRank
            userDefaults.set(.sptRank, sptRank)
            sptCount = 2 + overCounter
            userDefaults.set(.sptCount, sptCount)
            
            mainView.currencyButton.setTitle("x\(moneyMultiplier)", for: .normal)
        }
        if overCounter >= 1 {
            sptCount = 2 + overCounter
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "日数カウントが増加しました: 残り\(sptCount)日\n"
            ))
            mainView.activityLog.saveText()
            userDefaults.set(.sptCount, sptCount)
        }
    }
    
    @objc func writeLog(notification: NSNotification?) {
        let timeString = DateManager.shared.fetchCurrentTime(type: .hourAndMinute)
        let name = notification?.userInfo!["Name"] as? String ?? ""
        let point = notification?.userInfo!["Point"] as? Int ?? 0
        let obtainedPoint = notification?.userInfo!["ObtainedPoint"] as? Int ?? 0
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
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
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
            mainView.activityLog.addAttributedText(attributedText: text)
        case "Shop":
            let text = NSMutableAttributedString(
                string: "[\(timeString)] -\(point)pt【x\(userDefaults.fetchInt(key: .shopRate))】: \(name)\n"
            )
            text.addAttribute(.foregroundColor, value: UIColor.red, range: NSMakeRange(0, text.length))
            mainView.activityLog.addAttributedText(attributedText: text)
        case "Effect":
            let num = notification?.userInfo?["EffectType"] as! Int
            let counts = mainView.effectsCount[num]
            let text = NSMutableAttributedString(
                string: "Effect: \(mainView.effectSympols[num][0])x\(counts[0]) \(mainView.effectSympols[num][1])x\(counts[1]) \(mainView.effectSympols[num][2])x\(counts[2])\n"
            )
            text.addAttribute(.foregroundColor, value: UIColor.blue, range: NSMakeRange(0, text.length))
            mainView.activityLog.addAttributedText(attributedText: text)
        default:
            break
        }
        if modeType == "Task" || modeType == "Shop" {
            mainView.activityLog.addAttributedText(attributedText: NSMutableAttributedString(
                string: "[\(timeString)] 現在: \(userDefaults.fetchInt(key: .currentPt))pts\n"
            ))
        }
        mainView.activityLog.saveText()
        
    }
    
    func effectButtonTapped(num: Int,button: UIButton,effect: String){
        let alertController = getAlertController(title: effect, message: "", fields: 3, placeHolder: ["Lsize","Msize","Ssize"])
        for i in 0...2 {
            alertController.textFields![i].text = String(mainView.effectsCount[num][i])
        }
        let alertAction = UIAlertAction(title: "OK", style: .default){ (_) -> Void in
            // プロパティ更新
            for i in 0...2 {
                if let count = Int(alertController.textFields![i].text!){
                    self.mainView.effectsCount[num][i] = count
                } else {
                    // 何もしない。編集前の値をそのまま保持する
                }
            }
            self.userDefaults.set(.effectsCount, self.mainView.effectsCount)
            
            // ボタン内テキスト更新
            button.setTitle( { () -> String?  in
                var text = ""
                for j in 0 ... 2 {
                    text += "\(self.mainView.effectSympols[num][j])x \(self.mainView.effectsCount[num][j])\n"
                }
                return text.trimmingCharacters(in: .newlines)
            }(), for: .normal)
            
            // ログ書込み
            NotificationCenter.default.post(name: .init(rawValue: "ACTIVITYLOG"), object: nil, userInfo: [
                "Type":"Effect",
                "EffectType":num
            ])
        }
        alertController.addAction(alertAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
}
