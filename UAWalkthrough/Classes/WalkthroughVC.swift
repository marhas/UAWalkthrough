//
//  WalkthroughVC.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2017-02-02.

import Foundation

public protocol WalkthroughController {
    func dismissWalkthrough()
}

public extension UIViewController {
    @discardableResult
    public func startWalkthrough(withSettings settings: WalkthroughSettings = WalkthroughSettings(), delegate: WalkthroughDelegate? = nil) -> WalkthroughController {
        let walkthroughVC = WalkthroughVC()
        walkthroughVC.walkthroughSettings = settings
        walkthroughVC.walkthroughDelegate = delegate
        addChildViewController(walkthroughVC)
        walkthroughVC.didMove(toParentViewController: self)
        return walkthroughVC
    }
}

public struct WalkthroughSettings {
    var stepAnimationDuration = 0.3
    var highlightingOffset = CGPoint(x: 25, y: 25)
    var automaticWalkthroughDelaySeconds: Int?

    public init(stepAnimationDuration: Double = 0.3,
         highlightingOffset: CGPoint = CGPoint(x: 25, y: 25),
         automaticWalkthroughDelaySeconds: Int? = nil) {
        self.stepAnimationDuration = stepAnimationDuration
        self.highlightingOffset = highlightingOffset
        self.automaticWalkthroughDelaySeconds = automaticWalkthroughDelaySeconds
    }
}

public class WalkthroughVC: UIViewController, WalkthroughController {

    fileprivate var walkthroughSettings = WalkthroughSettings()

    fileprivate var viewCenterXConstraint: NSLayoutConstraint?
    fileprivate var viewCenterYConstraint: NSLayoutConstraint?
    fileprivate var viewHeightConstraint: NSLayoutConstraint?
    fileprivate var viewWidthConstraint: NSLayoutConstraint?
    fileprivate var textBubbleHorizontalConstraints: [NSLayoutConstraint]?
    fileprivate var textBubbleVerticalConstraint: NSLayoutConstraint?
    fileprivate var arrowXConstraint: NSLayoutConstraint?
    fileprivate var arrowYConstraint: NSLayoutConstraint?
    fileprivate var stepWalkthroughTimer: Timer?
    
    weak var walkthroughProvider: WalkthroughProvider?
    weak var walkthroughDelegate: WalkthroughDelegate?
    fileprivate var backgroundDimmingView: DimmingViewWithHole!
    
    static let textBubbleBackgroundColor = UIColor.tooltipBackground
    static let distanceBetweenTextBubbleAndHightlightedArea:CGFloat = 17
    static let textBubbleArrowOverlap = CGFloat(8)
    
    var textBubble: PaddingLabel = {
        let bubblePaddingLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100), insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
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

    var currentWalkthroughItemIndex = 0
    
    var arrow = WalkthroughVC.createArrowView(size: CGSize(width: 25, height: distanceBetweenTextBubbleAndHightlightedArea + textBubbleArrowOverlap))
    
    let tapGestureRecognizer = UITapGestureRecognizer()

    override public func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

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
        
        backgroundDimmingView = DimmingViewWithHole(frame: .zero)
        backgroundDimmingView.translatesAutoresizingMaskIntoConstraints = false
        backgroundDimmingView.addGestureRecognizer(tapGestureRecognizer)
        
        parentVC.view.addSubview(backgroundDimmingView)
        viewWidthConstraint = backgroundDimmingView.widthAnchor.constraint(equalToConstant: 0)
        viewHeightConstraint = backgroundDimmingView.heightAnchor.constraint(equalToConstant: 0)
        viewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)
        viewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: parentVC.view.centerYAnchor)
        
        activateAllHighlightingConstraints()
        
        let dummyWalkthroughItem = WalkthroughItem(highlightedArea: parentVC.view, textLocation: .above, text: "")
        showWalkthroughItem(dummyWalkthroughItem, onView: parentVC.view)
        
        stepWalkthrough()
    }

    override public func viewWillDisappear(_ animated: Bool) {
        dismissWalkthrough()
    }

    public func dismissWalkthrough() {
        backgroundDimmingView.removeGestureRecognizer(tapGestureRecognizer)
        backgroundDimmingView.removeFromSuperview()
        removeFromParentViewController()
        walkthroughDelegate?.walkthroughCompleted()
    }

    @objc func stepWalkthrough() {
        stepWalkthroughTimer?.invalidate()
        guard let walkthroughProvider = walkthroughProvider, let parentVC = parent, currentWalkthroughItemIndex < walkthroughProvider.walkthroughItems.count else {
            self.walkthroughProvider?.hasCompletedWalkthrough = true
            dismissWalkthrough()
            return
        }
        if let delay = walkthroughSettings.automaticWalkthroughDelaySeconds {
            stepWalkthroughTimer = Timer.scheduledTimer(timeInterval: TimeInterval(delay), target: self, selector: #selector(stepWalkthrough), userInfo: nil, repeats: false)
        }
        showWalkthroughItem(walkthroughProvider.walkthroughItems[currentWalkthroughItemIndex], onView: parentVC.view)
        currentWalkthroughItemIndex += 1
    }
    
    private func showWalkthroughItem(_ walkthroughItem: WalkthroughItem, onView view: UIView) {
        deactivateAllHighlightingConstraints()
        
        viewWidthConstraint =  backgroundDimmingView.widthAnchor.constraint(equalTo: walkthroughItem.highlightedArea.widthAnchor, multiplier: 1, constant: walkthroughSettings.highlightingOffset.x)
        viewHeightConstraint =  backgroundDimmingView.heightAnchor.constraint(equalTo: walkthroughItem.highlightedArea.heightAnchor, multiplier: 1, constant: walkthroughSettings.highlightingOffset.y)
        
        viewCenterXConstraint = backgroundDimmingView.centerXAnchor.constraint(equalTo: walkthroughItem.highlightedArea.centerXAnchor)
        viewCenterYConstraint = backgroundDimmingView.centerYAnchor.constraint(equalTo: walkthroughItem.highlightedArea.centerYAnchor)
        
        activateAllHighlightingConstraints()
        
        self.updateTextBubble(walkthroughItem: walkthroughItem)
        
        UIView.animate(withDuration: walkthroughSettings.stepAnimationDuration, animations: {
            view.layoutIfNeeded()
        })
    }
    
    private func updateTextBubble(walkthroughItem: WalkthroughItem) {
        guard let parentVC = parent else { return }
        
        deactivateAllTextBubbleConstraints()
        
        if textBubble.superview == nil {
            backgroundDimmingView.addSubview(textBubble)
        }
        
        textBubble.isHidden = false
        textBubble.text = walkthroughItem.text
        textBubbleHorizontalConstraints = [textBubble.centerXAnchor.constraint(equalTo: parentVC.view.centerXAnchor)]
        textBubbleHorizontalConstraints?.append(textBubble.widthAnchor.constraint(equalTo: parentVC.view.widthAnchor, constant: -20))
        
        if walkthroughItem.textLocation == .above {
            textBubbleVerticalConstraint = textBubble.bottomAnchor.constraint(equalTo: backgroundDimmingView.topAnchor, constant: -WalkthroughVC.distanceBetweenTextBubbleAndHightlightedArea)
        } else {
            textBubbleVerticalConstraint = textBubble.topAnchor.constraint(equalTo: backgroundDimmingView.bottomAnchor, constant: WalkthroughVC.distanceBetweenTextBubbleAndHightlightedArea)
        }
        
        activateAllTextBubbleConstraints()
        
        arrowYConstraint?.isActive = false
        arrowXConstraint?.isActive = false

        if (arrow.superview == nil) {
            backgroundDimmingView.addSubview(arrow)
            backgroundDimmingView.bringSubview(toFront: textBubble)
        }

        // The rotation of the arrow should happen so that is is not visible. Hence it doesn't even need to be animated, but it is easier to get the timing right that way
        let rotationAnimationDuration = walkthroughSettings.stepAnimationDuration / 3.0
        let rotationAnimationDelay = rotationAnimationDuration
        if walkthroughItem.textLocation == .below {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: { 
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }, completion: nil)
            arrowYConstraint = backgroundDimmingView.bottomAnchor.constraint(equalTo: arrow.topAnchor, constant: WalkthroughVC.textBubbleArrowOverlap - 1)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: backgroundDimmingView.centerXAnchor)
            arrowYConstraint?.isActive = true
            arrowXConstraint?.isActive = true
        } else {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: {
                self.arrow.transform = .identity
            }, completion: nil)
            arrowYConstraint = arrow.bottomAnchor.constraint(equalTo: backgroundDimmingView.topAnchor, constant: WalkthroughVC.textBubbleArrowOverlap - 1)
            arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: backgroundDimmingView.centerXAnchor)
            arrowYConstraint?.isActive = true
            arrowXConstraint?.isActive = true
        }
    }
    
    class func createArrowView(size: CGSize = CGSize(width: 30, height: 25)) -> UIView {
        let arrowShapeLayer = CAShapeLayer()
        let origin = CGPoint(x: 0, y: 0)
        arrowShapeLayer.frame = CGRect(origin: origin, size: size)
        let arrowPath = UIBezierPath()
        arrowPath.move(to: origin)
        arrowPath.addLine(to: CGPoint(x: size.width/2, y: size.height))
        arrowPath.addLine(to: CGPoint(x: size.width, y: 0))
        arrowPath.close()
        arrowShapeLayer.path = arrowPath.cgPath
        arrowShapeLayer.fillColor = textBubbleBackgroundColor.cgColor
        let view = UIView(frame: arrowShapeLayer.frame)
        view.layer.addSublayer(arrowShapeLayer)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        
        return view
    }
    
    private func activateAllTextBubbleConstraints() {
        if let horizontalConstraints = textBubbleHorizontalConstraints {
            NSLayoutConstraint.activate(horizontalConstraints)
        }
        textBubbleVerticalConstraint?.isActive = true
    }
    
    private func deactivateAllTextBubbleConstraints() {
        if let horizontalConstraints = textBubbleHorizontalConstraints {
            NSLayoutConstraint.deactivate(horizontalConstraints)
        }
        textBubbleVerticalConstraint?.isActive = false
    }
    
    private func activateAllHighlightingConstraints() {
        NSLayoutConstraint.activate([viewWidthConstraint, viewHeightConstraint, viewCenterXConstraint, viewCenterYConstraint].flatMap { $0 })
    }
    
    private func deactivateAllHighlightingConstraints() {
        NSLayoutConstraint.deactivate([viewWidthConstraint, viewHeightConstraint, viewCenterXConstraint, viewCenterYConstraint].flatMap { $0 })
    }
}

public struct WalkthroughItem {
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

public protocol WalkthroughDelegate: class {
    func walkthroughCompleted()
}

