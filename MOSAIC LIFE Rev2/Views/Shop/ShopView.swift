//
//  ShopView.swift
//  MOSAIC LIFE Rev2
//
//  Created by Toshiki Hanakawa on 2022/04/21.
//

import Foundation

import UIKit

public final class ShopView: CommonListView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        listTable = shopListView
        pointLabel = ptLabel
        if #available(iOS 15, *) {
            listTable.sectionHeaderTopPadding = 0.0
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var shopListView: UITableView!
    @IBOutlet public weak var ptLabel: UILabel!
}
