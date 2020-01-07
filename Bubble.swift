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

    init(bubbleBackgroundColor: UIColor = .white, minBubbleHorizontalMargin: CGFloat = 0, yOffsetToHighlightedArea: CGFloat = 8, arrowSize: CGSize = CGSize(width: 25, height: 12)) {
        self.minBubbleHorizontalMargin = minBubbleHorizontalMargin
        self.yOffsetToHighlightedArea = yOffsetToHighlightedArea
        self.arrowSize = arrowSize
        arrow = ArrowView(size: arrowSize, color: bubbleBackgroundColor)

        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false

        addSubview(roundedCornerView)
        roundedCornerView.bound(inside: self)
        roundedCornerView.backgroundColor = bubbleBackgroundColor
        addSubview(arrow)
        backgroundColor = .clear
    }

    func configure(withWalkthroughItem walkthroughItem: WalkthroughItem, anchorView: UIView? = nil) {
        deactivateAllBubbleConstraints()
        deactivateAllArrowConstraints()

        configureContent(walkthroughItem.content)
        if let standaloneItem = walkthroughItem as? StandaloneItem {
            configure(withStandaloneItem: standaloneItem, anchorView: anchorView)
        } else if let highlightedItem = walkthroughItem as? HighlightedItem {
            guard let anchorView = anchorView ?? superview else { return }
            configure(withHighlightedItem: highlightedItem, anchorView: anchorView)
        }
    }

    private func configure(withStandaloneItem standaloneItem: StandaloneItem, anchorView: UIView?) {
        if let layoutHandler = standaloneItem.layoutHandler {
            if let customConstraints = layoutHandler(self) {
                bubbleConstraints = customConstraints
            }
        } else if let centerOffset = standaloneItem.centerOffset, let anchorView = anchorView {
            let horizontalCenterConstraint = centerXAnchor.constraint(equalTo: anchorView.centerXAnchor, constant: centerOffset.x)
            let verticalCenterConstraint = centerYAnchor.constraint(equalTo: anchorView.centerYAnchor, constant: centerOffset.y)
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

    private func configure(withHighlightedItem highlightedItem: HighlightedItem, anchorView: UIView) {
        let centerConstraint = centerXAnchor.constraint(equalTo: highlightedItem.highlightedArea.centerXAnchor)
        centerConstraint.priority = .defaultLow
        bubbleConstraints = [centerConstraint]
        addHorizontalMarginConstraints()

        if highlightedItem.textLocation == .above {
            bubbleConstraints.append(bottomAnchor.constraint(equalTo: anchorView.topAnchor, constant: -yOffsetToHighlightedArea - arrowSize.height))
        } else {
            bubbleConstraints.append(topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: yOffsetToHighlightedArea + arrowSize.height))
        }

        activateAllBubbleConstraints()

        deactivateAllArrowConstraints()

        arrow.isHidden = false

        // The rotation of the arrow should happen so that is is not visible. Hence it doesn't even need to be animated, but it is easier to get the timing right that way
        //        let rotationAnimationDuration = settings.stepAnimationDuration / 3.0
        // TODO
        let rotationAnimationDuration = 0.0
        let rotationAnimationDelay = 0.15
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
        arrowXConstraint = arrow.centerXAnchor.constraint(equalTo: anchorView.centerXAnchor)
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

    var style: BubbleStyle = BubbleStyle.default {
        didSet {
            textLabel.textColor = style.textColor
            textLabel.backgroundColor = style.backgroundColor
            textLabel.insets = style.textInsets
            arrow.color = style.backgroundColor
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

    private func addHorizontalMarginConstraints() {
        guard let superView = superview else { return }
        let leftMarginConstraint = leftAnchor.constraint(greaterThanOrEqualTo: superView.leftAnchor, constant: minBubbleHorizontalMargin)
        let rightMarginConstraint = superView.rightAnchor.constraint(greaterThanOrEqualTo: rightAnchor, constant: minBubbleHorizontalMargin)

        bubbleConstraints.append(contentsOf: [leftMarginConstraint, rightMarginConstraint])
    }

    private var customView: UIView?

    lazy var textLabel: PaddingLabel = {
        let bubblePaddingLabel = PaddingLabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0), insets: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        bubblePaddingLabel.backgroundColor = style.backgroundColor
        bubblePaddingLabel.backgroundColor = UIColor.green.withAlphaComponent(0.5)
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

//    static private func createArrowView(size: CGSize = CGSize(width: 25, height: 12), color: UIColor) -> UIView {
//        let arrowShapeLayer = CAShapeLayer()
//        let origin = CGPoint(x: 0, y: 0)
//        arrowShapeLayer.frame = CGRect(origin: origin, size: size)
//        let arrowPath = UIBezierPath()
//        arrowPath.move(to: origin)
//        arrowPath.addLine(to: CGPoint(x: size.width/2, y: size.height))
//        arrowPath.addLine(to: CGPoint(x: size.width, y: 0))
//        arrowPath.close()
//        arrowShapeLayer.path = arrowPath.cgPath
//        arrowShapeLayer.fillColor = color.cgColor
//        let view = UIView(frame: arrowShapeLayer.frame)
//        view.backgroundColor = .clear
//        view.layer.addSublayer(arrowShapeLayer)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.widthAnchor.constraint(equalToConstant: size.width).isActive = true
//        view.heightAnchor.constraint(equalToConstant: size.height).isActive = true
//        return view
//    }

    private let minBubbleHorizontalMargin: CGFloat
    private let yOffsetToHighlightedArea: CGFloat
    private let arrowSize: CGSize
    private static let defaultCornerRadius: CGFloat = 12.0
    private let roundedCornerView: UIView = {
        let roundedCornerView = UIView()
        roundedCornerView.translatesAutoresizingMaskIntoConstraints = false
        roundedCornerView.layer.cornerRadius = defaultCornerRadius
        roundedCornerView.layer.masksToBounds = true
        roundedCornerView.clipsToBounds = true
        roundedCornerView.backgroundColor = .green
        return roundedCornerView
    }()

    var arrow: ArrowView

    fileprivate var bubbleConstraints = [NSLayoutConstraint]()
    fileprivate var arrowXConstraint: NSLayoutConstraint?
    fileprivate var arrowYConstraint: NSLayoutConstraint?
}

class ArrowView: UIView {

    init(size: CGSize, color: UIColor) {
        self.color = color
        arrowLayer = ArrowView.createArrowShapeLayer(size: size, color: color)
        super.init(frame: CGRect(origin: CGPoint.zero, size: size))
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(arrowLayer)
//        widthAnchor.constraint(equalToConstant: size.width).isActive = true
//        heightAnchor.constraint(equalToConstant: size.height).isActive = true

    }

//    init(size: CGSize, color: UIColor) {
//        super.init(frame: fr)
//        let view = UIView(frame: arrowShapeLayer.frame)
//
//    }

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

