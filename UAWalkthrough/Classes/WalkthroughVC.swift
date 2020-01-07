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
    func startWalkthrough(withWalkthroughProvider walkthroughProvider: WalkthroughProvider, settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleTextStyle = .default, delegate: WalkthroughDelegate? = nil, completion: (() -> Void)? = nil) -> WalkthroughController? {
        guard !children.contains(where: { $0 is WalkthroughVC }) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.configure(settings: settings, style: style, delegate: delegate, completion: completion)
        walkthroughVC.weaklyRetainedWalkthroughProvider = walkthroughProvider

        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }

    @discardableResult
    func startWalkthrough(withWalkthroughItems walkthroughItems: [WalkthroughItem], settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleTextStyle = .default, delegate: WalkthroughDelegate? = nil, completion: (() -> Void)? = nil) -> WalkthroughController? {
        guard !children.contains(where: { $0 is WalkthroughVC }) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.configure(settings: settings, style: style, delegate: delegate, completion: completion)
        walkthroughVC.stronglyRetainedWalkthroughProvider = DefaultWalkthoughProvider(walkthroughItems: walkthroughItems)

        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }

    func showBubble(withWalkthroughItem walkthroughItem: WalkthroughItem, minBubbleHorizontalMargin: CGFloat, preferredBubbleMaxLayoutWidth: CGFloat, style: BubbleTextStyle = .default) -> Bubble {
        let bubble = Bubble()
        bubble.configure(withContent: walkthroughItem.content)

        return bubble
    }


}

public extension WalkthroughProvider where Self: UIViewController {
    @discardableResult
    func startWalkthrough(withSettings settings: WalkthroughSettings = WalkthroughSettings(), style: BubbleTextStyle = .default, delegate: WalkthroughDelegate? = nil, showEvenIfItHasAlreadyBeenCompleted: Bool = false, completion: (() -> Void)? = nil) -> WalkthroughController? {
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

public struct BubbleTextStyle {
    let textColor: UIColor
    let backgroundColor: UIColor
    let shadowStyle: WalkthroughShadowStyle?
    let cornerRadius: Float
    let textInsets: UIEdgeInsets
    let bubbleYOffsetToHighlightedArea: CGFloat
    let arrowSize: CGSize

    public init(textColor: UIColor = UIColor(red: 190/255, green: 210/255, blue: 229/255, alpha: 1),
                backgroundColor: UIColor = UIColor(red: 46/255, green: 46/255, blue: 45/255, alpha: 1),
                shadowStyle: WalkthroughShadowStyle?,
                cornerRadius: Float = 6,
                textInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16),
                bubbleYOffsetToHighlightedArea: CGFloat = 13,
                arrowSize: CGSize = CGSize(width: 25, height: 16)
                ) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.shadowStyle = shadowStyle
        self.cornerRadius = cornerRadius
        self.textInsets = textInsets
        self.bubbleYOffsetToHighlightedArea = bubbleYOffsetToHighlightedArea
        self.arrowSize = arrowSize
    }

    public static let `default` = BubbleTextStyle(textColor: .tooltipText, backgroundColor: .tooltipBackground, shadowStyle: nil)
    public static let white = BubbleTextStyle(textColor: .tooltipText, backgroundColor: .white, shadowStyle: .light, cornerRadius: 6)
}

public class WalkthroughVC: UIViewController, WalkthroughController {

    func configure(settings: WalkthroughSettings, style: BubbleTextStyle, delegate: WalkthroughDelegate?, completion: (() -> Void)?) {
        view.translatesAutoresizingMaskIntoConstraints = false
        self.settings = settings
        self.style = style
        self.walkthroughDelegate = delegate
        self.completion = completion
    }

    fileprivate var settings = WalkthroughSettings() {
        didSet {
            bubble.textLabel.preferredMaxLayoutWidth = settings.preferredBubbleMaxLayoutWidth
        }
    }

    fileprivate var style = BubbleTextStyle.default {
        didSet {
            if let shadowStyle = style.shadowStyle {
                bubbleTransitionView.layer.shadowOpacity = shadowStyle.shadowOpacity
                bubbleTransitionView.layer.shadowColor = shadowStyle.shadowColor.cgColor
                bubbleTransitionView.layer.shadowOffset = shadowStyle.shadowOffset
            }
            bubble.style = style
            bubbleTransitionView.backgroundColor = style.backgroundColor
            arrow = WalkthroughVC.createArrowView(color: style.backgroundColor)
        }
    }

    fileprivate var highlightingViewCenterXConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewCenterYConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewHeightConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewWidthConstraint: NSLayoutConstraint?
    fileprivate var bubbleConstraints = [NSLayoutConstraint]()
    fileprivate var arrowXConstraint: NSLayoutConstraint?
    fileprivate var arrowYConstraint: NSLayoutConstraint?
    fileprivate var stepWalkthroughTimer: Timer?
    
    weak var weaklyRetainedWalkthroughProvider: WalkthroughProvider?
    var stronglyRetainedWalkthroughProvider: WalkthroughProvider? = nil
    var walkthroughProvider: WalkthroughProvider? {
        return stronglyRetainedWalkthroughProvider ?? weaklyRetainedWalkthroughProvider
    }
    weak var walkthroughDelegate: WalkthroughDelegate?
    var completion: (() -> Void)?
    fileprivate var backgroundDimmingView: UIView!
    
    private var bubble = Bubble()

    // Used to get a smooth animation when the PaddingLabel shrinks as a result of it's text is updated to something shorter, and also for holding the shadow if enabled.
    var bubbleTransitionView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6.0
        return view
    }()

    var currentWalkthroughItemIndex = 0
    
    var arrow = createArrowView(color: BubbleTextStyle.default.backgroundColor)

    let tapGestureRecognizer = UITapGestureRecognizer()

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
            highlightingViewWidthConstraint =  backgroundDimmingView.widthAnchor.constraint(equalTo: parentVC.view.widthAnchor)
            highlightingViewHeightConstraint =  backgroundDimmingView.heightAnchor.constraint(equalTo: parentVC.view.heightAnchor)
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

        bubbleTransitionView.addSubview(arrow)
        backgroundDimmingView.bringSubviewToFront(bubble)

        let dummyWalkthroughItem = HighlightedItem(highlightedArea: parentVC.view, textLocation: .above, text: .plainText(""))
        showWalkthroughItem(dummyWalkthroughItem, onView: parentVC.view)

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

    @objc func stepWalkthrough() {
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
            highlightingViewWidthConstraint =  backgroundDimmingView.widthAnchor.constraint(equalTo: hightlightedItem.highlightedArea.widthAnchor, multiplier: 1, constant: settings.highlightingOffset.x)
            highlightingViewHeightConstraint =  backgroundDimmingView.heightAnchor.constraint(equalTo: hightlightedItem.highlightedArea.heightAnchor, multiplier: 1, constant: settings.highlightingOffset.y)

            highlightingViewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: hightlightedItem.highlightedArea.centerXAnchor)
            highlightingViewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: hightlightedItem.highlightedArea.centerYAnchor)
            activateAllHighlightingConstraints()
        }

        self.updateBubble(withWalkthroughItem: walkthroughItem)

        let animationDuration = currentWalkthroughItemIndex == 0 ? 0 : settings.stepAnimationDuration
        UIView.animate(withDuration: animationDuration, animations: {
            view.layoutIfNeeded()
        })
    }

    private func updateBubble(withWalkthroughItem walkthroughItem: WalkthroughItem) {
        deactivateAllBubbleConstraints()
        deactivateAllArrowConstraints()
        if bubble.superview == nil {
            backgroundDimmingView.addSubview(bubble)
            backgroundDimmingView.insertSubview(bubbleTransitionView, belowSubview: bubble)
            bubbleTransitionView.centerXAnchor.constraint(equalTo: bubble.centerXAnchor).isActive = true
            bubbleTransitionView.centerYAnchor.constraint(equalTo: bubble.centerYAnchor).isActive = true
            bubbleTransitionView.widthAnchor.constraint(equalTo: bubble.widthAnchor).isActive = true
            bubbleTransitionView.heightAnchor.constraint(equalTo: bubble.heightAnchor).isActive = true
        }
        bubble.isHidden = false
        bubble.configure(withContent: walkthroughItem.content)

        if let standaloneItem = walkthroughItem as? StandaloneItem {
            update(standaloneItem: standaloneItem)
        } else if let highlightedItem = walkthroughItem as? HighlightedItem {
            update(highlightedItem: highlightedItem)
        } else {
            fatalError("Non-supported WalkthroughItem")
        }
    }

    private func update(standaloneItem: StandaloneItem) {
        guard let parentVC = parent else { return }
        if let layoutHandler = standaloneItem.layoutHandler {
            if let customConstraints = layoutHandler(self.bubble) {
                bubbleConstraints = customConstraints
            }
        } else if let centerOffset = standaloneItem.centerOffset {
            let horizontalCenterConstraint = bubble.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor, constant: centerOffset.x)
            let verticalCenterConstraint = bubble.centerYAnchor.constraint(equalTo: parentVC.view.centerYAnchor, constant: centerOffset.y)
            bubbleConstraints = [horizontalCenterConstraint, verticalCenterConstraint]
            addHorizontalBubbleConstraints()
        } else {
            assert(false, "A StandAlone item needs to have either a layout handler or a center offset configured.")
            return
        }
        arrow.isHidden = true
        arrowXConstraint = bubble.centerXAnchor.constraint(equalTo: arrow.centerXAnchor)
        arrowYConstraint = bubble.centerYAnchor.constraint(equalTo: arrow.centerYAnchor)
        activateAllArrowConstraints()
        activateAllBubbleConstraints()
    }

    private func update(highlightedItem: HighlightedItem) {
        let centerConstraint = bubble.centerXAnchor.constraint(equalTo: highlightedItem.highlightedArea.centerXAnchor)
        centerConstraint.priority = .defaultLow
        bubbleConstraints = [centerConstraint]
        addHorizontalBubbleConstraints()

        let anchorView = bubbleAnchorView(withHighlightedView: highlightedItem.highlightedArea)
        if highlightedItem.textLocation == .above {
            bubbleConstraints.append(bubble.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -style.bubbleYOffsetToHighlightedArea - style.arrowSize.height))
        } else {
            bubbleConstraints.append(bubble.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: style.bubbleYOffsetToHighlightedArea + style.arrowSize.height))
        }

        activateAllBubbleConstraints()

        deactivateAllArrowConstraints()

        arrow.isHidden = false

        // The rotation of the arrow should happen so that is is not visible. Hence it doesn't even need to be animated, but it is easier to get the timing right that way
        let rotationAnimationDuration = settings.stepAnimationDuration / 3.0
        let rotationAnimationDelay = rotationAnimationDuration
        if highlightedItem.textLocation == .below {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: { 
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }, completion: nil)
            arrowYConstraint = bubbleTransitionView.topAnchor.constraint(equalTo: arrow.bottomAnchor)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
            activateAllArrowConstraints()
        } else {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: {
                self.arrow.transform = .identity
            }, completion: nil)
            arrowYConstraint = bubbleTransitionView.bottomAnchor.constraint(equalTo: arrow.topAnchor)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
            activateAllArrowConstraints()
        }
    }

    private func bubbleAnchorView(withHighlightedView highlightedView: UIView) -> UIView {
        if case .dimAndHighlight = settings.presentationMode {
            return backgroundDimmingView
        } else {
            return highlightedView
        }
    }

    private func addHorizontalBubbleConstraints() {
        guard let parentVC = parent, let superView = parentVC.view else { return }
        let leftMarginConstraint = bubble.leftAnchor.constraint(greaterThanOrEqualTo: superView.leftAnchor, constant: settings.minBubbleHorizontalMargin)
        let rightMarginConstraint = superView.rightAnchor.constraint(greaterThanOrEqualTo: bubble.rightAnchor, constant: settings.minBubbleHorizontalMargin)

        bubbleConstraints.append(contentsOf: [leftMarginConstraint, rightMarginConstraint])
    }
    
    class func createArrowView(size: CGSize = CGSize(width: 25, height: 12), color: UIColor) -> UIView {
        let arrowShapeLayer = CAShapeLayer()
        let origin = CGPoint(x: 0, y: 0)
        arrowShapeLayer.frame = CGRect(origin: origin, size: size)
        let arrowPath = UIBezierPath()
        arrowPath.move(to: origin)
        arrowPath.addLine(to: CGPoint(x: size.width/2, y: size.height))
        arrowPath.addLine(to: CGPoint(x: size.width, y: 0))
        arrowPath.close()
        arrowShapeLayer.path = arrowPath.cgPath
        arrowShapeLayer.fillColor = color.cgColor
        let view = UIView(frame: arrowShapeLayer.frame)
        view.backgroundColor = .clear
        view.layer.addSublayer(arrowShapeLayer)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        return view
    }
    
    private func activateAllBubbleConstraints() {
        NSLayoutConstraint.activate(bubbleConstraints)
    }
    
    private func deactivateAllBubbleConstraints() {
        NSLayoutConstraint.deactivate(bubbleConstraints)
    }

    private func activateAllArrowConstraints() {
        arrowXConstraint?.isActive = true
        arrowYConstraint?.isActive = true
    }

    private func deactivateAllArrowConstraints() {
        arrowXConstraint?.isActive = false
        arrowYConstraint?.isActive = false
    }

    private func activateAllHighlightingConstraints() {
        guard case .dimAndHighlight = settings.presentationMode else { return }
        NSLayoutConstraint.activate([highlightingViewWidthConstraint, highlightingViewHeightConstraint, highlightingViewCenterXConstraint, highlightingViewCenterYConstraint].compactMap { $0 })
    }
    
    private func deactivateAllHighlightingConstraints() {
        guard case .dimAndHighlight = settings.presentationMode else { return }
        NSLayoutConstraint.deactivate([highlightingViewWidthConstraint, highlightingViewHeightConstraint, highlightingViewCenterXConstraint, highlightingViewCenterYConstraint].compactMap { $0 })
    }
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

public class Bubble: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        translatesAutoresizingMaskIntoConstraints = false
    }

    init() {
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(withContent content: Content) {
        switch content {
            case .customView(let view):
            configure(withCustomView: view)
            default:
            configure(withTextContent: content)
        }
    }

    var style: BubbleTextStyle = BubbleTextStyle.default {
        didSet {
            textLabel.textColor = style.textColor
            textLabel.backgroundColor = style.backgroundColor
            textLabel.insets = style.textInsets
        }
    }

    private func configure(withCustomView customView: UIView) {
        self.customView?.removeFromSuperview()
        self.customView = nil
        addSubview(customView)
        self.customView = customView
        customView.layer.cornerRadius = defaultCornerRadius
        customView.clipsToBounds = true
        customView.bound(inside: self)
        textLabel.isHidden = true
    }

    private func configure(withTextContent textContent: Content) {
        customView?.removeFromSuperview()
        customView = nil
        if textLabel.superview == nil {
            addSubview(textLabel)
            textLabel.bound(inside: self)
        }
        if case .plainText(let plainText) = textContent {
            textLabel.text = plainText
        } else if case .attributedText(let attributedText) = textContent {
            textLabel.attributedText = attributedText
        }
        textLabel.isHidden = false
    }

    private var customView: UIView?

    lazy var textLabel: PaddingLabel = {
        let bubblePaddingLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0), insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        bubblePaddingLabel.backgroundColor = style.backgroundColor
        bubblePaddingLabel.textColor = .tooltipText
        bubblePaddingLabel.translatesAutoresizingMaskIntoConstraints = false
        bubblePaddingLabel.lineBreakMode = .byWordWrapping
        bubblePaddingLabel.isHidden = true
        bubblePaddingLabel.numberOfLines = 0
        bubblePaddingLabel.layer.cornerRadius = defaultCornerRadius
        bubblePaddingLabel.clipsToBounds = true
        return bubblePaddingLabel
    }()

    private let defaultCornerRadius: CGFloat = 6.0
}
