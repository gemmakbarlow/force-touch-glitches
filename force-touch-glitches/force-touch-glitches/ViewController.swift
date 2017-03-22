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
    case show = 1.0
    case hide = 0.0
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

    fileprivate let AnimationDuration = 1.0
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let hide = Alpha.hide.rawValue
        hintLabel.alpha = hide
        thumb.alpha = hide
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        forceTouchStarted = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func beginForceTouchMessaging(_ finale: ((Bool) -> Void)?) {
        animateInOutWithText(HoldDownForFiveSeconds) { [weak self] completed in
            guard completed else { return }
            self?.animateInOutWithText(AlmostThere) { [weak self] completed in
                guard completed else { return }
                self?.animateInOutWithText(Hypnotic, completion: finale)
            }
        }
    }

    
    fileprivate func endForceTouchMessaging() {
        animateInOut(hintLabel, animateIn: false) { [weak self] completed in
            guard completed else { return }
            self?.hintLabel.text = ""
        }
    }
    
    fileprivate func animateInOutWithText(_ text: String, completion: ((Bool) -> Void)?) {
        hintLabel.text = text
        animateInOut(hintLabel, animateIn: true) { [weak self] completed in
            if completed {
                guard let l = self?.hintLabel else { return }
                self?.animateInOut(l, animateIn: false, completion: completion)
            }
        }
    }
    
    // MARK: - Animation
    
    fileprivate func animateInOut(_ viewToAnimate: UIView, animateIn: Bool, completion: ((Bool) -> Void)?) {
        UIView.animate(withDuration: AnimationDuration, delay: 2.0, options: .beginFromCurrentState, animations: {
            let alpha: Alpha = animateIn ? .show : .hide
            viewToAnimate.alpha = alpha.rawValue
        }) { completed in
            completion?(completed)
        }
    }

    fileprivate func setupForceTouchGestureRecognizer() {
        let forceTouch = DFContinuousForceTouchGestureRecognizer()
        forceTouch.forceTouchDelegate = self
        target.addGestureRecognizer(forceTouch)
    }

    
    fileprivate func setupSeeYouThereImage() {
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
    
    static func random(_ maximum: Int) -> Int {
        return Int(arc4random_uniform(UInt32(maximum)))
    }
    
}

// MARK: - Delays

/**
 Convenience method that allows actions to be delayed.
 
 - parameter delay:   Double describing how many seconds the action should be delayed for.
 - parameter closure: Action code to launch post-delay
 */
func delay(_ delay: Double, closure: @escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC)
            )) / Double(NSEC_PER_SEC), execute: closure)
}

extension ViewController: DFContinuousForceTouchDelegate {
  
    func forceTouchRecognized(_ recognizer: DFContinuousForceTouchGestureRecognizer) {
        handleForceTouchStart()
    }

    func forceTouch(_ recognizer: DFContinuousForceTouchGestureRecognizer!, didCancelWithForce force: CGFloat, maxForce: CGFloat) {
        handleForceTouchEnd()
    }

    func forceTouch(_ recognizer: DFContinuousForceTouchGestureRecognizer!, didEndWithForce force: CGFloat, maxForce: CGFloat) {
        handleForceTouchEnd()
    }
    
    
    fileprivate func handleForceTouchStart() {
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
    
    fileprivate func handleForceTouchEnd() {
        forceTouchStarted = false
        endForceTouchMessaging()
        endGlitching()
    }
    
    fileprivate func beginGlitching() {
        vibrate()
        glitchingLabel.glitchEnabled = true

    }
    
    fileprivate func endGlitching() {
        glitchingLabel.glitchEnabled = false
    }
    
    fileprivate func hideAllViews() {
        let hide = Alpha.hide.rawValue
        glitchingLabel.alpha = hide
        hintLabel.alpha = hide
        thumb.alpha = hide
        target.isUserInteractionEnabled = false
    }
    
    fileprivate func showSeeYouThereViews() {
        let show = Alpha.show.rawValue
        seeYouThere.alpha = show
        hintLabel.text = SeeYouInJune
        hintLabel.alpha = show
    }
}

