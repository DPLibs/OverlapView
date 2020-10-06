//
//  ViewController.swift
//  OverlapView
//
//  Created by Dmitriy Polyakov on 10/06/2020.
//  Copyright (c) 2020 Dmitriy Polyakov. All rights reserved.
//

import Foundation
import UIKit
import OverlapView

extension ActivityOverlapViewMode {
    static let test = ActivityOverlapViewMode(backgroundColor: .white, activityColor: .white, coverColor: .blue)
}

class TestView: OverlapView {
    
    let container = UIView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.prepareViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.prepareViews()
    }
    
    override var config: OverlapViewConfig {
        .init(viewsNonTouchSensitive: [self.container], hideOnTouch: true, hideOnTouchTransition: .init(duration: 0.25, options: .curveEaseOut))
    }
    
    func prepareViews() {
        self.container.removeFromSuperview()
        self.addSubview(self.container)
        self.container.backgroundColor = .gray
        self.container.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.container.widthAnchor.constraint(equalToConstant: 200),
            self.container.heightAnchor.constraint(equalToConstant: 200),
            self.container.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            self.container.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])
        
        self.label.removeFromSuperview()
        self.container.addSubview(self.label)
        self.label.text = "Test"
        self.label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.label.centerYAnchor.constraint(equalTo: self.container.centerYAnchor),
            self.label.centerXAnchor.constraint(equalTo: self.container.centerXAnchor)
        ])
    }
    
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        ActivityOverlapView(mode: .test).show(in: .superview(self.view))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) { [weak self] in
            ActivityOverlapView.hide(in: .superview(self?.view))
            
            let testView = TestView()
            testView.show(in: .window, transition: .default, completion: nil)
        }
    }

}

