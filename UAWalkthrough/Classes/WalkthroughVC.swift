//
//  WalkthroughVC.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2017-02-02.

import UIKit

public protocol WalkthroughController {
    func dismissWalkthrough()
}

public protocol WalkthroughProvider: class {
    var walkthroughItems: [WalkthroughItem] { get }
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

public extension WalkthroughProvider where Self: UIViewController {
    @discardableResult
    func startWalkthrough(withSettings settings: WalkthroughSettings = WalkthroughSettings(), style: TextBubbleStyle = .default, delegate: WalkthroughDelegate? = nil, showEvenIfItHasAlreadyBeenCompleted: Bool = false) -> WalkthroughController? {
        guard !(hasCompletedWalkthrough && !showEvenIfItHasAlreadyBeenCompleted) else { return nil }

        let walkthroughVC = WalkthroughVC()
        walkthroughVC.settings = settings
        walkthroughVC.style = style
        walkthroughVC.walkthroughDelegate = delegate
        addChild(walkthroughVC)
        walkthroughVC.didMove(toParent: self)
        return walkthroughVC
    }
}

public struct WalkthroughSettings {
    var stepAnimationDuration: Double
    var highlightingOffset: CGPoint
    var automaticWalkthroughDelaySeconds: Int?
    var minTextBubbleHorizontalMargin: CGFloat
    var preferredTextBubbleMaxLayoutWidth: CGFloat
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
         preferredTextBubbleMaxLayoutWidth: CGFloat? = nil,
         presentationMode: PresentationMode = .dimAndHighlight()
         ) {
        self.stepAnimationDuration = stepAnimationDuration
        self.highlightingOffset = highlightingOffset
        self.automaticWalkthroughDelaySeconds = automaticWalkthroughDelaySeconds
        self.minTextBubbleHorizontalMargin = minLabelHorizontalMargin
        self.preferredTextBubbleMaxLayoutWidth = preferredTextBubbleMaxLayoutWidth ?? UIScreen.main.bounds.width - 2 * minLabelHorizontalMargin
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

public struct TextBubbleStyle {
    let textColor: UIColor
    let backgroundColor: UIColor
    let shadowStyle: WalkthroughShadowStyle?
    let cornerRadius: Float
    let textInsets: UIEdgeInsets

    public init(textColor: UIColor = UIColor(red: 190/255, green: 210/255, blue: 229/255, alpha: 1), backgroundColor: UIColor = UIColor(red: 46/255, green: 46/255, blue: 45/255, alpha: 1), shadowStyle: WalkthroughShadowStyle?, cornerRadius: Float = 6, textBubbleInsets: UIEdgeInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)) {
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.shadowStyle = shadowStyle
        self.cornerRadius = cornerRadius
        self.textInsets = textBubbleInsets
    }

    public static let defaultCornerRadius = Float(6)
    public static let `default` = TextBubbleStyle(textColor: .tooltipText, backgroundColor: .tooltipBackground, shadowStyle: nil)
    public static let white = TextBubbleStyle(textColor: .tooltipText, backgroundColor: .white, shadowStyle: .light, cornerRadius: defaultCornerRadius)
}

public class WalkthroughVC: UIViewController, WalkthroughController {
    fileprivate var settings = WalkthroughSettings() {
        didSet {
            textBubble.preferredMaxLayoutWidth = settings.preferredTextBubbleMaxLayoutWidth
        }
    }
    fileprivate var style = TextBubbleStyle.default {
        didSet {
            if let shadowStyle = style.shadowStyle {
                textBubbleTransitionView.layer.shadowOpacity = shadowStyle.shadowOpacity
                textBubbleTransitionView.layer.shadowColor = shadowStyle.shadowColor.cgColor
                textBubbleTransitionView.layer.shadowOffset = shadowStyle.shadowOffset
            }
            textBubble.textColor = style.textColor
            textBubble.backgroundColor = style.backgroundColor
            textBubble.insets = style.textInsets
            textBubbleTransitionView.backgroundColor = style.backgroundColor
            arrow = WalkthroughVC.createArrowView(color: style.backgroundColor)
        }
    }

    fileprivate var highlightingViewCenterXConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewCenterYConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewHeightConstraint: NSLayoutConstraint?
    fileprivate var highlightingViewWidthConstraint: NSLayoutConstraint?
    fileprivate var textBubbleConstraints = [NSLayoutConstraint]()
    fileprivate var arrowXConstraint: NSLayoutConstraint?
    fileprivate var arrowYConstraint: NSLayoutConstraint?
    fileprivate var stepWalkthroughTimer: Timer?
    
    weak var walkthroughProvider: WalkthroughProvider?
    weak var walkthroughDelegate: WalkthroughDelegate?
    fileprivate var backgroundDimmingView: UIView! // DimmingViewWithHole!
    
    static let textBubbleBackgroundColor = UIColor.tooltipBackground
    static let distanceBetweenTextBubbleAndHightlightedArea: CGFloat = 17
    static let textBubbleArrowOverlap = CGFloat(8)

    var textBubble: PaddingLabel = {
        let bubblePaddingLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0), insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        bubblePaddingLabel.backgroundColor = textBubbleBackgroundColor
        bubblePaddingLabel.textColor = .tooltipText
        bubblePaddingLabel.translatesAutoresizingMaskIntoConstraints = false
        bubblePaddingLabel.lineBreakMode = .byWordWrapping
        bubblePaddingLabel.isHidden = true
        bubblePaddingLabel.numberOfLines = 0
        bubblePaddingLabel.layer.cornerRadius = 6.0
        bubblePaddingLabel.layer.masksToBounds = true
        bubblePaddingLabel.clipsToBounds = true
        return bubblePaddingLabel
    }()

    // Used to get a smooth animation when the PaddingLabel shrinks as a result of it's text is updated to something shorter, and also for holding the shadow if enabled.
    var textBubbleTransitionView: UIView = {
        let view = UIView()
        view.backgroundColor = textBubbleBackgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 6.0
        return view
    }()

    var currentWalkthroughItemIndex = 0
    
    var arrow = createArrowView(color: TextBubbleStyle.default.backgroundColor)

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

        guard let walkthroughProvider = parent as? WalkthroughProvider else {
            assert(false, "You must add WalkthroughVC to a view controller that implements the WalkthroughProvider protocol.")
            return
        }
        self.walkthroughProvider = walkthroughProvider
        
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
        backgroundDimmingView.addGestureRecognizer(tapGestureRecognizer)

//        highlightingViewWidthConstraint = backgroundDimmingView.widthAnchor.constraint(equalToConstant: 0)
//        highlightingViewHeightConstraint = backgroundDimmingView.heightAnchor.constraint(equalToConstant: 0)
//        highlightingViewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)
//        highlightingViewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: parentVC.view.centerYAnchor)
//
//        activateAllHighlightingConstraints()

        textBubbleTransitionView.addSubview(arrow)
        backgroundDimmingView.bringSubviewToFront(textBubble)

        let dummyWalkthroughItem = HighlightedItem(highlightedArea: parentVC.view, textLocation: .above, text: "")
        showWalkthroughItem(dummyWalkthroughItem, onView: parentVC.view)
        
        stepWalkthrough()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        dismissWalkthrough()
    }

    public func dismissWalkthrough() {
        backgroundDimmingView.removeGestureRecognizer(tapGestureRecognizer)
        backgroundDimmingView.removeFromSuperview()
        removeFromParent()
        walkthroughDelegate?.walkthroughCompleted()
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

        self.updateTextBubble(walkthroughItem: walkthroughItem)

        UIView.animate(withDuration: settings.stepAnimationDuration, animations: {
            view.layoutIfNeeded()
        })
    }

    private func updateTextBubble(walkthroughItem: WalkthroughItem) {
        deactivateAllTextBubbleConstraints()
        deactivateAllArrowConstraints()
        if textBubble.superview == nil {
            backgroundDimmingView.addSubview(textBubble)
            backgroundDimmingView.insertSubview(textBubbleTransitionView, belowSubview: textBubble)
            textBubbleTransitionView.centerXAnchor.constraint(equalTo: textBubble.centerXAnchor).isActive = true
            textBubbleTransitionView.centerYAnchor.constraint(equalTo: textBubble.centerYAnchor).isActive = true
            textBubbleTransitionView.widthAnchor.constraint(equalTo: textBubble.widthAnchor).isActive = true
            textBubbleTransitionView.heightAnchor.constraint(equalTo: textBubble.heightAnchor).isActive = true
        }
        textBubble.isHidden = false
        textBubble.text = walkthroughItem.text

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
            if let customConstraints = layoutHandler(self.textBubble) {
                textBubbleConstraints = customConstraints
            }
        } else {
            let horizontalCenterConstraint = textBubble.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor, constant: standaloneItem.centerOffset.x)
            let verticalCenterConstraint = textBubble.centerYAnchor.constraint(equalTo: parentVC.view.centerYAnchor, constant: standaloneItem.centerOffset.y)
            textBubbleConstraints = [horizontalCenterConstraint, verticalCenterConstraint]
            addHorizontalTextBubbleConstraints()
        }
        arrow.isHidden = true
        arrowXConstraint = textBubble.centerXAnchor.constraint(equalTo: arrow.centerXAnchor)
        arrowYConstraint = textBubble.centerYAnchor.constraint(equalTo: arrow.centerYAnchor)
        activateAllArrowConstraints()
        activateAllTextBubbleConstraints()
    }

    private func update(highlightedItem: HighlightedItem) {
        let centerConstraint = textBubble.centerXAnchor.constraint(equalTo: highlightedItem.highlightedArea.centerXAnchor)
        centerConstraint.priority = .defaultLow
        textBubbleConstraints = [centerConstraint]
        addHorizontalTextBubbleConstraints()

        let anchorView = textBubbleAnchorView(withHighlightedView: highlightedItem.highlightedArea)
        if highlightedItem.textLocation == .above {
            textBubbleConstraints.append(textBubble.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -WalkthroughVC.distanceBetweenTextBubbleAndHightlightedArea))
        } else {
            textBubbleConstraints.append(textBubble.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: WalkthroughVC.distanceBetweenTextBubbleAndHightlightedArea))
        }

        activateAllTextBubbleConstraints()

        deactivateAllArrowConstraints()

        arrow.isHidden = false

        // The rotation of the arrow should happen so that is is not visible. Hence it doesn't even need to be animated, but it is easier to get the timing right that way
        let rotationAnimationDuration = settings.stepAnimationDuration / 3.0
        let rotationAnimationDelay = rotationAnimationDuration
        if highlightedItem.textLocation == .below {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: { 
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }, completion: nil)
            arrowYConstraint = anchorView.bottomAnchor.constraint(equalTo: arrow.topAnchor, constant: WalkthroughVC.textBubbleArrowOverlap - 1)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
            activateAllArrowConstraints()
        } else {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: {
                self.arrow.transform = .identity
            }, completion: nil)
            arrowYConstraint = arrow.bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: WalkthroughVC.textBubbleArrowOverlap - 1)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
            activateAllArrowConstraints()
        }
    }

    private func textBubbleAnchorView(withHighlightedView highlightedView: UIView) -> UIView {
        if case .dimAndHighlight = settings.presentationMode {
            return backgroundDimmingView
        } else {
            return highlightedView
        }
    }
    private func addHorizontalTextBubbleConstraints() {
        guard let parentVC = parent, let superView = parentVC.view else { return }
        let leftMarginConstraint = textBubble.leftAnchor.constraint(greaterThanOrEqualTo: superView.leftAnchor, constant: settings.minTextBubbleHorizontalMargin)
        let rightMarginConstraint = superView.rightAnchor.constraint(greaterThanOrEqualTo: textBubble.rightAnchor, constant: settings.minTextBubbleHorizontalMargin)

        textBubbleConstraints.append(contentsOf: [leftMarginConstraint, rightMarginConstraint])
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
    
    private func activateAllTextBubbleConstraints() {
        NSLayoutConstraint.activate(textBubbleConstraints)
    }
    
    private func deactivateAllTextBubbleConstraints() {
        NSLayoutConstraint.deactivate(textBubbleConstraints)
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
    var text: String { get set }
}

public struct StandaloneItem: WalkthroughItem {
    public typealias LayoutHandler = (UIView) -> [NSLayoutConstraint]?

    public init(centerOffset: CGPoint = CGPoint.zero, text: String, layoutHandler: LayoutHandler? = nil) {
        self.centerOffset = centerOffset
        self.text = text
        self.layoutHandler = layoutHandler
    }
    public var centerOffset: CGPoint
    public var text: String
    let layoutHandler: LayoutHandler?
}

public struct HighlightedItem: WalkthroughItem {
    public init(highlightedArea: UIView, textLocation: TextLocation, text: String) {
        self.highlightedArea = highlightedArea
        self.textLocation = textLocation
        self.text = text
    }

    public var highlightedArea: UIView
    public var textLocation: TextLocation
    public var text: String

    public enum TextLocation {
        case above, below
    }
}

public protocol WalkthroughDelegate: class {
    func walkthroughCompleted()
}
