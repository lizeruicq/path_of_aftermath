//
//  GameViewController.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/2.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 设置视图属性
        if let view = self.view as! SKView? {
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true

            // 创建主菜单场景
            let mainMenuScene = MainMenuScene(size: view.bounds.size)
            mainMenuScene.scaleMode = .aspectFill

            // 显示主菜单场景
            view.presentScene(mainMenuScene)
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
