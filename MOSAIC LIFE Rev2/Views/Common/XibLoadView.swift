//
//  XibLoadView.swift
//  Views
//
//  Created by Toshiki Hanakawa on 2022/04/18.
//

import UIKit

// このViewを継承する際は、継承先のViewと同名のxibファイルを作ること

public class XibLoadView: UIView {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadNib()
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        loadNib()
    }

    private func loadNib() {
        let nibName = String(describing: type(of: self))
        let bundle = Bundle(for: type(of: self))
        let view = bundle.loadNibNamed(nibName, owner: self, options: nil)?.first as! UIView
        view.frame = bounds
        view.translatesAutoresizingMaskIntoConstraints = true
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
}
