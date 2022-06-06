//
//  MainView.swift
//  Views
//

import UIKit

public final class MainView: XibLoadView {
    
    let userDefaults = UDDataStore()
    
    lazy var effectsCount : [[Int]] = userDefaults.fetchObject(key: .effectsCount) as! [[Int]]
    
    let effectSympols = [
        ["\u{1F534}", "\u{2B55}", "\u{1F53B}"],
        ["\u{1F4A0}", "\u{1F537}", "\u{1F539}"],
        ["\u{1F49A}", "\u{2733}", "\u{2747}"]
    ]
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        ptLabel.layer.borderWidth = 2.0
        ptLabel.layer.borderColor = UIColor {_ in return #colorLiteral(red: 1, green: 0.4718433711, blue: 0, alpha: 1)}.cgColor
        ptLabel.layer.cornerRadius = 20
        ptLabel.layer.masksToBounds = true
        ptLabel.text = String(userDefaults.fetchInt(key: .currentPt))
        activityLog.layer.borderWidth = 1.0
        activityLog.layer.borderColor = UIColor.black.cgColor
        
        let effectButtons = [angerEffectButton,exploreEffectButton,heartEffectButton]
        
        for i in 0 ... 2 {
            effectButtons[i]?.titleLabel?.numberOfLines = 3
            effectButtons[i]?.titleLabel?.textAlignment = .center
            effectButtons[i]?.setTitle( { () -> String?  in
                var text = ""
                for j in 0 ... 2 {
                    text += "\(effectSympols[i][j])x \(effectsCount[i][j])\n"
                }
                return text.trimmingCharacters(in: .newlines)
            }(), for: .normal)
        }
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var pointLabelSet: UIView!
    @IBOutlet public weak var ptLabel: PtLabel!
    @IBOutlet public weak var activityLog: ActivityLog!
    @IBOutlet public weak var taskButton: UIButton!
    @IBOutlet public weak var shopButton: UIButton!
    
    //sptStack
    @IBOutlet public weak var currencyButton: UIButton!
    @IBOutlet public weak var currentSptLabel: UITextField!
    @IBOutlet public weak var addingSptLabel: UITextField!
    
    //EffectsStack
    @IBOutlet public weak var angerEffectButton: UIButton!
    @IBOutlet public weak var exploreEffectButton: UIButton!
    @IBOutlet public weak var heartEffectButton: UIButton!
}


