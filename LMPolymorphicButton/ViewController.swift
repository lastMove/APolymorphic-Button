//
//  ViewController.swift
//  LMPolymorphicButton
//
//  Created by jason akakpo on 15/05/2015.
//  Copyright (c) 2015 MTT. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonTapped(sender: LMPolymorphicButton)
    {
        sender.toggleActivity();
    }

}

