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

    var walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3, preferredTextBubbleMaxLayoutWidth: 300, presentationMode: .none)
    var walkthroughStyle = TextBubbleStyle.white

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.startWalkthrough(withSettings: self.walkthroughSettings, style: self.walkthroughStyle, delegate: self, showEvenIfItHasAlreadyBeenCompleted: true)
        }
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        self.startWalkthrough(withSettings: walkthroughSettings, style: walkthroughStyle)
    }
}

extension WhiteStyleDemoVC: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        let attributedString = NSMutableAttributedString(string: "You can also use attributed strings. ", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        attributedString.append(NSAttributedString(string: "For example some bold text.", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]))

        return [
            StandaloneItem(text: .plain("This is a demo of UAWalkthrough. Use it to introduce your app to new users or highlight new features."), layoutHandler: { [weak self] bubble in
                guard let self = self else { return nil }
                return [
                    bubble.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    bubble.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 220)
                ]
            }),
            HighlightedItem(highlightedArea: slider, textLocation: .below, text: .plain("It can be configured to progress automatically and/or require that the user taps the screen to move to the next element. This is by the way a UISlider.")),
            HighlightedItem(highlightedArea: button1, textLocation: .below, text: .plain("If you press this button ... nothing happens.")),
            HighlightedItem(highlightedArea: button2, textLocation: .below, text: .plain("This is another button. Try it. But first we need to finish the walkthrough.")),
            HighlightedItem(highlightedArea: button3, textLocation: .above, text: .attributed(attributedString)),
            HighlightedItem(highlightedArea: button4, textLocation: .above, text: .plain("This is the fourth and last button on this screen, and also the end of the onboarding.")),
            StandaloneItem(centerOffset: CGPoint(x: 0, y: -120), text: .plain("For more advanced usage scenarios, you can add a delegate to take action on walkthrough completion.\nThanks for your attention!")),
        ]
    }
}

extension WhiteStyleDemoVC: WalkthroughDelegate {
    func walkthroughCompleted() {
        self.tabBarController?.selectedIndex = 1
    }
}
