//
//  AZPageContentController.swift
//  AZPageViewController
//
//  Created by wanghaohao on 2020/1/20.
//  Copyright © 2020 whao. All rights reserved.
//

import UIKit

class AZPageContentController: UIViewController {
    
    var index:Int = 0
    
    private lazy var contentLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // Do any additional setup after loading the view.
        view.addSubview(contentLabel)
        contentLabel.frame = view.bounds
    }
    init(index:Int) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
        contentLabel.text = "\(index)"
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
