//
//  CustomWalkthroughProviderVC.swift
//  UAWalkthrough_Example
//
//  Created by Marcel Hasselaar on 2019-11-11.
//  Copyright (c) 2019 Marcel Hasselaar. All rights reserved.
//
// This examples shows how to create a walkthrough without having your view controller implement WalkthroughProvider,
// which makes sense in some cases e.g. when you want to be able to show different walkthroughs for the same view controller
//
import UIKit
import UAWalkthrough

class CustomWalkthroughProviderVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!

    private let walkthroughProvider = MyCustomWalkthroughProvider()
    private let walkthroughSettings = WalkthroughSettings(automaticWalkthroughDelaySeconds: 3, preferredBubbleMaxLayoutWidth: 250, presentationMode: .dim())

    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
            self.startWalkthrough(withWalkthroughProvider: self.walkthroughProvider, settings: self.walkthroughSettings, style: BubbleStyle.default, delegate: self)
        }
    }

    @IBAction func restartWalkthrough(_ sender: Any) {
        self.startWalkthrough(withWalkthroughProvider: self.walkthroughProvider, settings: walkthroughSettings, style: BubbleStyle.default)
    }
}

class MyCustomWalkthroughProvider: WalkthroughProvider {
    var walkthroughItems: [WalkthroughItem] = [
        StandaloneItem(content: .plainText("This demonstrates an alternative approach for configuring a walkthrough...")),
        StandaloneItem(content: .plainText("...where you define a WalkthroughProvider that serves the content for the walkthrough...")),
        StandaloneItem(content: .plainText("...which might be useful for example when you want to show different walkthroughs from the same view controller."))
    ]
}

extension CustomWalkthroughProviderVC: WalkthroughDelegate {
    func walkthroughCompleted() {
        self.tabBarController?.selectedIndex = 0
    }
}
