//
//  ViewController.swift
//  UAWalkthrough
//
//  Created by marhas on 02/13/2018.
//  Copyright (c) 2018 Marcel Hasselaar. All rights reserved.
//

import UIKit
import UAWalkthrough

class WhiteStyleDemoVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    var walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3, preferredBubbleMaxLayoutWidth: 300, presentationMode: .none)
    var walkthroughStyle = BubbleStyle.white

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.startWalkthrough(withSettings: self.walkthroughSettings, style: self.walkthroughStyle, delegate: self, showEvenIfItHasAlreadyBeenCompleted: true)
        }

        let bubbleStyle = BubbleStyle(textColor: .white, backgroundColor: .orange, shadowStyle: .dark, cornerRadius: 20, yOffsetToHighlightedArea: 2)
        let bubbleItem = HighlightedItem(highlightedArea: button1, textLocation: .below, text: .plainText("This is a standalone bubble"))
        let bubbleView = showBubble(withWalkthroughItem: bubbleItem, minBubbleHorizontalMargin: 20, preferredBubbleMaxLayoutWidth: 300, style: bubbleStyle)
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        self.startWalkthrough(withSettings: walkthroughSettings, style: walkthroughStyle)
    }
}

extension WhiteStyleDemoVC: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        let attributedString = NSMutableAttributedString(string: "You can also use attributed strings. ", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        attributedString.append(NSAttributedString(string: "For example some bold text.", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]))
        let customView = createCustomView()

        return [
            StandaloneItem(text: .plainText("This is a demo of UAWalkthrough. Use it to introduce your app to new users or highlight new features."), layoutHandler: { [weak self] bubble in
                guard let self = self else { return nil }
                return [
                    bubble.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    bubble.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220)
                ]
            })
            ,
            HighlightedItem(highlightedArea: slider, textLocation: .below, text: .plainText("It can be configured to progress automatically and/or require that the user taps the screen to move to the next element. This is by the way a UISlider.")),
            HighlightedItem(highlightedArea: button1, textLocation: .below, text: .plainText("If you press this button ... nothing happens.")),
            HighlightedItem(highlightedArea: button2, textLocation: .above, text: .attributedText(attributedString)),
            HighlightedItem(highlightedArea: button3, textLocation: .below, text: .customView(customView)),
            HighlightedItem(highlightedArea: button4, textLocation: .above, text: .plainText("This is the fourth and last button on this screen, and also the end of the onboarding.")),
            StandaloneItem(text: .plainText("For more advanced usage scenarios, you can add a delegate to take action on walkthrough completion.\nThanks for your attention!"), centerOffset: CGPoint(x: 0, y: -120)),
        ]
    }

    private func createCustomView() -> UIView {
        let customView = UIView()
        let view1 = createAutolayoutView(withBackgroundColor: .yellow)
        let view2 = createAutolayoutView(withBackgroundColor: .orange)
        let view3 = createAutolayoutView(withBackgroundColor: .red)
        let stackView = UIStackView(arrangedSubviews: [view1, view2, view3])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        customView.addSubview(stackView)
        stackView.bound(inside: customView)
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .clear
        label.text = "You can even put a custom views in a bubble like this."
        customView.addSubview(label)
        label.bound(inside: customView)
        customView.widthAnchor.constraint(equalToConstant: 250).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        return customView
    }

    private func createAutolayoutView(withBackgroundColor backgroundColor: UIColor? = UIColor.clear) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        return view
    }
}

extension WhiteStyleDemoVC: WalkthroughDelegate {
    func walkthroughCompleted() {
        self.tabBarController?.selectedIndex = 1
    }
}

extension UIView {
    func bound(inside outer: UIView) {
        self.topAnchor.constraint(equalTo: outer.topAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: outer.rightAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: outer.bottomAnchor).isActive = true
        self.leftAnchor.constraint(equalTo: outer.leftAnchor).isActive = true
    }
}
