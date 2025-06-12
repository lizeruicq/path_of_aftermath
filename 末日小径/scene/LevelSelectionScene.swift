//
//  LevelSelectionScene.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit
import GameplayKit

class LevelSelectionScene: SKScene {

    // 背景图片节点
    private var backgroundNode: SKSpriteNode?

    // 关卡选择面板
    private var levelSelectionPanel: LevelSelectionPanel?

    // 返回按钮
    private var backButton: SKSpriteNode?
    private var backButtonLabel: SKLabelNode?

    // 加载指示器
    private var loadingIndicator: SKNode?
    private var loadingLabel: SKLabelNode?

    // 预加载的纹理
    private var preloadedTextures: [SKTexture] = []

    override func didMove(to view: SKView) {
        setupBackground()
        setupLevelSelectionPanel()
        setupBackButton()
    }

    // 设置背景
    private func setupBackground() {
        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: "level-choose")

        // 创建背景精灵节点
        backgroundNode = SKSpriteNode(texture: texture)

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

            // 调整背景大小以填充整个屏幕
            backgroundNode.size = self.size
            
            // 创建士兵提示面板
            let soldierTipPanel = SoldierTipPanel(size: self.size)
            soldierTipPanel.zPosition = 22
            
            // 将背景添加到场景
            addChild(backgroundNode)
            // 将士兵提示面板添加到场景
            addChild(soldierTipPanel)
        }
    }

    // 设置关卡选择面板
    private func setupLevelSelectionPanel() {
        // 创建关卡选择面板
        levelSelectionPanel = LevelSelectionPanel(size: size)
        levelSelectionPanel?.delegate = self
        levelSelectionPanel?.zPosition = 10

//        // 调试：解锁前几关用于测试
//        LevelProgressManager.shared.unlockFirstFewLevels()

        addChild(levelSelectionPanel!)
    }

    // 设置返回按钮
    private func setupBackButton() {
        // 按钮尺寸和位置
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 50
        let buttonY: CGFloat = 60

        // 创建返回按钮背景
        backButton = SKSpriteNode(color: SKColor.red.withAlphaComponent(0.8), size: CGSize(width: buttonWidth, height: buttonHeight))
        backButton?.position = CGPoint(x: size.width / 2, y: buttonY)
        backButton?.name = "backButton"
        backButton?.zPosition = 20

        // 添加圆角效果
        let cornerRadius: CGFloat = 10
        let roundedBackButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: cornerRadius)
//        roundedBackButton.fillColor = SKColor.red.withAlphaComponent(0.8)
        roundedBackButton.strokeColor = SKColor.white
        roundedBackButton.lineWidth = 2
        roundedBackButton.position = CGPoint(x: size.width / 2, y: buttonY)
        roundedBackButton.name = "backButton"
        roundedBackButton.zPosition = 20

        // 创建返回按钮标签
        backButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        backButtonLabel?.text = "返回主菜单"
        backButtonLabel?.fontSize = 18
        backButtonLabel?.fontColor = SKColor.white
        backButtonLabel?.position = CGPoint(x: 0, y: 0)
        backButtonLabel?.verticalAlignmentMode = .center
        backButtonLabel?.horizontalAlignmentMode = .center
        backButtonLabel?.zPosition = 21

        // 添加到场景
        addChild(roundedBackButton)
        roundedBackButton.addChild(backButtonLabel!)
    }

    // 创建加载指示器
    private func createLoadingIndicator() {
        // 创建加载指示器容器
        let container = SKNode()
        container.position = CGPoint(x: self.size.width - 100, y: 100)
        container.zPosition = 100

        // 创建旋转的圆环
        let circleRadius: CGFloat = 20
        let circle = SKShapeNode(circleOfRadius: circleRadius)
        circle.strokeColor = SKColor.white
        circle.lineWidth = 3
        circle.fillColor = SKColor.clear

        // 创建旋转动画
        let rotateAction = SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0))
        circle.run(rotateAction)

        // 创建加载文本
        let label = SKLabelNode(fontNamed: "Helvetica")
        label.text = "加载中..."
        label.fontSize = 16
        label.fontColor = SKColor.white
        label.position = CGPoint(x: 0, y: -circleRadius - 15)

        // 添加到容器
        container.addChild(circle)
        container.addChild(label)

        // 添加到场景
        addChild(container)

        // 保存引用
        loadingIndicator = container
        loadingLabel = label

        // 默认隐藏
        container.isHidden = true
    }

    // 显示加载指示器
    private func showLoadingIndicator() {
        // 如果加载指示器不存在，创建它
        if loadingIndicator == nil {
            createLoadingIndicator()
        }

        // 显示加载指示器
        loadingIndicator?.isHidden = false
    }

    // 隐藏加载指示器
    private func hideLoadingIndicator() {
        loadingIndicator?.isHidden = true
    }

    // 开始加载游戏场景
    private func startLoadingGameScene(forLevel level: Int) {
        // 显示加载指示器
        showLoadingIndicator()

        // 禁用按钮交互
        isUserInteractionEnabled = false

        // 预加载关卡资源
        preloadLevelResources(forLevel: level) { [weak self] success in
            guard let self = self else { return }

            if success {
                // 创建游戏场景
                let gameScene = GameSceneWithGrid(size: self.size)
                gameScene.scaleMode = .aspectFit

                // 配置对应关卡
                gameScene.configureLevel(level: level)

                // 场景切换动画
                let transition = SKTransition.fade(withDuration: 1.0)

                // 切换到游戏场景
                if let view = self.view {
                    // 隐藏加载指示器
                    self.hideLoadingIndicator()

                    // 切换场景
                    view.presentScene(gameScene, transition: transition)
                }
            } else {
                // 加载失败，重新启用交互
                self.isUserInteractionEnabled = true

                // 隐藏加载指示器
                self.hideLoadingIndicator()

                // 显示错误消息
                self.showErrorMessage("资源加载失败，请重试")
            }
        }
    }

    // 预加载关卡资源
    private func preloadLevelResources(forLevel level: Int, completion: @escaping (Bool) -> Void) {
        // 使用ResourceManager预加载所有资源
        ResourceManager.shared.preloadAllResources { success in
            if success {
                print("ResourceManager成功预加载所有资源")
                // 在主线程上调用完成回调
                DispatchQueue.main.async {
                    completion(true)
                }
            } else {
                print("ResourceManager预加载资源失败")
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }

    // 显示错误消息
    private func showErrorMessage(_ message: String) {
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

    // 处理触摸开始事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果正在加载，忽略触摸事件
        if loadingIndicator != nil && !loadingIndicator!.isHidden {
            return
        }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            // 检查是否点击了返回按钮
            if node.name == "backButton" {
                returnToMainMenu()
                return
            }
        }

        // 将触摸开始事件传递给关卡选择面板
        if let panel = levelSelectionPanel {
            let panelLocation = touch.location(in: panel)
            panel.handleTouchBegan(at: panelLocation)
        }
    }

    // 处理触摸移动事件
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果正在加载，忽略触摸事件
        if loadingIndicator != nil && !loadingIndicator!.isHidden {
            return
        }

        guard let touch = touches.first else { return }

        // 将触摸移动事件传递给关卡选择面板
        if let panel = levelSelectionPanel {
            let panelLocation = touch.location(in: panel)
            panel.handleTouchMoved(to: panelLocation)
        }
    }

    // 处理触摸结束事件
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果正在加载，忽略触摸事件
        if loadingIndicator != nil && !loadingIndicator!.isHidden {
            return
        }

        guard let touch = touches.first else { return }

        // 将触摸结束事件传递给关卡选择面板
        if let panel = levelSelectionPanel {
            let panelLocation = touch.location(in: panel)
            panel.handleTouchEnded(at: panelLocation)
        }
    }

    // 处理触摸取消事件
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 将取消事件当作结束事件处理
        touchesEnded(touches, with: event)
    }

    // 返回主菜单
    private func returnToMainMenu() {
        print("返回主菜单")

        // 创建主菜单场景
        let mainMenuScene = MainMenuScene(size: size)
        mainMenuScene.scaleMode = .aspectFit

        // 场景切换动画
        let transition = SKTransition.fade(withDuration: 1.0)

        // 切换到主菜单场景
        view?.presentScene(mainMenuScene, transition: transition)
    }

    // 刷新关卡按钮状态
    func refreshLevelButtons() {
        levelSelectionPanel?.refreshLevelButtons()
    }
}

// MARK: - LevelSelectionPanelDelegate
extension LevelSelectionScene: LevelSelectionPanelDelegate {

    // 关卡选择面板选择了关卡
    func levelSelectionPanel(_ panel: LevelSelectionPanel, didSelectLevel levelId: Int) {
        print("场景接收到关卡选择: \(levelId)")
        SoundManager.shared.playSoundEffect("touch",in: self)
        startLoadingGameScene(forLevel: levelId)
    }

    // 关卡选择面板请求显示错误消息
    func levelSelectionPanelDidRequestShowError(_ panel: LevelSelectionPanel, message: String) {
        showErrorMessage(message)
    }
}


