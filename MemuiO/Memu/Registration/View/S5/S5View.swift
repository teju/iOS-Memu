//
//  S5View.swift
//  Memu
//
//  Created by Akash Arun Jambhulkar (Digital) on 4/25/20.
//  Copyright © 2020 APPLE. All rights reserved.
//

import UIKit
//import Reusable

@IBDesignable
class S5View: UIView {
    
    let nibName = "S5View"

    //MARK: - IBOutlets
    @IBOutlet var customView: UIView!
    @IBOutlet weak var txtOfficeAddress: UITextField!
    @IBOutlet weak var txtWorkEmail: UITextField!
    
    //MARK: - UIView Overided methods
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    
    override init(frame: CGRect) {
        // Call super init
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        configureXIB()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        configureXIB()
    }
    
    //MARK: - Custom Methods
    func configureXIB() {
        customView = configureNib()
        
        // use bounds not frame or it'll be offset
        customView.frame = bounds
        
        // Make the flexible view
        customView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(customView)
    }
    
    func configureNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
