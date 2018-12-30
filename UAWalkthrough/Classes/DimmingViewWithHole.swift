//
//  DimmingViewWithHole.swift
//  UAWalkthrough
//
//  Created by Marcel Hasselaar on 2017-02-02.

public class DimmingViewWithHole: UIView {
    
    let dimmingAlpha = CGFloat(0.7)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        let screenBounds = UIScreen.main.bounds
        let maxDimension = max(screenBounds.height, screenBounds.width)  // To support rotating

        self.backgroundColor = UIColor.clear
        
        let topDimmingView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        topDimmingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topDimmingView)
        topDimmingView.backgroundColor = UIColor.black.withAlphaComponent(dimmingAlpha)
        topDimmingView.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true
        topDimmingView.heightAnchor.constraint(equalToConstant: maxDimension).isActive = true
        topDimmingView.widthAnchor.constraint(equalToConstant: maxDimension*2).isActive = true
        topDimmingView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let bottomDimmingView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        bottomDimmingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomDimmingView)
        bottomDimmingView.backgroundColor = UIColor.black.withAlphaComponent(dimmingAlpha)
        bottomDimmingView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        bottomDimmingView.heightAnchor.constraint(equalToConstant: maxDimension).isActive = true
        bottomDimmingView.widthAnchor.constraint(equalToConstant: maxDimension*2).isActive = true
        bottomDimmingView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        let leftDimmingView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        leftDimmingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftDimmingView)
        leftDimmingView.backgroundColor = UIColor.black.withAlphaComponent(dimmingAlpha)
        leftDimmingView.rightAnchor.constraint(equalTo: leftAnchor).isActive = true
        leftDimmingView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        leftDimmingView.widthAnchor.constraint(equalToConstant: maxDimension).isActive = true
        leftDimmingView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let rightDimmingView = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        rightDimmingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightDimmingView)
        rightDimmingView.backgroundColor = UIColor.black.withAlphaComponent(dimmingAlpha)
        rightDimmingView.leftAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        rightDimmingView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rightDimmingView.widthAnchor.constraint(equalToConstant: maxDimension).isActive = true
        rightDimmingView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    override func layoutSubviews() {
    //        super.layoutSubviews()
    //
    ////        let maskLayer = CAShapeLayer()
    ////        maskLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 6.0).cgPath
    ////        maskLayer.backgroundColor = UIColor.red.cgColor
    //
    //        if roundedCornersBackgroundLayer == nil {
    //            let backgroundLayer = CALayer()
    //            backgroundLayer.masksToBounds = true
    //
    //            innerBackgroundLayer.borderColor = UIColor.black.withAlphaComponent(dimmingAlpha).cgColor
    //            innerBackgroundLayer.borderWidth = 10
    //            innerBackgroundLayer.cornerRadius = 15
    //
    //            backgroundLayer.addSublayer(innerBackgroundLayer)
    //            layer.addSublayer(backgroundLayer)
    //            roundedCornersBackgroundLayer = backgroundLayer
    //            layer.shouldRasterize = true
    //
    //        }
    //        innerBackgroundLayer.frame = bounds.insetBy(dx: -5, dy: -5)
    //        roundedCornersBackgroundLayer?.frame = bounds
    //
    //        //        backgroundLayer.backgroundColor = UIColor.black.cgColor
    //
    ////        backgroundLayer.mask = maskLayer
    ////        layer.masksToBounds = true
    ////        layer.backgroundColor = UIColor.black.cgColor
    ////        layer.mask = maskLayer
    //
    //    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return true
    }
    
    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return self
    }
}
