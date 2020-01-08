//
//  Bubble.swift
//  FBSnapshotTestCase
//
//  Created by Marcel Hasselaar on 2020-01-07.
//

import UIKit

public class Bubble: UIView {

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }

    init(preferredMaxLayoutWidth: CGFloat? = nil, minBubbleHorizontalMargin: CGFloat = 0, animationDuration: Double = 0.35, style: BubbleStyle = .default) {
        self.minBubbleHorizontalMargin = minBubbleHorizontalMargin
        self.animationDuration = animationDuration

        super.init(frame: CGRect.zero)

        translatesAutoresizingMaskIntoConstraints = false
        if let preferredMaxLayoutWidth = preferredMaxLayoutWidth {
            textLabel.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        }
        roundedCornerView = createRoundedCornerView(cornerRadius: style.cornerRadius)
        addSubview(roundedCornerView)
        roundedCornerView.bound(inside: self)
        backgroundColor = .clear

        defer { self.style = style }
    }

    func configure(withWalkthroughItem walkthroughItem: WalkthroughItem) {
        deactivateAllBubbleConstraints()
        deactivateAllArrowConstraints()

        configureContent(walkthroughItem.content)
        if let standaloneItem = walkthroughItem as? StandaloneItem {
            configure(withStandaloneItem: standaloneItem)
        } else if let highlightedItem = walkthroughItem as? HighlightedItem {
            configure(withHighlightedItem: highlightedItem)
        }
    }

    private func configure(withStandaloneItem standaloneItem: StandaloneItem) {
        if let layoutHandler = standaloneItem.layoutHandler {
            if let customConstraints = layoutHandler(self) {
                bubbleConstraints = customConstraints
            }
        } else if let centerOffset = standaloneItem.centerOffset, let outerView = outerView {
            let horizontalCenterConstraint = centerXAnchor.constraint(equalTo: outerView.centerXAnchor, constant: centerOffset.x)
            horizontalCenterConstraint.priority = superlowLayoutPriority
            let verticalCenterConstraint = centerYAnchor.constraint(equalTo: outerView.centerYAnchor, constant: centerOffset.y)
            verticalCenterConstraint.priority = superlowLayoutPriority
            bubbleConstraints = [horizontalCenterConstraint, verticalCenterConstraint]
            addHorizontalMarginConstraints()
        } else {
            assert(false, "A StandAlone item needs to have either a layout handler or a center offset configured.")
            return
        }
        arrow.isHidden = true
        arrowXConstraint = centerXAnchor.constraint(equalTo: arrow.centerXAnchor)
        arrowYConstraint = centerYAnchor.constraint(equalTo: arrow.centerYAnchor)
        activateAllArrowConstraints()
        activateAllBubbleConstraints()
    }

    private func configure(withHighlightedItem highlightedItem: HighlightedItem) {
        let centerConstraint = centerXAnchor.constraint(equalTo: highlightedItem.highlightedArea.centerXAnchor)
        centerConstraint.priority = superlowLayoutPriority
        bubbleConstraints = [centerConstraint]
        addHorizontalMarginConstraints()

        if highlightedItem.textLocation == .above {
            bubbleConstraints.append(bottomAnchor.constraint(equalTo: highlightedItem.highlightedArea.topAnchor, constant: -style.yOffsetToHighlightedArea - style.arrowSize.height))
        } else {
            bubbleConstraints.append(topAnchor.constraint(equalTo: highlightedItem.highlightedArea.bottomAnchor, constant: style.yOffsetToHighlightedArea + style.arrowSize.height))
        }

        activateAllBubbleConstraints()

        deactivateAllArrowConstraints()

        arrow.isHidden = false

        // By rotating the arrow exactly at the middle of the animation should have it rotated while not visible.
        // Using a arrow larger than then bubble will still look weird though as it will not be completely hidden during rotation.
        let rotationAnimationDuration = animationDuration / 2 + 0.0000001
        let rotationAnimationDelay = rotationAnimationDuration / 2
        if highlightedItem.textLocation == .below {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: {
                self.arrow.transform = CGAffineTransform(rotationAngle: .pi)
            }, completion: nil)
            arrowYConstraint = topAnchor.constraint(equalTo: arrow.bottomAnchor)
        } else {
            UIView.animate(withDuration: rotationAnimationDuration, delay: rotationAnimationDelay, options: [], animations: {
                self.arrow.transform = .identity
            }, completion: nil)
            arrowYConstraint = bottomAnchor.constraint(equalTo: arrow.topAnchor)
        }
        arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: highlightedItem.highlightedArea.centerXAnchor)
        activateAllArrowConstraints()
    }

    private func configureContent(_ content: Content) {
        switch content {
        case .customView(let view):
            configure(withCustomView: view)
        default:
            configure(withTextContent: content)
        }
    }

    private var style: BubbleStyle = BubbleStyle.default {
        didSet {
            textLabel.textColor = style.textColor
            textLabel.backgroundColor = style.backgroundColor
            textLabel.insets = style.textInsets
            deactivateAllArrowConstraints()
            arrow?.removeFromSuperview()
            arrow = ArrowView(size: style.arrowSize, color: style.backgroundColor)
            insertSubview(arrow, belowSubview: roundedCornerView)
            roundedCornerView.backgroundColor = style.backgroundColor

            if let shadowStyle = style.shadowStyle {
                layer.shadowOpacity = shadowStyle.shadowOpacity
                layer.shadowColor = shadowStyle.shadowColor.cgColor
                layer.shadowOffset = shadowStyle.shadowOffset
            } else {
                layer.shadowColor = nil
            }
        }
    }

    private func configure(withCustomView customView: UIView) {
        self.customView?.removeFromSuperview()
        self.customView = nil
        roundedCornerView.addSubview(customView)
        self.customView = customView
        customView.bound(inside: roundedCornerView)
        textLabel.isHidden = true
        UIView.animate(withDuration: 0.001) {
            customView.layoutIfNeeded()
            self.roundedCornerView.layoutIfNeeded()
        }
    }

    private func configure(withTextContent textContent: Content) {
        customView?.removeFromSuperview()
        customView = nil
        if textLabel.superview == nil {
            roundedCornerView.addSubview(textLabel)
            textLabel.bound(inside: self)
        }
        if case .plainText(let plainText) = textContent {
            textLabel.text = plainText
        } else if case .attributedText(let attributedText) = textContent {
            textLabel.attributedText = attributedText
        }
        textLabel.isHidden = false
    }

    var outerView: UIView? {
        superview is DimmingViewWithHole ? superview?.superview : superview
    }

    private func addHorizontalMarginConstraints() {
        guard let outerView = outerView else { return }
        let leftMarginConstraint = leftAnchor.constraint(greaterThanOrEqualTo: outerView.leftAnchor, constant: minBubbleHorizontalMargin)
        let rightMarginConstraint = outerView.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: minBubbleHorizontalMargin)

        bubbleConstraints.append(contentsOf: [leftMarginConstraint, rightMarginConstraint])
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
        return bubblePaddingLabel
    }()

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

    private func createRoundedCornerView(cornerRadius: CGFloat) -> UIView {
        let roundedCornerView = UIView()
        roundedCornerView.translatesAutoresizingMaskIntoConstraints = false
        roundedCornerView.layer.cornerRadius = cornerRadius
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.clipsToBounds = true
        return roundedCornerView
    }

    private let minBubbleHorizontalMargin: CGFloat
    private let animationDuration: Double

    private var roundedCornerView: UIView!
    private var arrow: ArrowView!

    fileprivate var bubbleConstraints = [NSLayoutConstraint]()
    fileprivate var arrowXConstraint: NSLayoutConstraint?
    fileprivate var arrowYConstraint: NSLayoutConstraint?
    private let superlowLayoutPriority = UILayoutPriority(rawValue: 1)  // Used to safeguard that our constraints doesn't affect the highlighted views
}

class ArrowView: UIView {

    init(size: CGSize, color: UIColor) {
        self.color = color
        arrowLayer = ArrowView.createArrowShapeLayer(size: size, color: color)
        super.init(frame: CGRect(origin: CGPoint.zero, size: size))
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(arrowLayer)
        widthAnchor.constraint(equalToConstant: size.width).isActive = true
        heightAnchor.constraint(equalToConstant: size.height).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var color: UIColor {
        didSet {
            let newArrowLayer = ArrowView.createArrowShapeLayer(size: frame.size, color: color)
            layer.replaceSublayer(arrowLayer, with: newArrowLayer)
            arrowLayer = newArrowLayer
        }
    }

    private class func createArrowShapeLayer(size: CGSize, color: UIColor) -> CALayer {
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
        return arrowShapeLayer
    }

    private var arrowLayer: CALayer
}

