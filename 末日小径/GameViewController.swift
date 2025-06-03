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

            // 预加载所有资源
            ResourceManager.shared.preloadAllResources { success in
                if success {
                    print("应用启动时预加载所有资源成功")

                    // 在主线程上创建并显示主菜单场景
                    DispatchQueue.main.async {
                        let mainMenuScene = MainMenuScene(size: view.bounds.size)
                        mainMenuScene.scaleMode = .aspectFit
                        // 显示主菜单场景
                        view.presentScene(mainMenuScene)
                    }
                } else {
                    print("应用启动时预加载资源失败")

                    // 即使预加载失败，也显示主菜单场景
                    DispatchQueue.main.async {
                        let mainMenuScene = MainMenuScene(size: view.bounds.size)
                        mainMenuScene.scaleMode = .aspectFit
                        // 显示主菜单场景
                        view.presentScene(mainMenuScene)
                    }
                }
            }

            // // 尝试从.sks文件加载GameScene（用于测试roade节点）
            // if let scene = SKScene(fileNamed: "GameScene") {
            //     scene.scaleMode = .aspectFill
            //     view.presentScene(scene)
            //     print("成功从GameScene.sks加载场景")
            // } else {
            //     print("无法从GameScene.sks加载场景，使用MainMenuScene代替")
            //     // 创建主菜单场景
            //     let mainMenuScene = MainMenuScene(size: view.bounds.size)
            //     mainMenuScene.scaleMode = .aspectFill
            //     // 显示主菜单场景
            //     view.presentScene(mainMenuScene)
            // }
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
