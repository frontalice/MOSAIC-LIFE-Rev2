//
//  MainView.swift
//  Views
//
//  Created by Toshiki Hanakawa on 2022/04/18.
//

import UIKit

public final class MainView: XibLoadView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        ptLabel.layer.borderWidth = 2.0
        ptLabel.layer.borderColor = UIColor {_ in return #colorLiteral(red: 1, green: 0.4718433711, blue: 0, alpha: 1)}.cgColor
        ptLabel.layer.cornerRadius = 20
        ptLabel.layer.masksToBounds = true
        activityLog.layer.borderWidth = 1.0
        activityLog.layer.borderColor = UIColor.black.cgColor
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var pointLabelSet: UIView!
    @IBOutlet public weak var ptLabel: PtLabel!
    @IBOutlet public weak var activityLog: UITextView!
    @IBOutlet public weak var taskButton: UIButton!
    @IBOutlet public weak var shopButton: UIButton!
}


