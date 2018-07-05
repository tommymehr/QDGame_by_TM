//
//  GameViewController.swift
//  QDGame_by_TM
//
//  Created by Tommy on 04.07.18.
//  Copyright © 2018 Tommy. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.bounds.size)
            
            //Scene settings
            
            scene.scaleMode = .aspectFill
            
            //View Settings
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
            
    }
       
}
