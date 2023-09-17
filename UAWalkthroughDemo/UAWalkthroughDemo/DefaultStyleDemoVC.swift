//
//  DefaultStyleDemoVC.swift
//  UAWalkthrough_Example
//
//  Created by Marcel Hasselaar on 2019-10-22.
//  Copyright © 2019 Marcel Hasselaar. All rights reserved.
//

import UIKit
import UAWalkthrough

class DefaultStyleDemoVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

//    private let walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3, preferredBubbleMaxLayoutWidth: 300, presentationMode: .dim())
    private let walkthroughSettings = WalkthroughSettings(presentationMode: .dim())
    private let bubbleStyle = BubbleStyle.default

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.startWalkthrough(withSettings: self.walkthroughSettings, style: self.bubbleStyle, delegate: self, showEvenIfItHasAlreadyBeenCompleted: true)
        }
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        self.startWalkthrough(withSettings: walkthroughSettings, style: bubbleStyle)
    }
}

extension DefaultStyleDemoVC: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] {
        let attributedString = NSMutableAttributedString(string: "You can also use attributed strings. ", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .regular)])
        attributedString.append(NSAttributedString(string: "For example some bold text.", attributes: [.font: UIFont.systemFont(ofSize: 17, weight: .bold)]))

        return [
            StandaloneItem(content: .plainText("The background can be dimmed and views highlighted for extra focus."), layoutHandler: { [weak self] bubble in
                guard let self = self else { return nil }
                return [
                    bubble.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                    bubble.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 90)
                ]
            }),
            HighlightedItem(highlightedArea: button4, textLocation: .above, content: .plainText("Views can be walked through in any order. This is button 4.")),
            HighlightedItem(highlightedArea: slider, textLocation: .below, content: .plainText("There are a few preconfigured appearances but there's plenty of opportunity to configure it to your liking. (Here's the slider again)")),
            HighlightedItem(highlightedArea: button1, textLocation: .below, content: .plainText("Here's another button.")),
            HighlightedItem(highlightedArea: button2, textLocation: .below, content: .plainText("This is yet another button. As long as the walkthrough runs the regular UI of the app is disabled. Tap the background to progress the walkthrough.")),
            HighlightedItem(highlightedArea: button3, textLocation: .above, content: .attributedText(attributedString)),
            StandaloneItem(content: .plainText("This example uses a delegate to automatically switch tab when the walkthrough completes."), centerOffset: CGPoint(x: 0, y: -120)),
        ]
    }
}

extension DefaultStyleDemoVC: WalkthroughDelegate {
    func walkthroughCompleted() {
        self.tabBarController?.selectedIndex = 2
    }
}
