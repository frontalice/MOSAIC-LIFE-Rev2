//
//  TaskView.swift
//  Views
//
//  Created by Toshiki Hanakawa on 2022/04/19.
//

import UIKit

public final class TaskView: XibLoadView {
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet public weak var taskListView: UITableView!
    @IBOutlet public weak var ptLabel: UILabel!
    @IBOutlet public weak var modeControl: UISegmentedControl!
    
}
