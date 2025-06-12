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
    
    // 重置进度按钮
    private var resetButton: SKSpriteNode?
    private var resetButtonLabel: SKLabelNode?

    // 设置按钮
    private var settingsButton: SKSpriteNode?
    private var settingsButtonLabel: SKLabelNode?
    
    // 确认面板
    private var confirmationPanel: ConfirmationPanel?

    override func didMove(to view: SKView) {
        SoundManager.shared.playBackgroundMusic()
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
            // backgroundNode.size = self.size

            let scale = max(self.size.width / backgroundNode.size.width,
                self.size.height / backgroundNode.size.height)
           backgroundNode.setScale(scale)

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
        startButton = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 50))
//        startButton = SKSpriteNode(texture: ResourceManager.shared.buttonimg, size: CGSize(width: 200, height: 50))
        startButton?.alpha = 0.8
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
            startButtonLabel.zPosition = 11

            startButton.addChild(startButtonLabel)
            addChild(startButton)
        }
        
        // 创建重置进度按钮
        resetButton = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 50))
        resetButton?.alpha = 0.8
        resetButtonLabel = SKLabelNode(fontNamed: "Helvetica")

        if let resetButton = resetButton, let resetButtonLabel = resetButtonLabel {
            resetButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.2) // 在开始按钮下方增加间距
            resetButton.name = "resetButton"
            resetButton.zPosition = 10

            resetButtonLabel.text = "重置进度"
            resetButtonLabel.fontSize = 20
            resetButtonLabel.fontColor = SKColor.white
            resetButtonLabel.verticalAlignmentMode = .center
            resetButtonLabel.horizontalAlignmentMode = .center
            resetButtonLabel.position = CGPoint.zero
            resetButtonLabel.zPosition = 11

            resetButton.addChild(resetButtonLabel)
            addChild(resetButton)
        }

        // 创建设置按钮
        settingsButton = SKSpriteNode(color: .clear, size: CGSize(width: 200, height: 50))
                settingsButton?.alpha = 0.8
        settingsButtonLabel = SKLabelNode(fontNamed: "Helvetica")

        if let settingsButton = settingsButton, let settingsButtonLabel = settingsButtonLabel {
            settingsButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.3)
            settingsButton.name = "settingsButton"
            settingsButton.zPosition = 10

            // 根据 SoundManager 的状态设置初始文本
            settingsButtonLabel.text = SoundManager.shared.isSoundEnabled ? "音效：开" : "音效：关"
            settingsButtonLabel.fontSize = 20
            settingsButtonLabel.fontColor = SKColor.white
            settingsButtonLabel.verticalAlignmentMode = .center
            settingsButtonLabel.horizontalAlignmentMode = .center
            settingsButtonLabel.position = CGPoint.zero
            settingsButtonLabel.zPosition=11
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
            if node.name == "startButton" 
            // || node.parent?.name == "startButton"
             {

                SoundManager.shared.playSoundEffect("touch",in: self)
                SoundManager.shared.resetCooldownTimer()
                startGame()
            } else if node.name == "resetButton"
            // || node.parent?.name == "resetButton" 
            {
                showConfirmationPanel()
                SoundManager.shared.playSoundEffect("touch",in: self)
                
            }
             else if node.name == "settingsButton" 
            //  || node.parent?.name == "settingsButton"
              {
                 
                // 切换音效状态
                SoundManager.shared.toggleSound()
                 SoundManager.shared.playSoundEffect("touch",in: self)
                
                // 更新按钮文字
                if let label = settingsButtonLabel {
                    label.text = SoundManager.shared.isSoundEnabled ? "音效：开" : "音效：关"
                }
            }
            
            
        }
    }
    
    // 处理触摸结束事件
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // 如果确认面板存在，将触摸事件传递给它
        if let confirmationPanel = confirmationPanel {
            // 将触摸位置转换为面板坐标系
            let panelLocation = touch.location(in: confirmationPanel)
            confirmationPanel.handleTouchBegan(at: panelLocation)
            confirmationPanel.handleTouchEnded(at: panelLocation)
        }
    }
    
    // 显示确认面板
    private func showConfirmationPanel() {
        // 如果已经显示，不重复创建
        if confirmationPanel != nil {
            return
        }
        
        // 创建确认面板
        confirmationPanel = ConfirmationPanel(size: self.size)
        confirmationPanel?.delegate = self
        confirmationPanel?.zPosition = 1000 // 确保在所有元素之上
        
        // 添加到场景
        if let confirmationPanel = confirmationPanel {
            addChild(confirmationPanel)
        }
    }
    
    // 隐藏确认面板
    private func hideConfirmationPanel() {
        confirmationPanel?.removeFromParent()
        confirmationPanel = nil
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
    
    // 重置进度
    private func resetProgress() {
        // 调用关卡进度管理器重置进度
        LevelProgressManager.shared.resetProgress()
        
        // 可以添加提示信息
        showMessage("进度已重置")
    }

    // 打开设置
    private func openSettings() {
        // 这里可以实现设置功能，目前只是一个占位
        print("打开设置")
    }
    
    private func showMessage(_ message: String) {
        // 创建错误消息标签
        let errorLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        errorLabel.text = message
        errorLabel.fontSize = 24
        errorLabel.fontColor = SKColor.red
        errorLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        errorLabel.zPosition = 100

        // 添加到场景
        addChild(errorLabel)

        // 创建淡出动作
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        // 运行动作序列
        errorLabel.alpha = 0
        errorLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
}




// MARK: - ConfirmationPanelDelegate
extension MainMenuScene: ConfirmationPanelDelegate {
    func confirmationPanelDidConfirm(_ panel: ConfirmationPanel) {
        // 用户点击"是"，执行重置操作
        resetProgress()
        
        // 隐藏确认面板
        hideConfirmationPanel()
    }
    
    func confirmationPanelDidCancel(_ panel: ConfirmationPanel) {
        // 用户点击"否"，取消操作
        // 不执行任何操作，仅隐藏面板
        hideConfirmationPanel()
    }
}
