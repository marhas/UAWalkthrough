//
//  WalkthroughVC.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2017-02-02.
//  Copyright © 2017 Marcel Hasselaar. All rights reserved.

import UIKit

public protocol WalkthroughController {
    func dismissWalkthrough()
}

public protocol WalkthroughProvider: class {
    var walkthroughItems: [WalkthroughItem] { get }
}

private class DefaultWalkthoughProvider: WalkthroughProvider {
    let walkthroughItems: [WalkthroughItem]

    init(walkthroughItems: [WalkthroughItem]) {
        self.walkthroughItems = walkthroughItems
    }
}

public extension WalkthroughProvider {
    private var userDefaultsKey: String {
        return String(describing: type(of:self)) + "-WalkthroughCompleted"
    }

    var hasCompletedWalkthrough: Bool {
        get {
            return UserDefaults.standard.bool(forKey: userDefaultsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
        }
    }
}

public extension UIViewController {
    /// Note that you need to keep a reference to the passed in WalkthroughProvider since it will not be retained by this method.
    @discardableResult
    func startWalkthrough(withWalkthroughProvider walkthroughProvider: WalkthroughProvider, settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleStyle = .default, delegate: WalkthroughDelegate? = nil, completion: (() -> Void)? = nil) -> WalkthroughController? {
        guard !children.contains(where: { $0 is WalkthroughVC }) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.configure(settings: settings, style: style, delegate: delegate, completion: completion)
        walkthroughVC.weaklyRetainedWalkthroughProvider = walkthroughProvider

        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }

    @discardableResult
    func startWalkthrough(withWalkthroughItems walkthroughItems: [WalkthroughItem], settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleStyle = .default, delegate: WalkthroughDelegate? = nil, completion: (() -> Void)? = nil) -> WalkthroughController? {
        guard !children.contains(where: { $0 is WalkthroughVC }) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.configure(settings: settings, style: style, delegate: delegate, completion: completion)
        walkthroughVC.stronglyRetainedWalkthroughProvider = DefaultWalkthoughProvider(walkthroughItems: walkthroughItems)

        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }

    @discardableResult
    func showBubble(withWalkthroughItem walkthroughItem: WalkthroughItem, minBubbleHorizontalMargin: CGFloat, preferredBubbleMaxLayoutWidth: CGFloat, style: BubbleStyle = .default) -> Bubble {
        let bubble = Bubble(preferredMaxLayoutWidth: preferredBubbleMaxLayoutWidth, minBubbleHorizontalMargin: minBubbleHorizontalMargin, style: style)
        view.addSubview(bubble)
        bubble.configure(withWalkthroughItem: walkthroughItem)
        return bubble
    }
}

public extension WalkthroughProvider where Self: UIViewController {
    @discardableResult
    func startWalkthrough(withSettings settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleStyle = .default, delegate: WalkthroughDelegate? = nil, showEvenIfItHasAlreadyBeenCompleted: Bool = false, completion: (() -> Void)? = nil) -> WalkthroughController? {
        guard !(hasCompletedWalkthrough && !showEvenIfItHasAlreadyBeenCompleted) else { return nil }
        guard !children.contains(where: { $0 is WalkthroughVC }) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.configure(settings: settings, style: style, delegate: delegate, completion: completion)
        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }
}

public struct WalkthroughSettings {
    var stepAnimationDuration: Double
    var highlightingOffset: CGPoint
    var automaticWalkthroughDelaySeconds: Int?
    var minBubbleHorizontalMargin: CGFloat
    var preferredBubbleMaxLayoutWidth: CGFloat
    var presentationMode: PresentationMode

    public enum PresentationMode {
        case dimAndHighlight(dimmingColor: UIColor = .black, dimmingLevel: CGFloat = 0.7)
        case dim(dimmingColor: UIColor = .black, dimmingLevel: CGFloat = 0.7)
        case none
    }

    public init(stepAnimationDuration: Double = 0.3,
         highlightingOffset: CGPoint = CGPoint(x: 25, y: 25),
         automaticWalkthroughDelaySeconds: Int? = nil,
         minLabelHorizontalMargin: CGFloat = 10,
         preferredBubbleMaxLayoutWidth: CGFloat? = nil,
         presentationMode: PresentationMode = .dimAndHighlight()
         ) {
        self.stepAnimationDuration = stepAnimationDuration
        self.highlightingOffset = highlightingOffset
        self.automaticWalkthroughDelaySeconds = automaticWalkthroughDelaySeconds
        self.minBubbleHorizontalMargin = minLabelHorizontalMargin
        self.preferredBubbleMaxLayoutWidth = preferredBubbleMaxLayoutWidth ?? UIScreen.main.bounds.width - 2 * minLabelHorizontalMargin
        self.presentationMode = presentationMode
    }
}

public struct WalkthroughShadowStyle {
    public let shadowOffset: CGSize
    public let shadowColor: UIColor
    public let shadowOpacity: Float

    public init(offset: CGSize = CGSize(width: 3, height: 4), color: UIColor = .black, opacity: Float = 0.7) {
        self.shadowOffset = offset
        self.shadowColor = color
        self.shadowOpacity = opacity
    }

    public static let dark = WalkthroughShadowStyle(offset: CGSize(width: 3, height: 4), color: .black, opacity: 0.7)
    public static let light = WalkthroughShadowStyle(offset: CGSize(width: 3, height: 4), color: .black, opacity: 0.2)
}

public struct BubbleStyle {
    let textColor: UIColor
    let backgroundColor: UIColor
    let shadowStyle: WalkthroughShadowStyle?
    let cornerRadius: Float
    let textInsets: UIEdgeInsets
    let yOffsetToHighlightedArea: CGFloat
    let arrowSize: CGSize

    public init(textColor: UIColor = UIColor(red: 190/255, green: 210/255, blue: 229/255, alpha: 1),
                backgroundColor: UIColor = UIColor(red: 46/255, green: 46/255, blue: 45/255, alpha: 1),
                shadowStyle: WalkthroughShadowStyle?,
                cornerRadius: Float = 6,
                textInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                yOffsetToHighlightedArea: CGFloat = 8,
                arrowSize: CGSize = CGSize(width: 25, height: 16)
                ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.shadowStyle = shadowStyle
        self.cornerRadius = cornerRadius
        self.textInsets = textInsets
        self.yOffsetToHighlightedArea = yOffsetToHighlightedArea
        self.arrowSize = arrowSize
    }

    public static let `default` = BubbleStyle(textColor: .tooltipText, backgroundColor: .tooltipBackground, shadowStyle: nil)
    public static let white = BubbleStyle(textColor: .tooltipText, backgroundColor: .white, shadowStyle: .light, cornerRadius: 6)
}

public class WalkthroughVC: UIViewController, WalkthroughController {
    var walkthroughProvider: WalkthroughProvider? {
        return stronglyRetainedWalkthroughProvider ?? weaklyRetainedWalkthroughProvider
    }
    weak var walkthroughDelegate: WalkthroughDelegate?
    var completion: (() -> Void)?

    static public func forgetCompletedWalkthrougs() {
        let defaults = UserDefaults.standard.dictionaryRepresentation()
        defaults.map { $0.key }.filter { $0.hasSuffix("-WalkthroughCompleted") }.forEach { userDefaultsKey in
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        }
    }

    override public func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)

        guard let parentVC = parent else { return }

        if let walkthroughProvider = parent as? WalkthroughProvider {
            self.weaklyRetainedWalkthroughProvider = walkthroughProvider
        }
        guard let walkthroughProvider = walkthroughProvider else {
            assert(false, "You must add WalkthroughVC to a view controller that implements the WalkthroughProvider protocol or pass a WalkthoughProvider to the startWalkthrough() function.")
            return
        }

        guard !walkthroughProvider.walkthroughItems.isEmpty else {
            assert(false, "The WalkthroughProvider doesn't have any walkthrough items so there's nothing for me to do.")
            return
        }
        
        tapGestureRecognizer.addTarget(self, action: #selector(stepWalkthrough))

        deactivateAllHighlightingConstraints()

        switch settings.presentationMode {
        case .dimAndHighlight(let dimmingColor, let dimmingLevel):
            backgroundDimmingView = DimmingViewWithHole(frame: .zero, dimmingColor: dimmingColor, dimmingAlpha: dimmingLevel)
            parentVC.view.addSubview(backgroundDimmingView)
            backgroundDimmingView.translatesAutoresizingMaskIntoConstraints = false
            highlightingViewWidthConstraint = backgroundDimmingView.widthAnchor.constraint(equalTo: parentVC.view.widthAnchor)
            highlightingViewHeightConstraint = backgroundDimmingView.heightAnchor.constraint(equalTo: parentVC.view.heightAnchor)
            highlightingViewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)
            highlightingViewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: parentVC.view.centerYAnchor)
        case .dim(let dimmingColor, let dimmingLevel):
            backgroundDimmingView = UIView()
            backgroundDimmingView.backgroundColor = dimmingColor.withAlphaComponent(dimmingLevel)
            parentVC.view.addSubview(backgroundDimmingView)
            backgroundDimmingView.bound(inside: parentVC.view, considerSafeArea: false)
        case .none:
            backgroundDimmingView = UIView()
            backgroundDimmingView.backgroundColor = .clear
            parentVC.view.addSubview(backgroundDimmingView)
            backgroundDimmingView.bound(inside: parentVC.view, considerSafeArea: false)
        }
        backgroundDimmingView.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.backgroundDimmingView.alpha = 1
        }

        backgroundDimmingView.addGestureRecognizer(tapGestureRecognizer)
        backgroundDimmingView.bringSubviewToFront(bubble)

        // Workaround for bug with autosizing UILabel
        showWalkthroughItem(HighlightedItem(highlightedArea: parentVC.view, textLocation: .above, text: .plainText("")), onView: parentVC.view)

        DispatchQueue.main.async {
            self.stepWalkthrough()
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        dismissWalkthrough()
    }

    public func dismissWalkthrough() {
        backgroundDimmingView.removeGestureRecognizer(tapGestureRecognizer)
        backgroundDimmingView.removeFromSuperview()
        removeFromParent()
        walkthroughDelegate?.walkthroughCompleted()
        completion?()
    }

    fileprivate func configure(settings: WalkthroughSettings, style: BubbleStyle, delegate: WalkthroughDelegate?, completion: (() -> Void)?) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.settings = settings
        self.walkthroughDelegate = delegate
        self.completion = completion
        bubble = Bubble(preferredMaxLayoutWidth: settings.preferredBubbleMaxLayoutWidth, minBubbleHorizontalMargin: settings.minBubbleHorizontalMargin, animationDuration: settings.stepAnimationDuration, style: style)
    }

    @objc private func stepWalkthrough() {
        stepWalkthroughTimer?.invalidate()
        guard let walkthroughProvider = walkthroughProvider, let parentVC = parent, currentWalkthroughItemIndex < walkthroughProvider.walkthroughItems.count else {
            self.walkthroughProvider?.hasCompletedWalkthrough = true
            dismissWalkthrough()
            return
        }
        if let delay = settings.automaticWalkthroughDelaySeconds {
            stepWalkthroughTimer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(stepWalkthrough), userInfo: nil, repeats: false)
        }
        showWalkthroughItem(walkthroughProvider.walkthroughItems[currentWalkthroughItemIndex], onView: parentVC.view)
        currentWalkthroughItemIndex += 1
    }
    
    private func showWalkthroughItem(_ walkthroughItem: WalkthroughItem, onView view: UIView) {
        deactivateAllHighlightingConstraints()

        if let hightlightedItem = walkthroughItem as? HighlightedItem {
            highlightingViewWidthConstraint = backgroundDimmingView.widthAnchor.constraint(equalTo: hightlightedItem.highlightedArea.widthAnchor, multiplier: 1, constant: settings.highlightingOffset.x)
            highlightingViewHeightConstraint = backgroundDimmingView.heightAnchor.constraint(equalTo: hightlightedItem.highlightedArea.heightAnchor, multiplier: 1, constant: settings.highlightingOffset.y)

            highlightingViewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: hightlightedItem.highlightedArea.centerXAnchor)
            highlightingViewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: hightlightedItem.highlightedArea.centerYAnchor)
        } else {
            // This is to make the hole in the dimming view disappear in a controlled fashion
            highlightingViewHeightConstraint = backgroundDimmingView.heightAnchor.constraint(equalToConstant: 0)
        }
        activateAllHighlightingConstraints()

        self.updateBubble(withWalkthroughItem: walkthroughItem)

        let animationDuration = currentWalkthroughItemIndex == 0 ? 0 : settings.stepAnimationDuration
        UIView.animate(withDuration: animationDuration, animations: {
            view.layoutIfNeeded()
        })
    }

    private func updateBubble(withWalkthroughItem walkthroughItem: WalkthroughItem) {
        if bubble.superview == nil {
            backgroundDimmingView.addSubview(bubble)
        }
        bubble.isHidden = false
//        let anchorView = bubbleAnchorView(withWalkthroughItem: walkthroughItem)
        bubble.configure(withWalkthroughItem: walkthroughItem, anchorView: nil)
    }

//    private func bubbleAnchorView(withWalkthroughItem walkthroughItem: WalkthroughItem) -> UIView? {
//        guard let highlightedItem = walkthroughItem as? HighlightedItem else { return parent?.view }
//        if case .dimAndHighlight = settings.presentationMode {
//            return backgroundDimmingView
//        } else {
//            return highlightedItem.highlightedArea
//        }
//    }

    private func activateAllHighlightingConstraints() {
        guard case .dimAndHighlight = settings.presentationMode else { return }
        NSLayoutConstraint.activate([highlightingViewWidthConstraint, highlightingViewHeightConstraint, highlightingViewCenterXConstraint, highlightingViewCenterYConstraint].compactMap { $0 })
    }
    
    private func deactivateAllHighlightingConstraints() {
        guard case .dimAndHighlight = settings.presentationMode else { return }
        NSLayoutConstraint.deactivate([highlightingViewWidthConstraint, highlightingViewHeightConstraint, highlightingViewCenterXConstraint, highlightingViewCenterYConstraint].compactMap { $0 })
    }

    fileprivate var settings = WalkthroughSettings()
    fileprivate var highlightingViewCenterXConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewCenterYConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewHeightConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewWidthConstraint: NSLayoutConstraint?
    fileprivate var stepWalkthroughTimer: Timer?
    fileprivate weak var weaklyRetainedWalkthroughProvider: WalkthroughProvider?
    fileprivate var stronglyRetainedWalkthroughProvider: WalkthroughProvider? = nil
    fileprivate var backgroundDimmingView: UIView!

    private var bubble: Bubble!
    private var currentWalkthroughItemIndex = 0
    private let tapGestureRecognizer = UITapGestureRecognizer()
}

public protocol WalkthroughItem {
    var content: Content { get set }
}

public struct StandaloneItem: WalkthroughItem {
    public typealias LayoutHandler = (UIView) -> [NSLayoutConstraint]?

    public init(text: Content, centerOffset: CGPoint = CGPoint.zero) {
        self.content = text
        self.centerOffset = centerOffset
        layoutHandler = nil
    }

    public init(text: Content, layoutHandler: LayoutHandler? = nil) {
        self.content = text
        self.layoutHandler = layoutHandler
        centerOffset = nil
    }

    public init(text: Content) {
        self.content = text
        self.layoutHandler = nil
        centerOffset = CGPoint.zero
    }

    public var centerOffset: CGPoint?
    public var content: Content
    let layoutHandler: LayoutHandler?
}

public struct HighlightedItem: WalkthroughItem {
    public init(highlightedArea: UIView, textLocation: TextLocation, text: Content) {
        self.highlightedArea = highlightedArea
        self.textLocation = textLocation
        self.content = text
    }

    public var highlightedArea: UIView
    public var textLocation: TextLocation
    public var content: Content

    public enum TextLocation {
        case above, below
    }
}

public enum Content {
    case attributedText(NSAttributedString)
    case plainText(String)
    case customView(UIView)
}

public protocol WalkthroughDelegate: class {
    func walkthroughCompleted()
}
