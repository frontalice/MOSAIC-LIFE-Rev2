//
//  TaskView.swift
//  Views
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import UIKit

public final class TaskView: CommonListView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        listTable = taskListView
        pointLabel = ptLabel
        rateSegmentControl = modeControl
        if #available(iOS 15, *) {
            listTable.sectionHeaderTopPadding = 0.0
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var taskListView: UITableView!
    @IBOutlet public weak var ptLabel: UILabel!
    @IBOutlet public weak var modeControl: UISegmentedControl!
    
}
