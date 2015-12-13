//
//  ViewController.swift
//  LMPolymorphicButton
//
//  Created by jason akakpo on 15/05/2015.
//  Copyright (c) 2015 MTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func buttonTapped(sender: LMPolymorphicButton) {
        sender.toggleActivity()
    }
}

