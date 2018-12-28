//  PaddingLabel.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2017-02-02.

@IBDesignable public class PaddingLabel: UILabel {

    @IBInspectable var topInset: CGFloat = 20.0
    @IBInspectable var bottomInset: CGFloat = 20.0
    @IBInspectable var leftInset: CGFloat = 20.0
    @IBInspectable var rightInset: CGFloat = 20.0

    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience public init(frame: CGRect, insets: UIEdgeInsets) {
        self.init(frame: frame)
        topInset = insets.top
        bottomInset = insets.bottom
        leftInset = insets.left
        rightInset = insets.right
    }

    convenience public init(insets: UIEdgeInsets) {
        self.init(frame: CGRect(), insets: insets)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func drawText(in rect: CGRect) {
        let padding = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: padding))
    }

    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize

        let textWidth = frame.size.width - (self.leftInset + self.rightInset)
        let size = CGSize(width: textWidth, height: CGFloat.greatestFiniteMagnitude)
        let newSize = self.text!.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font], context: nil)
        intrinsicSuperViewContentSize.height = ceil(newSize.size.height) + self.topInset + self.bottomInset

        return intrinsicSuperViewContentSize
    }

    override public func sizeThatFits(_ size: CGSize) -> CGSize {
        let width = size.width - leftInset - rightInset
        let height = size.height - topInset - bottomInset
        let superSizeThatFits = super.sizeThatFits(CGSize(width: width, height: height))
        return CGSize(width: superSizeThatFits.width + leftInset + rightInset, height: superSizeThatFits.height + topInset + bottomInset)
    }
}
