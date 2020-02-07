//
//  WelcomeViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
  @IBOutlet weak var titleLabel: UILabel!

  override func viewWillAppear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = true

    super.viewWillAppear(animated)
  }

  override func viewWillDisappear(_ animated: Bool) {
    navigationController?.isNavigationBarHidden = false

    super.viewWillDisappear(animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = K.appName
  }
}
