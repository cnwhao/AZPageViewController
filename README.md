# IOS开发--UIPageViewController

标签（空格分隔）： IOS

---

回顾IOS开发中的知识点，如有引用未注明出处，望告知；如有理解有错误的地方，望指正。感谢！！！

---

Demo：[https://github.com/cnwhao/AZPageViewController.git](https://github.com/cnwhao/AZPageViewController.git)

---

- [x] UIPageViewController简介
- [x] UIPageViewController监听滚动

---
  
项目上首页改版，布局方式类似今日头条多栏页面的方式。  
方案1：嵌套UICollectionView。  
方案2：使用UIPageViewController的一些特性。  
既然苹果提供了针对分页专门设计的控件，果断的使用方案2。  

---



## UIPageViewController

UIPageViewController是iOS5.0之后提供的一个分页控件可以实现图片轮播效果和翻书效果。

```swift

open class UIPageViewController : UIViewController {

    
    public init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil)

    public init?(coder: NSCoder)

    
    weak open var delegate: UIPageViewControllerDelegate?
    
    weak open var dataSource: UIPageViewControllerDataSource? // If nil, user gesture-driven navigation will be disabled.
    // 翻书效果curl和平移效果scroll
    open var transitionStyle: UIPageViewController.TransitionStyle { get }
    // 方向 水平和垂直
    open var navigationOrientation: UIPageViewController.NavigationOrientation { get }
    
    // 仅在style为UIPageViewControllerTransitionStylePageCurl时有效
    open var spineLocation: UIPageViewController.SpineLocation { get } // If transition style is 'UIPageViewControllerTransitionStylePageCurl', default is 'UIPageViewControllerSpineLocationMin', otherwise 'UIPageViewControllerSpineLocationNone'.

    // 如果设置了SpineLocation mid这个选项，则需要设置true。
    // Whether client content appears on both sides of each page. If 'NO', content on page front will partially show through back.
    // If 'UIPageViewControllerSpineLocationMid' is set, 'doubleSided' is set to 'YES'. Setting 'NO' when spine location is mid results in an exception.
    open var isDoubleSided: Bool // Default is 'NO'.

    
    // An array of UIGestureRecognizers pre-configured to handle user interaction. Initially attached to a view in the UIPageViewController's hierarchy, they can be placed on an arbitrary view to change the region in which the page view controller will respond to user gestures.
    // Only populated if transition style is 'UIPageViewControllerTransitionStylePageCurl'.
    
    open var gestureRecognizers: [UIGestureRecognizer] { get }

    open var viewControllers: [UIViewController]? { get }

    // 设置可见视图控制器。数组应该只包含在动画完成后可见的视图控制器。如果设置SpineLocation mid，isDoubleSided true，则必须包含两个视图控制器。
    // Set visible view controllers, optionally with animation. Array should only include view controllers that will be visible after the animation has completed.
    // For transition style 'UIPageViewControllerTransitionStylePageCurl', if 'doubleSided' is 'YES' and the spine location is not 'UIPageViewControllerSpineLocationMid', two view controllers must be included, as the latter view controller is used as the back.
    open func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewController.NavigationDirection, animated: Bool, completion: ((Bool) -> Void)? = nil)
}

```


```swift

public enum SpineLocation : Int {
    case none // Returned if 'spineLocation' is queried when 'transitionStyle' is not 'UIPageViewControllerTransitionStylePageCurl'.
    // 单页显示, 从上往下翻页
    case min // Requires one view controller.
    // 双页显示
    case mid // Requires two view controllers.
    // 单页显示, 从下往上翻
    case max // Requires one view controller.
}

```


## UIPageViewController 代理

```swift 
public protocol UIPageViewControllerDelegate : NSObjectProtocol {
    // 当页面即将切换之前调用
    // Sent when a gesture-initiated transition begins.
    @available(iOS 6.0, *)
    optional func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController])

    // 当页面切换动画完成之后调用
    // Sent when a gesture-initiated transition ends. The 'finished' parameter indicates whether the animation finished, while the 'completed' parameter indicates whether the transition completed or bailed out (if the user let go early).
    @available(iOS 5.0, *)
    optional func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)

    // 仅为翻书效果,并且横竖屏状态变化的时候时回调, 重新设置书脊的位置
    // Delegate may specify a different spine location for after the interface orientation change. Only sent for transition style 'UIPageViewControllerTransitionStylePageCurl'.
    // Delegate may set new view controllers or update double-sided state within this method's implementation as well.
    @available(iOS 5.0, *)
    optional func pageViewController(_ pageViewController: UIPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewController.SpineLocation

    // 下面两个方法只要是设置UIPageViewController（阅读器）支持的屏幕类型
    // 返回支持的方法,只在创建控制器后的初始化时调
    @available(iOS 7.0, *)
    optional func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: UIPageViewController) -> UIInterfaceOrientationMask
    // 优先使用的方向
    @available(iOS 7.0, *)
    optional func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation
}

```

```

public protocol UIPageViewControllerDataSource : NSObjectProtocol {

    // 返回当前viewController 的前一个viewController
    // In terms of navigation direction. For example, for 'UIPageViewControllerNavigationOrientationHorizontal', view controllers coming 'before' would be to the left of the argument view controller, those coming 'after' would be to the right.
    // Return 'nil' to indicate that no more progress can be made in the given direction.
    // For gesture-initiated transitions, the page view controller obtains view controllers via these methods, so use of setViewControllers:direction:animated:completion: is not required.
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?

    // 返回当前viewController 的后一个viewController
    @available(iOS 5.0, *)
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    
    // 调用setViewControllers触发回调，如果同时实现了下面两个代理方法，平移效果，则会在视图控制器底部显示page indicator
    // pagecontrol 点数量
    // A page indicator will be visible if both methods are implemented, transition style is 'UIPageViewControllerTransitionStyleScroll', and navigation orientation is 'UIPageViewControllerNavigationOrientationHorizontal'.
    // Both methods are called in response to a 'setViewControllers:...' call, but the presentation index is updated automatically in the case of gesture-driven navigation.
    @available(iOS 6.0, *)
    optional func presentationCount(for pageViewController: UIPageViewController) -> Int // The number of items reflected in the page indicator.
    // pagecontrol高亮点位置
    @available(iOS 6.0, *)
    optional func presentationIndex(for pageViewController: UIPageViewController) -> Int // The selected item reflected in the page indicator.
}

```

---


## UIPageViewController监听滚动

实现首页内容滚动和segment联动的时候，需要实时监听UIPageViewController内容的滚动位置。通过遍历UIPageViewController子视图获取控制滑动的UIScrollview，然后引出代理监听滚动，发现滚动不是连续的，经过复杂的曲线数据转换，实现了内容滚动和segment联动。快速滑动时，仍然存在判断左右滑动问题，具体细节不再赘述。和[简书博主](https://www.jianshu.com/p/4cc4638f44e4)这篇遭遇到了同样的经历，博主已经描述的很详细了，同样也学习了博主的方式，解决了问题。[demo](https://github.com/cnwhao/AZPageViewController.git)


---
