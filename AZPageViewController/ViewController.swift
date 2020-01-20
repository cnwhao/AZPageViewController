//
//  ViewController.swift
//  AZPageViewController
//
//  Created by wanghaohao on 2020/1/20.
//  Copyright © 2020 whao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    private var bufferedControllers = [AZPageContentController]()
    private lazy var progressLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    private lazy var pageViewContoller:AZPageViewController = {
        let op = [UIPageViewController.OptionsKey.spineLocation: UIPageViewController.SpineLocation.min]
        let controller = AZPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: op)
        controller.pageCount = 6
        controller.viewControllerAtIndexBlock = { [weak self] index in
            return self?.previewController(formPage: index)
        }
        controller.indexOfViewControllerBlock = { [weak self] viewController in
            return (viewController as? AZPageContentController)?.index
        }
        return controller
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .lightGray
        // Do any additional setup after loading the view.
        
        self.setUpSubviews()
    }
    private func setUpSubviews() {
        self.addChild(pageViewContoller)
        self.view.addSubview(pageViewContoller.view)
        self.view.addSubview(progressLabel)
        
        var rect = self.view.bounds
        rect.origin.y = 100
        rect.size.height = 40
        progressLabel.frame = rect
        
        let start = self.previewController(formPage: 0)
        pageViewContoller.setViewControllers([start], direction: .forward, animated: false, completion: nil)
    }
}

extension ViewController {
    private func viewControllerAt(index: Int) -> UIViewController {
        for vc in bufferedControllers {
            if vc.index == index {
                return vc
            }
        }
        let vc = AZPageContentController(index: index)
        vc.view.backgroundColor = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange][index % 4]
        bufferedControllers.append(vc)
        
        pageViewContoller.addListenerWithReadyViewControllers(bufferedControllers) { [weak self] (currentIndex, offX) in
            self?.progressLabel.text = "\(offX / (self?.pageViewContoller.view.bounds.size.width ?? 1))"
        }
        return vc
    }
    private func previewController(formPage index: Int) -> UIViewController {
        return viewControllerAt(index: index)
    }
}
