import Foundation
import UIKit

public protocol OverlapViewPresentable {
    func showOverlapView(_ view: OverlapView, in overlapContainer: OverlapViewContainer, transition: ViewTransition, completion: (() -> Void)?)
    func hideOverlapView(in overlapContainer: OverlapViewContainer, transition: ViewTransition, completion: (() -> Void)?)
}

public extension OverlapViewPresentable where Self: UIViewController {
    
    func showOverlapView(_ view: OverlapView, in overlapContainer: OverlapViewContainer, transition: ViewTransition, completion: (() -> Void)?) {
        OverlapView.show(view, in: overlapContainer, transition: transition, completion: completion)
    }
    
    func hideOverlapView(in overlapContainer: OverlapViewContainer, transition: ViewTransition, completion: (() -> Void)?) {
        OverlapView.hide(in: overlapContainer, transition: transition, completion: completion)
    }
    
}

public struct OverlapViewConfig {
    public let viewsNonTouchSensitive: [UIView?]
    public let hideOnTouch: Bool
    public let hideOnTouchTransition: ViewTransition
    
    public init(viewsNonTouchSensitive: [UIView?], hideOnTouch: Bool, hideOnTouchTransition: ViewTransition) {
        self.viewsNonTouchSensitive = viewsNonTouchSensitive
        self.hideOnTouch = hideOnTouch
        self.hideOnTouchTransition = hideOnTouchTransition
    }
    
    public static let `default` = OverlapViewConfig(viewsNonTouchSensitive: [], hideOnTouch: true, hideOnTouchTransition: .default)
}

public enum OverlapViewContainer {
    case window
    case superview(_ view: UIView?)
}

open class OverlapView: UIView {
    
    fileprivate static var window: UIWindow?
    fileprivate var overlapContainer: OverlapViewContainer?
    
    open var config: OverlapViewConfig { .default }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard self.config.hideOnTouch else { return }
        
        let currentLocations = self.config.viewsNonTouchSensitive.filter({
            guard let view = $0, let location = touches.first?.location(in: view), view.bounds.contains(location) else { return false }
            return true
        })
        guard currentLocations.isEmpty else { return }
        
        self.hide(transition: self.config.hideOnTouchTransition, completion: nil)
    }
    
    open class func show(_ view: OverlapView, in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        self.hide(in: overlapContainer, transition: .withoutAnimate, completion: nil)
        view.show(in: overlapContainer, transition: transition, completion: completion)
    }
    
    open class func hide(in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        switch overlapContainer {
        case .window:
            let view = OverlapView()
            view._hideInWindow(transition: transition, completion: completion)
        case let .superview(view):
            guard let subviews = view?.subviews else { return }
            subviews.forEach({
                ($0 as? OverlapView)?._hideInSuperview(transition: transition, completion: completion)
            })
        }
    }
    
    open func show(in overlapContainer: OverlapViewContainer, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        self.hide(transition: .withoutAnimate, completion: nil)
        self.overlapContainer = overlapContainer
        switch overlapContainer {
        case .window:
            self._showInWindow(transition: transition, completion: completion)
        case let .superview(view):
            self._showInSuperview(superview: view, transition: transition, completion: completion)
        }
    }
    
    open func hide(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        guard let overlapContainer = self.overlapContainer else { return }
        switch overlapContainer {
        case .window:
            self._hideInWindow(transition: transition, completion: completion)
        case .superview:
            self._hideInSuperview(transition: transition, completion: completion)
        }
    }
    
    open func _showInWindow(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.windowLevel = .alert
        window.alpha = 0.0
        
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        controller.view.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: controller.view.topAnchor),
            self.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor)
        ])
        
        window.rootViewController = controller
        window.makeKeyAndVisible()
        OverlapView.window = window
        
        UIWindow.transition(
            with: self,
            duration: transition.duration,
            options: transition.options,
            animations: {
                OverlapView.window?.alpha = 1.0
            },
            completion: { completed in
                guard completed else { return }
                completion?()
            }
        )
    }
    
    open func _hideInWindow(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        guard let window = OverlapView.window else { return }
        
        UIView.transition(
            with: window,
            duration: transition.duration,
            options: transition.options,
            animations: {
                window.alpha = 0.0
            },
            completion: { completed in
                guard completed else { return }
                OverlapView.window?.removeFromSuperview()
                OverlapView.window = nil
                completion?()
            }
        )
    }
    
    open func _showInSuperview(superview: UIView?, transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        guard let superview = superview else { return }
        
        self.alpha = 0.0
        superview.addSubview(self)
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
        
        UIView.transition(
            with: self,
            duration: transition.duration,
            options: transition.options,
            animations: { [weak self] in
                self?.alpha = 1.0
            },
            completion: { completed in
                guard completed else { return }
                completion?()
            }
        )
    }
    
    open func _hideInSuperview(transition: ViewTransition = .default, completion: (() -> Void)? = nil) {
        UIView.transition(
            with: self,
            duration: transition.duration,
            options: transition.options,
            animations: { [weak self] in
                self?.alpha = 0.0
            },
            completion: { [weak self] completed in
                guard completed else { return }
                self?.removeFromSuperview()
                completion?()
            }
        )
    }
    
}
