//
//  ShopView.swift
//  MOSAIC LIFE Rev2
//

import Foundation

import UIKit

public final class ShopView: CommonListView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        listTable = shopListView
        pointLabel = ptLabel
        rateLabel = shopRateLabel
        checkBox = checkButton
        if #available(iOS 15, *) {
            listTable.sectionHeaderTopPadding = 0.0
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var shopListView: UITableView!
    @IBOutlet public weak var ptLabel: UILabel!
    @IBOutlet public weak var shopRateLabel: UILabel!
    @IBOutlet public weak var checkButton: UIButton!
}
