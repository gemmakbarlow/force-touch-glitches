//
//  ViewController.swift
//  force-touch-glitches
//
//  Created by Gemma Barlow on 4/27/16.
//  Copyright © 2016 gemmakbarlow. All rights reserved.
//

import UIKit
import GlitchLabel
import DFContinuousForceTouchGestureRecognizer
import AudioToolbox.AudioServices

class ViewController: UIViewController {

    @IBOutlet weak var glitchingLabel: GlitchLabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var target: UIView!
    
    // MARK: - Memory Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForceTouchGestureRecognizer()
        glitchingLabel.glitchEnabled = false
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        hintLabel.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        animateInOut(true) { [weak self] completed in
            if completed {
                self?.animateInOut(false, completion: nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Animation
    
    private func animateInOut(animateIn: Bool, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(1.0, delay: 2.0, options: .BeginFromCurrentState, animations: { [weak self] in
            self?.hintLabel.alpha = animateIn ? 1.0 : 0.0
        }) { completed in
            completion?(completed)
        }
    }

    private func setupForceTouchGestureRecognizer() {
        let forceTouch = DFContinuousForceTouchGestureRecognizer()
        forceTouch.forceTouchDelegate = self
        target.addGestureRecognizer(forceTouch)
    }

}


func vibrate() {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

extension ViewController: DFContinuousForceTouchDelegate {
    
    func forceTouchRecognized(recognizer: DFContinuousForceTouchGestureRecognizer) {
        beginGlitching()
    }

    func forceTouchRecognizer(recognizer: DFContinuousForceTouchGestureRecognizer!, didCancelWithForce force: CGFloat, maxForce: CGFloat) {
        endGlitching()
    }

    func forceTouchRecognizer(recognizer: DFContinuousForceTouchGestureRecognizer!, didEndWithForce force: CGFloat, maxForce: CGFloat) {
        endGlitching()
    }
    
    
    private func beginGlitching() {
        vibrate()
        glitchingLabel.glitchEnabled = true

    }
    
    private func endGlitching() {
        glitchingLabel.glitchEnabled = false
    }
}

