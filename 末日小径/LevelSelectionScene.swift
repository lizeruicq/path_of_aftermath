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

    // 关卡按钮
    private var levelButtons: [SKSpriteNode] = []
    private var levelButtonLabels: [SKLabelNode] = []

    // 加载指示器
    private var loadingIndicator: SKNode?
    private var loadingLabel: SKLabelNode?

    // 预加载的纹理
    private var preloadedTextures: [SKTexture] = []

    override func didMove(to view: SKView) {
        setupBackground()
        setupLevelButtons()
    }

    // 设置背景
    private func setupBackground() {
        // 创建背景精灵节点，使用"level-choose"图片（需要添加到Assets.xcassets中）
        backgroundNode = SKSpriteNode(imageNamed: "level-choose")

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

            // 调整背景大小以填充整个屏幕
            backgroundNode.size = self.size

            // 将背景添加到场景
            addChild(backgroundNode)
        }
    }

    // 设置关卡按钮
    private func setupLevelButtons() {
        // 关卡名称数组
        let levelNames = ["关卡1", "关卡2", "关卡3","关卡4"]

        // 按钮样式参数
        let buttonSize = CGSize(width: 150, height: 50)
        let buttonColor = SKColor.darkGray.withAlphaComponent(0.7)
        let fontName = "Helvetica"
        let fontSize: CGFloat = 20
        let fontColor = SKColor.white

        // 计算按钮总高度和间距
        let totalButtonsHeight: CGFloat = CGFloat(levelNames.count) * buttonSize.height
        let spacing: CGFloat = 40
        let totalHeight = totalButtonsHeight + spacing * CGFloat(levelNames.count - 1)

        // 计算起始Y坐标
        let startY = (self.size.height + totalHeight) / 2 - buttonSize.height / 2

        for (index, levelName) in levelNames.enumerated() {
            // 创建按钮节点
            let button = SKSpriteNode(color: buttonColor, size: buttonSize)
            button.name = "level(\(index) + 1)Button"
            button.zPosition = 10

            // 计算按钮位置
            let yPosition = startY - CGFloat(index) * (buttonSize.height + spacing)
            button.position = CGPoint(x: self.size.width / 2, y: yPosition)

            // 创建按钮标签
            let label = SKLabelNode(fontNamed: fontName)
            label.text = levelName
            label.fontSize = fontSize
            label.fontColor = fontColor
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.position = CGPoint.zero

            // 添加标签到按钮
            button.addChild(label)

            // 添加按钮到场景
            addChild(button)

            // 保存按钮和标签引用
            levelButtons.append(button)
            levelButtonLabels.append(label)
        }
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
                gameScene.scaleMode = .aspectFill

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
        // 清空之前预加载的纹理
        preloadedTextures.removeAll()

        // 需要预加载的纹理名称
        var textureNames: [String] = []

        // 添加关卡背景
        textureNames.append("level-\(level)")

        // 添加僵尸纹理
        for i in 1...7 {
            textureNames.append("walker_move_\(i)")
        }

        // 添加炮塔纹理
        textureNames.append("rifle_idle")
        for i in 1...3 {
            textureNames.append("rifle_shoot_\(i)")
        }
        textureNames.append("shotgun_idle")
        // 创建纹理数组
        let textures = textureNames.map { SKTexture(imageNamed: $0) }
        preloadedTextures = textures

        // 预加载所有纹理
        SKTexture.preload(textures) {
            // 在主线程上调用完成回调
            DispatchQueue.main.async {
                completion(true)
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

    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 如果正在加载，忽略触摸事件
        if loadingIndicator != nil && !loadingIndicator!.isHidden {
            return
        }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)

        for node in touchedNodes {
            // 检查是否点击了关卡按钮
            if let buttonNode = node as? SKSpriteNode, levelButtons.contains(buttonNode) {
                // 获取按钮索引
                if let index = levelButtons.firstIndex(of: buttonNode) {
                    // 打印调试信息（修正变量引用）
                    print("选择了关卡\(index + 1)")

                    // 验证索引有效性
                    guard index >= 0 && index < levelButtons.count else {
                        print("无效的关卡索引: \(index)")
                        return
                    }
                    // // 1. 先尝试用 fileNamed: 加载，并向下转型到 GameScene
                    // if let gameScene = SKScene(fileNamed: "GameScene") as? GameScene {
                    //     // 2. 现在 gameScene 是非可选的 GameScene 可以安全使用
                    //     gameScene.scaleMode = .aspectFill
                    //     gameScene.configureLevel(level: index + 1)

                    //     // 3. 创建过渡动画并呈现
                    //     let transition = SKTransition.fade(withDuration: 1.0)
                    //     self.view?.presentScene(gameScene, transition: transition)
                    // } else {
                    //     // 加载失败时的容错处理
                    //     print("⚠️ 无法加载 GameScene.sks 或类型转换失败")
                    // }

                    // 开始加载游戏场景
                    startLoadingGameScene(forLevel: index + 1)
                }
            }
        }
    }
}
