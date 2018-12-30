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

    var walkthroughSettings = WalkthroughSettings(preferredTextBubbleMaxLayoutWidth: 300)

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
//        let walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3)
        hasCompletedWalkthrough = false

//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [unowned self] in
            self.startWalkthrough(withSettings: walkthroughSettings)
//        self.startWalkthrough()
//        }
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        hasCompletedWalkthrough = false
        self.startWalkthrough(withSettings: walkthroughSettings)
    }
}

extension ViewController: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        return [
            WalkthroughItem(highlightedArea: titleLabel, textLocation: .below, text: "This is a demo of the UAWalkthrough pod, which can be used eg to introduce your app to your user."),
            WalkthroughItem(highlightedArea: slider, textLocation: .below, text: "It can be configured to progress automatically and/or require that the user taps the screen to move to the next element. This is by the way a UISlider."),
            WalkthroughItem(highlightedArea: button1, textLocation: .below, text: "If you press this button ... nothing happens."),
            WalkthroughItem(highlightedArea: button2, textLocation: .below, text: "This is another button. Try it. But first we need to finish the walkthrough."),
            WalkthroughItem(highlightedArea: button3, textLocation: .above, text: "Down here there's yet another button, which will do absolutely nothing for you."),
            WalkthroughItem(highlightedArea: button4, textLocation: .above, text: "...and this is the fourth and last button on this screen, and also the end of the onboarding.")
        ]
    }
}
