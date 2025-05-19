//
//  MainMenuScene.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {

    // 背景图片节点
    private var backgroundNode: SKSpriteNode?

    // 游戏标题标签
    private var titleLabel: SKLabelNode?

    // 开始游戏按钮
    private var startButton: SKSpriteNode?
    private var startButtonLabel: SKLabelNode?

    // 设置按钮
    private var settingsButton: SKSpriteNode?
    private var settingsButtonLabel: SKLabelNode?

    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupButtons()
    }

    // 设置背景
    private func setupBackground() {
        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: "background")

        // 创建背景精灵节点
        backgroundNode = SKSpriteNode(texture: texture)

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

            // 调整背景大小以填充整个屏幕
            backgroundNode.size = self.size

            // 将背景添加到场景
            addChild(backgroundNode)
        }
    }

    // 设置游戏标题
    private func setupTitle() {
        titleLabel = SKLabelNode(fontNamed: "Chalkduster")

        if let titleLabel = titleLabel {
            titleLabel.text = "末日小径"
            titleLabel.fontSize = 50
            titleLabel.fontColor = SKColor.white
            titleLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.7)
            titleLabel.zPosition = 10  // 确保标题在背景之上


            addChild(titleLabel)
        }
    }

    // 设置按钮
    private func setupButtons() {
        // 创建开始游戏按钮
        startButton = SKSpriteNode(color: SKColor.darkGray.withAlphaComponent(0.7), size: CGSize(width: 200, height: 50))
        startButtonLabel = SKLabelNode(fontNamed: "Helvetica")

        if let startButton = startButton, let startButtonLabel = startButtonLabel {
            startButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.4)
            startButton.name = "startButton"
            startButton.zPosition = 10

            startButtonLabel.text = "开始游戏"
            startButtonLabel.fontSize = 20
            startButtonLabel.fontColor = SKColor.white
            startButtonLabel.verticalAlignmentMode = .center
            startButtonLabel.horizontalAlignmentMode = .center
            startButtonLabel.position = CGPoint.zero

            startButton.addChild(startButtonLabel)
            addChild(startButton)
        }

        // 创建设置按钮
        settingsButton = SKSpriteNode(color: SKColor.darkGray.withAlphaComponent(0.7), size: CGSize(width: 200, height: 50))
        settingsButtonLabel = SKLabelNode(fontNamed: "Helvetica")

        if let settingsButton = settingsButton, let settingsButtonLabel = settingsButtonLabel {
            settingsButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
            settingsButton.name = "settingsButton"
            settingsButton.zPosition = 10

            settingsButtonLabel.text = "设置"
            settingsButtonLabel.fontSize = 20
            settingsButtonLabel.fontColor = SKColor.white
            settingsButtonLabel.verticalAlignmentMode = .center
            settingsButtonLabel.horizontalAlignmentMode = .center
            settingsButtonLabel.position = CGPoint.zero

            settingsButton.addChild(settingsButtonLabel)
            addChild(settingsButton)
        }
    }

    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            if node.name == "startButton" || node.parent?.name == "startButton" {
                startGame()
            } else if node.name == "settingsButton" || node.parent?.name == "settingsButton" {
                openSettings()
            }
        }
    }

    // 开始游戏
    private func startGame() {
        // 创建关卡选择场景实例
        let levelSelectionScene = LevelSelectionScene(size: self.size)
        levelSelectionScene.scaleMode = .aspectFill

        // 场景切换动画
        let transition = SKTransition.fade(withDuration: 1.0)

        // 切换到关卡选择场景
        if let view = self.view {
            view.presentScene(levelSelectionScene, transition: transition)
        }
    }

    // 打开设置
    private func openSettings() {
        // 这里可以实现设置功能，目前只是一个占位
        print("打开设置")
    }
}