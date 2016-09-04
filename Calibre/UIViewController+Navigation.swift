//
//  UIViewController+Navigation.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/4/16.
//  Copyright © 2016 Jesse Squires. All rights reserved.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    public func withNavigation() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }

    public func withPresentation(presentation: UIModalPresentationStyle) -> Self {
        modalPresentationStyle = presentation
        return self
    }

    public func withTransition(transition: UIModalTransitionStyle) -> Self {
        modalTransitionStyle = transition
        return self
    }

    public func withNavigationStyle(navigationStyle: NavigationStyle) -> UIViewController {
        switch navigationStyle {
        case .None:
            return self
        case .WithNavigation:
            return withNavigation()
        }
    }

    public func withStyles(navigation navigation: NavigationStyle, presentation: UIModalPresentationStyle, transition: UIModalTransitionStyle) -> UIViewController {
        return withPresentation(presentation).withTransition(transition).withNavigationStyle(navigation)
    }
}

extension UIViewController {
    public func navigate(to viewController: UIViewController, type: PresentationType, animated: Bool = true) {
        switch type {
        case let .Modal(navigationStyle, modalPresentationStyle, modalTransitionStyle):
            let vc = viewController.withStyles(navigation: navigationStyle, presentation: modalPresentationStyle, transition: modalTransitionStyle)
            presentViewController(vc, animated: animated, completion: nil)
        case let .Popover(popoverConfig):
            viewController.withStyles(navigation: .None, presentation: .Popover, transition: UIModalTransitionStyle.CrossDissolve)
            let popoverController = viewController.popoverPresentationController
            popoverController?.delegate = popoverConfig.delegate
            popoverController?.permittedArrowDirections = popoverConfig.arrowDirection

            switch popoverConfig.source {
            case .BarButtonItem(let item):
                popoverController?.barButtonItem = item
            case .View(let v):
                popoverController?.sourceView = v
                popoverController?.sourceRect = v.frame
            }
            presentViewController(viewController, animated: animated, completion: nil)
        case .Push:
            if let nav = self as? UINavigationController {
                nav.pushViewController(viewController, animated: animated)
            } else {
                navigationController!.pushViewController(viewController, animated: animated)
            }
        case .Show:
            showViewController(viewController, sender: self)
        case let .ShowDetail(navigationStyle):
            showViewController(viewController.withNavigationStyle(navigationStyle), sender: self)
        case let .Custom(transitioningDelegate):
            viewController.modalPresentationStyle = .Custom
            viewController.transitioningDelegate = transitioningDelegate
            presentViewController(viewController, animated: animated, completion: nil)
        }
    }
}

extension UIViewController {
    public func dismiss(animated animated: Bool = true) {
        if isModallyPresented {
            dismissViewControllerAnimated(animated, completion: nil)
        } else {
            assert(navigationController != nil)
            navigationController?.popViewControllerAnimated(animated)
        }
    }

    public func addDismissButtonIfNeeded(config config: DismissButtonConfig = DismissButtonConfig()) {
        guard needsDismissButton else { return }
        addDismissButton(config: config)
    }

    public func addDismissButton(config config: DismissButtonConfig = DismissButtonConfig()) {
        let button = UIBarButtonItem(config: config, target: self, action: #selector(UIViewController._didTapDismissButton(_:)))
        
        switch config.location {
        case .Left:
            navigationItem.leftBarButtonItem = button
        case .Right:
            navigationItem.rightBarButtonItem = button
        }
    }

    @objc private func _didTapDismissButton(sender: UIBarButtonItem) {
        dismiss()
    }

    private var needsDismissButton: Bool {
        return isModallyPresented
    }

    private var isModallyPresented: Bool {
        return (hasPresentingController && !hasNavigationController) || (hasPresentingController && hasNavigationController && isNavigationRootViewController)
    }

    private var hasPresentingController: Bool {
        return self.presentingViewController != nil
    }

    private var hasNavigationController: Bool {
        return self.navigationController != nil
    }

    private var isNavigationRootViewController: Bool {
        return navigationController?.viewControllers.first == self
    }
}
