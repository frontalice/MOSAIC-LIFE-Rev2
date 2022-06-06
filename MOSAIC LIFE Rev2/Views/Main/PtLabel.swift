//
//  ptLabel.swift
//  Views
//

import UIKit

public class PtLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
    
    public override func drawText(in rect: CGRect) {
        let newRect = rect.inset(by: padding)
        super.drawText(in: newRect)
    }
    
    public override var intrinsicContentSize: CGSize {
        var contentSize = super.intrinsicContentSize
        contentSize.height += padding.top + padding.bottom
        contentSize.width += padding.left + padding.right
        return contentSize
    }
    
    public override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentSize = super.sizeThatFits(size)
        contentSize.width += padding.left + padding.right
        contentSize.height += padding.top + padding.bottom
        return contentSize
    }

    //　↓これをやると.textが消えるわ.textを再代入しても反映されないわでハマるので親Viewのinit()内でやること
//    public override func draw(_ rect: CGRect) {
//        self.layer.borderWidth = 2.0
//        self.layer.borderColor = UIColor {_ in return #colorLiteral(red: 1, green: 0.4718433711, blue: 0, alpha: 1)}.cgColor
//        self.layer.cornerRadius = 20
//        self.layer.masksToBounds = true
//    }
}
