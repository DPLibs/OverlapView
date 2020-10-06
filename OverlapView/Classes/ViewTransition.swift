import Foundation
import UIKit

public struct ViewTransition: Equatable {
    public let duration: TimeInterval
    public let options: UIView.AnimationOptions
    
    public init(duration: TimeInterval, options: UIView.AnimationOptions) {
        self.duration = duration
        self.options = options
    }
    
    public static let `default` = ViewTransition(duration: 0.25, options: .transitionCrossDissolve)
    public static let withoutAnimate = ViewTransition(duration: .zero, options: [])
}
