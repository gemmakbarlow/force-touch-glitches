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

private let UseTheForce = NSLocalizedString("use the force (touch) Luke", comment: "First line of text to display")
private let HoldDownForFiveSeconds = NSLocalizedString("hold for a while", comment: "Second line of text to display")
private let AlmostThere = NSLocalizedString("almost there", comment: "Third line of text to display")
private let Hypnotic = NSLocalizedString("hypnotic, isn't it?", comment: "Fourth line of text to display")

class ViewController: UIViewController {

    private let AnimationDuration = 1.0
    var forceTouchStarted = false
    
    @IBOutlet weak var glitchingLabel: GlitchLabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var target: UIView!
    @IBOutlet weak var thumb: UIImageView!
    
    // MARK: - View Lifecycle
    
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
        
        // GB - animate text in & out
        guard !forceTouchStarted else { return }
        
        animateInOutWithText(UseTheForce, completion: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        forceTouchStarted = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func beginForceTouchMessaging(finale: ((Bool) -> Void)?) {
        animateInOutWithText(HoldDownForFiveSeconds) { [weak self] completed in
            guard completed else { return }
            self?.animateInOutWithText(AlmostThere) { [weak self] completed in
                guard completed else { return }
                self?.animateInOutWithText(Hypnotic, completion: finale)
            }
        }
    }

    
    private func endForceTouchMessaging() {
        animateInOut(false) { [weak self] completed in
            guard completed else { return }
            self?.hintLabel.text = ""
        }
    }
    
    private func animateInOutWithText(text: String, completion: ((Bool) -> Void)?) {
        hintLabel.text = text
        animateInOut(true) { [weak self] completed in
            if completed {
                self?.animateInOut(false, completion: completion)
            }
        }
    }
    
    // MARK: - Animation
    
    private func animateInOut(animateIn: Bool, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(AnimationDuration, delay: 2.0, options: .BeginFromCurrentState, animations: { [weak self] in
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



// MARK: - Vibration

func vibrate() {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}


// MARK: - Delays

/**
 Convenience method that allows actions to be delayed.
 
 - parameter delay:   Double describing how many seconds the action should be delayed for.
 - parameter closure: Action code to launch post-delay
 */
func delay(delay: Double, closure: ()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC)
            )
        ),
        dispatch_get_main_queue(), closure)
}

extension ViewController: DFContinuousForceTouchDelegate {
  
    func forceTouchRecognized(recognizer: DFContinuousForceTouchGestureRecognizer) {
        handleForceTouchStart()
    }

    func forceTouchRecognizer(recognizer: DFContinuousForceTouchGestureRecognizer!, didCancelWithForce force: CGFloat, maxForce: CGFloat) {
        handleForceTouchEnd()
    }

    func forceTouchRecognizer(recognizer: DFContinuousForceTouchGestureRecognizer!, didEndWithForce force: CGFloat, maxForce: CGFloat) {
        handleForceTouchEnd()
    }
    
    
    private func handleForceTouchStart() {
        forceTouchStarted = true
        beginGlitching()
        beginForceTouchMessaging { [weak self] finale in
            guard finale else { return }
            
            vibrate()
            
            delay(1.0) {
                vibrate()
            }
            delay(2.0) {
                vibrate()
            }
            delay(3.0) {
                self?.hideAllViews()
            }
        }
    }
    
    private func handleForceTouchEnd() {
        forceTouchStarted = false
        endForceTouchMessaging()
        endGlitching()
    }
    
    private func beginGlitching() {
        vibrate()
        glitchingLabel.glitchEnabled = true

    }
    
    private func endGlitching() {
        glitchingLabel.glitchEnabled = false
    }
    
    private func hideAllViews() {
        glitchingLabel.alpha = 0.0
        hintLabel.alpha = 0.0
        thumb.alpha = 0.0
        target.userInteractionEnabled = false
    }
}

