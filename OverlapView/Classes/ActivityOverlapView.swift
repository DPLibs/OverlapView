import Foundation
import UIKit

public protocol ActivityOverlapViewPresetable {
    func showActivityOverlapView(_ mode: ActivityOverlapViewMode, in overlapContainer: OverlapViewContainer, completion: (() -> Void)?)
    func hideActivityOverlapView(in overlapContainer: OverlapViewContainer, completion: (() -> Void)?)
}

public extension ActivityOverlapViewPresetable where Self: UIViewController {
    
    func showActivityOverlapView(_ mode: ActivityOverlapViewMode, in overlapContainer: OverlapViewContainer, completion: (() -> Void)?) {
        ActivityOverlapView(mode: mode).show(in: overlapContainer, transition: .withoutAnimate, completion: completion)
    }
    
    func hideActivityOverlapView(in overlapContainer: OverlapViewContainer, completion: (() -> Void)?) {
        ActivityOverlapView.hide(in: overlapContainer, transition: .withoutAnimate, completion: completion)
    }
    
}

public struct ActivityOverlapViewMode {
    let backgroundColor: UIColor
    let activityColor: UIColor
    let coverColor: UIColor
    
    public init(backgroundColor: UIColor, activityColor: UIColor, coverColor: UIColor) {
        self.backgroundColor = backgroundColor
        self.activityColor = activityColor
        self.coverColor = coverColor
    }
    
    static let lightBgGrayAc = ActivityOverlapViewMode(backgroundColor: .white, activityColor: .gray, coverColor: .clear)
    static let darkBgWhiteAc = ActivityOverlapViewMode(backgroundColor: .black, activityColor: .white, coverColor: .clear)
}

open class ActivityOverlapView: OverlapView {
    
    public let activity = UIActivityIndicatorView()
    public let coverView = UIView()
    
    public var _mode: ActivityOverlapViewMode? {
        didSet {
            self.modeDidSet()
        }
    }
    
    open override var config: OverlapViewConfig {
        .init(viewsNonTouchSensitive: [], hideOnTouch: false, hideOnTouchTransition: .withoutAnimate)
    }
    
    open override class func show(_ view: OverlapView, in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super.show(view, in: overlapContainer, transition: .withoutAnimate, completion: completion)
    }
    
    open override class func hide(in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        switch overlapContainer {
        case .window:
            let view = OverlapView()
            view._hideInWindow(transition: .withoutAnimate, completion: completion)
        case let .superview(view):
            guard let subviews = view?.subviews else { return }
            subviews.forEach({
                ($0 as? ActivityOverlapView)?._hideInSuperview(transition: .withoutAnimate, completion: completion)
            })
        }
    }
    
    open override func show(in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super.show(in: overlapContainer, transition: .withoutAnimate, completion: completion)
    }
    
    open override func hide(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super.hide(transition: .withoutAnimate, completion: completion)
    }
    
    open override func _showInWindow(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super._showInWindow(transition: .withoutAnimate, completion: completion)
    }
    
    open override func _hideInWindow(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super._hideInWindow(transition: .withoutAnimate, completion: completion)
    }
    
    open override func _showInSuperview(superview: UIView?, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super._showInSuperview(superview: superview, transition: .withoutAnimate, completion: completion)
    }
    
    open override func _hideInSuperview(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        super._hideInSuperview(transition: .withoutAnimate, completion: completion)
    }
    
    public init(mode: ActivityOverlapViewMode) {
        self._mode = mode
        super.init(frame: .zero)
        self.prepareView()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareView()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.prepareView()
    }
    
    open func prepareView() {
        self.modeDidSet()

        self.coverView.removeFromSuperview()
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.layer.cornerRadius = 16
        self.addSubview(self.coverView)
        NSLayoutConstraint.activate([
            self.coverView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.coverView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.coverView.widthAnchor.constraint(equalToConstant: 32),
            self.coverView.heightAnchor.constraint(equalToConstant: 32)
        ])

        self.activity.removeFromSuperview()
        self.activity.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.activity)
        NSLayoutConstraint.activate([
            self.activity.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.activity.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        self.activity.startAnimating()
    }
    
    open func modeDidSet() {
        guard let mode = self._mode else { return }
        self.backgroundColor = mode.backgroundColor
        self.activity.color = mode.activityColor
        self.coverView.backgroundColor = mode.coverColor
    }
    
}
