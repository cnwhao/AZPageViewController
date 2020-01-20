//
//  AZPageViewController.swift
//  AZPageViewController
//
//  Created by wanghaohao on 2020/1/20.
//  Copyright © 2020 whao. All rights reserved.
//

import UIKit

class AZPageViewController: UIPageViewController {
    /// page 数量
    open var pageCount:Int = 0
    /// index位置viewcontroller
    open var viewControllerAtIndexBlock:((_ index:Int)->(UIViewController?))?
    /// viewcontroller所在位置index
    open var indexOfViewControllerBlock:((_ viewContoller:UIViewController)->(Int?))?
    
    /// 当前位置 0..<pageCount
    private var currentPage: Int = 0
    private var scrollDidScroll: ((Int, CGFloat)->Void)?
    private var readyViewControllers: [UIViewController]?
    private var estimateOffSetX: CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        /// 获得uiscrollview 设置代理 监听滚动
        for subView: UIView in view.subviews {
            if subView.isKind(of: UIScrollView.classForCoder()) {
                let tempScrollView = subView as? UIScrollView
                tempScrollView?.delegate = self
            }
        }
        self.delegate = self
        self.dataSource = self
    }
    func addListenerWithReadyViewControllers(_ readyViewControllers: [UIViewController], didScroll scrollDidScroll: @escaping (Int, CGFloat)->Void){
        self.readyViewControllers = readyViewControllers
        self.scrollDidScroll = scrollDidScroll
    }
}
extension AZPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = view.frame.width
        for vc in readyViewControllers!{
            let p = vc.view.convert(CGPoint(), to: view)
            if (p.x) > CGFloat(0.0) && (p.x) < pageWidth{
                let estimatePage = (readyViewControllers?.firstIndex(of: vc))!
                estimateOffSetX = CGFloat(estimatePage) * pageWidth - (p.x)
            }
        }
        //如果是最后一个viewcontroller
        if estimateOffSetX >= CGFloat((readyViewControllers?.count)!-1)*pageWidth{
            let p = readyViewControllers?[(readyViewControllers?.count)!-1].view.convert(CGPoint(), to: view)
            estimateOffSetX = CGFloat((readyViewControllers?.count)!-1) * pageWidth - (p?.x)!
        }
        scrollDidScroll!(currentPage,estimateOffSetX)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = view.frame.width
        currentPage = Int(round(estimateOffSetX/pageWidth))
        if currentPage < 0 {
            currentPage = (readyViewControllers?.count)! - 1
        }
        estimateOffSetX = CGFloat(currentPage)*pageWidth
        scrollDidScroll!(currentPage, estimateOffSetX)
    }
}
extension AZPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfViewControllerBlock?(viewController) else {
            return nil
        }
        // 第一页
        if index == 0 {
            return nil
        }
        return viewControllerAtIndexBlock?(index - 1)
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = indexOfViewControllerBlock?(viewController) else {
            return nil
        }
        // 最后一页
        if index == pageCount - 1 {
            return nil
        }
        return viewControllerAtIndexBlock?(index + 1)
    }
    func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation {
        return .none
    }
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageCount
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return currentPage
    }
}
