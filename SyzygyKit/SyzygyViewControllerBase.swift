//
//  SyzygyViewController.swift
//  SyzygyKit
//
//  Created by Dave DeLong on 1/18/18.
//  Copyright © 2018 Syzygy. All rights reserved.
//

public extension Abort.Reason {
    public static func viewController(_ vc: PlatformViewController, mustBeChildOf parent: PlatformViewController) -> Abort.Reason {
        let p = String(describing: vc.parent)
        return Abort.Reason("\(vc) must be a direct child of \(parent), but is actually a child of \(p)")
    }
    public static func view(_ view: PlatformView, mustBeInHierarchyOf vc: PlatformViewController) -> Abort.Reason {
        return Abort.Reason("Container view \(view) is not in \(vc)'s view hierarchy")
    }
}


/// _SyzygyViewControllerBase exists because of weirdness in creating cross-platform view controllers
/// and inconsistent view controller API between the two
///
/// On macOS, the "child view controller" primitives are -insertChild:atIndex: and -removeChildAtIndex:
/// On iOS, the primitives are -addChildViewController: and -removeFromParentViewController
///
/// There is no sane way to create a class that only overrides one set on one platform and another set on
/// another platform, all within the same class (at least, not without getting in to runtime shenanigans).
/// Thus, the common logic of both kinds of view controllers is extracted in to this "Base" class,
/// and then the actual "public" classes are platform-specific versions in the ~ios/~macos files,
/// which declare the actual "SyzygyViewController" class.
///
/// DO NOT subclass _SyzygyViewControllerBase yourself.
open class _SyzygyViewControllerBase: PlatformViewController {
    
    // Selection
    internal let parentWantsSelection = MirroredProperty(false)
    internal let wantsSelection = MutableProperty(false)
    public let selectable = MutableProperty(false)
    public let selected: Property<Bool>
    
    // Background Color
    public let defaultBackgroundColor = MutableProperty<PlatformColor?>(.white)
    public let selectedBackgroundColor = MutableProperty<PlatformColor?>(.defaultSelectionColor)
    public let currentBackgroundColor: Property<PlatformColor?>
    
    public let disposable = CompositeDisposable()
    
    public var syzygyView: SyzygyView { return view as! SyzygyView }
    
    #if BUILDING_FOR_MOBILE
    private var _preferredStatusBarStyle: UIStatusBarStyle = .default
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        get { return _preferredStatusBarStyle }
        set {
            _preferredStatusBarStyle = newValue
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    #endif
    
    public enum UI {
        case empty
        case `default`
        case explicit(PlatformNib.Name, Bundle)
    }
    
    public init(ui: UI = .default) {
        let actuallySelected = parentWantsSelection.combine(wantsSelection, selectable).map { (parentWants, wants, can) -> Bool in
            return (parentWants || wants) && can
        }
        selected = actuallySelected.skipRepeats()
        
        let bgColor = selected.combine(defaultBackgroundColor, selectedBackgroundColor).map { (isSelected, def, sel) -> PlatformColor? in
            let color = sel ?? def
            return isSelected ? color : def
        }
        currentBackgroundColor = bgColor.skipRepeats(==)
        
        let nib: PlatformNib.Name?
        let bundle: Bundle?
        
        switch ui {
            case .empty:
                nib = PlatformNib.Name("Empty")
                bundle = Bundle(for: SyzygyViewController.self)
            case .default:
                nib = PlatformNib.Name("\(type(of: self))")
                bundle = Bundle(for: type(of: self))
            case .explicit(let n, let b):
                nib = n
                bundle = b
        }
        super.init(nibName: nib, bundle: bundle)
    }
    
    required public init?(coder: NSCoder) { Abort.because(.shutUpXcode) }
    
    open override func loadView() {
        super.loadView()
        
        let ddv: SyzygyView
        
        if let v = view as? SyzygyView {
            ddv = v
        } else {
            let newView = SyzygyView(frame: loadedView.frame)
            newView.embedSubview(loadedView)
            view = newView
            
            ddv = newView
        }
        ddv.controller = self
        
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        disposable += currentBackgroundColor.observe { [weak self] color in
            self?.syzygyView.backgroundColor = color
        }
    }
    
    open func select() { wantsSelection.value = true }
    open func deselect() { wantsSelection.value = false }
    public func toggleSelection() {
        // this negates the selection value, because ! is a (Bool) -> Bool function
        wantsSelection.modify(!)
    }
    
    open func viewDidMoveToSuperview(_ superview: PlatformView?) { }
    
    open func viewDidMoveToWindow(_ window: PlatformWindow?) { }
    
    open func viewSystemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: PlatformLayoutConstraintPriority, verticalFittingPriority: PlatformLayoutConstraintPriority) -> CGSize {
        return targetSize
    }
    
}
