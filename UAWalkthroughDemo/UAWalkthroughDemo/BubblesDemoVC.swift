//
//  ViewController.swift
//  UAWalkthrough
//
//  Created by marhas on 02/13/2018.
//  Copyright (c) 2020 Marcel Hasselaar. All rights reserved.
//

import UIKit
import UAWalkthrough

class BubblesDemoVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    private var walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3, preferredBubbleMaxLayoutWidth: 300, presentationMode: .none)
    private var walkthroughStyle = BubbleStyle.white
    private var bubblesToRemoveAtEnd = [Bubble]()

    override func viewDidAppear(_ animated: Bool) {

        // MARK: - Simplest case to show a highlighting bubble using all default values
        showBubble(withBubbleItem: HighlightedBubbleItem(highlightedArea: button1, content: .plainText("This is a default highlighting bubble pointing to button 1.")), forSeconds: 10)

        // MARK: - Custom standalone button positioned relative to center
        let bubbleStyle2 = BubbleStyle(textColor: .white, backgroundColor: .orange, shadowStyle: .dark, cornerRadius: 20, yOffsetToHighlightedArea: 0)
        let bubbleItem2 = StandaloneBubbleItem(content: .plainText("This standalone bubble has been positioned with an offset relative the center instead of pointing to a specific view."), centerOffset: CGPoint(x: -40, y: 90))
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let bubble2 = self.showBubble(withBubbleItem: bubbleItem2, style: bubbleStyle2, minBubbleHorizontalMargin: 20, preferredBubbleMaxLayoutWidth: 200)
            self.bubblesToRemoveAtEnd.append(bubble2)
        }

        // MARK: - Custom standalone button positioned with a layout handler and automatically removed after 5 seconds
        let bubbleStyle3 = BubbleStyle(textColor: .white, backgroundColor: .systemTeal)
        let bubbleItem3 = StandaloneBubbleItem(content: .plainText("This standalone bubble has been positioned with a layout handler, which provides the most flexibility."), layoutHandler: { (bubble) -> [NSLayoutConstraint]? in
            return [
                bubble.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                bubble.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -100)
            ]
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            let bubble3 = self.showBubble(withBubbleItem: bubbleItem3, style: bubbleStyle3)
            self.bubblesToRemoveAtEnd.append(bubble3)
        }

        // MARK: - Highlighted bubble with automatic removal and completion handler
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.showBubble(withBubbleItem: HighlightedBubbleItem(highlightedArea: self.button2, content: .plainText("You can also configure the bubbles to only show for a certain period, like this one that will be visible for 3 seconds.")), forSeconds: 3) {
                print("Bubble 4 finished showing")
            }
        }

        // MARK: - Standalone bubble that will transition the tab bar to the next screen in its completion handler
        DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
            self.showBubble(withBubbleItem: StandaloneBubbleItem(content: .plainText("This bubble will be shown for 6 seconds and then it will switch to the next screen.")), forSeconds: 6) {
                // Before jumping to the next screen, we remove the bubbles that haven't been configured to show for a limited time.
                self.bubblesToRemoveAtEnd.forEach { $0.remove() }
                self.tabBarController?.selectedIndex = 3
            }
        }
    }
}
