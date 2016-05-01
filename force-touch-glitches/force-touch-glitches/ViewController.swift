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

enum Alpha: CGFloat {
    case Show = 1.0
    case Hide = 0.0
}

private let Luke = NSLocalizedString("Luke", comment: "Name to choose between, introductory text.")
private let Leia = NSLocalizedString("Leia", comment: "Name to choose between, introductory text.")
private let Chewy = NSLocalizedString("Chewy", comment: "Name to choose between, introductory text.")

private let UseTheForceFormat = NSLocalizedString("use the force (touch) %@", comment: "First line of text to display")
private let HoldDownForFiveSeconds = NSLocalizedString("hold for a while", comment: "Second line of text to display")
private let AlmostThere = NSLocalizedString("almost there", comment: "Third line of text to display")
private let Hypnotic = NSLocalizedString("hypnotic, isn't it?", comment: "Fourth line of text to display")

private let SeeYouInJune = NSLocalizedString("See you in June?", comment: "Final display text")

class ViewController: UIViewController {

    private let AnimationDuration = 1.0
    var forceTouchStarted = false
    
    @IBOutlet weak var glitchingLabel: GlitchLabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var target: UIView!
    @IBOutlet weak var thumb: UIImageView!
    @IBOutlet weak var seeYouThere: UIImageView!
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupForceTouchGestureRecognizer()
        glitchingLabel.glitchEnabled = false
        setupSeeYouThereImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let hide = Alpha.Hide.rawValue
        hintLabel.alpha = hide
        thumb.alpha = hide
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // GB - animate text in & out
        guard !forceTouchStarted else { return }
        
        // GB - pick a name to use
        let names = [Luke, Leia, Chewy]
        let randomIndex = Int.random(names.count - 1)
        let text = String(format: UseTheForceFormat, names[randomIndex])
        
        animateInOutWithText(text)  { [weak self] completed in
            guard completed else { return }
            guard let t = self?.thumb else { return }
            self?.animateInOut(t, animateIn: true, completion: nil)
        }
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
        animateInOut(hintLabel, animateIn: false) { [weak self] completed in
            guard completed else { return }
            self?.hintLabel.text = ""
        }
    }
    
    private func animateInOutWithText(text: String, completion: ((Bool) -> Void)?) {
        hintLabel.text = text
        animateInOut(hintLabel, animateIn: true) { [weak self] completed in
            if completed {
                guard let l = self?.hintLabel else { return }
                self?.animateInOut(l, animateIn: false, completion: completion)
            }
        }
    }
    
    // MARK: - Animation
    
    private func animateInOut(viewToAnimate: UIView, animateIn: Bool, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(AnimationDuration, delay: 2.0, options: .BeginFromCurrentState, animations: {
            let alpha: Alpha = animateIn ? .Show : .Hide
            viewToAnimate.alpha = alpha.rawValue
        }) { completed in
            completion?(completed)
        }
    }

    private func setupForceTouchGestureRecognizer() {
        let forceTouch = DFContinuousForceTouchGestureRecognizer()
        forceTouch.forceTouchDelegate = self
        target.addGestureRecognizer(forceTouch)
    }

    
    private func setupSeeYouThereImage() {
        seeYouThere.layer.masksToBounds = true
        seeYouThere.layer.cornerRadius = 10.0
    }
}



// MARK: - Vibration

func vibrate() {
    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
}

// MARK: - Random Numbers

extension Int {
    
    static func random(maximum: Int) -> Int {
        return Int(arc4random_uniform(UInt32(maximum)))
    }
    
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
                self?.showSeeYouThereViews()
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
        let hide = Alpha.Hide.rawValue
        glitchingLabel.alpha = hide
        hintLabel.alpha = hide
        thumb.alpha = hide
        target.userInteractionEnabled = false
    }
    
    private func showSeeYouThereViews() {
        let show = Alpha.Show.rawValue
        seeYouThere.alpha = show
        hintLabel.text = SeeYouInJune
        hintLabel.alpha = show
    }
}

