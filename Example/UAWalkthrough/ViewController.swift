//
//  ViewController.swift
//  UAWalkthrough
//
//  Created by marhas on 02/13/2018.
//  Copyright (c) 2018 marhas. All rights reserved.
//

import UIKit
import UAWalkthrough

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    var walkthroughSettings = WalkthroughSettings(preferredTextBubbleMaxLayoutWidth: 300, presentationMode: .none)
    var walkthroughStyle = TextBubbleStyle.white

    override func viewDidAppear(_ animated: Bool) {
        hasCompletedWalkthrough = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.startWalkthrough(withSettings: self.walkthroughSettings, style: self.walkthroughStyle)
        }
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        hasCompletedWalkthrough = false
        self.startWalkthrough(withSettings: walkthroughSettings, style: walkthroughStyle)
    }
}

extension ViewController: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        return [
            StandaloneItem(text: "This is a demo of the UAWalkthrough pod, which can be used eg to introduce your app to your user.", layoutHandler: { [weak self] bubble in
                guard let self = self else { return nil }
                return [
                    bubble.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    bubble.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 43)
                ]
            }),
            HighlightedItem(highlightedArea: slider, textLocation: .below, text: "It can be configured to progress automatically and/or require that the user taps the screen to move to the next element. This is by the way a UISlider."),
            HighlightedItem(highlightedArea: button1, textLocation: .below, text: "If you press this button ... nothing happens."),
            HighlightedItem(highlightedArea: button2, textLocation: .below, text: "This is another button. Try it. But first we need to finish the walkthrough."),
            HighlightedItem(highlightedArea: button3, textLocation: .above, text: "Down here there's yet another button, which will do absolutely nothing for you."),
            HighlightedItem(highlightedArea: button4, textLocation: .above, text: "...and this is the fourth and last button on this screen, and also the end of the onboarding."),
            StandaloneItem(centerOffset: CGPoint(x: 0, y: -120), text: "For more advanced usage scenarios, you can add a delegate to take action on walkthrough completion. Thanks for your attention!"),
        ]
    }
}
