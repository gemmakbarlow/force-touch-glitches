//
//  ViewController.swift
//  force-touch-glitches
//
//  Created by Gemma Barlow on 4/27/16.
//  Copyright © 2016 gemmakbarlow. All rights reserved.
//

import UIKit
import GlitchLabel

class ViewController: UIViewController {

    @IBOutlet weak var glitchingLabel: GlitchLabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    private func animateInOut(animateIn: Bool, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(1.0, delay: 2.0, options: .BeginFromCurrentState, animations: { [weak self] in
            self?.hintLabel.alpha = animateIn ? 1.0 : 0.0
        }) { completed in
            completion?(completed)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

