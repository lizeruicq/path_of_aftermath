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
    
    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            // 检查是否点击了关卡按钮
            if let buttonNode = node as? SKSpriteNode, levelButtons.contains(buttonNode) {
                // 获取按钮索引
                if let index = levelButtons.firstIndex(of: buttonNode) {
                    // 打印调试信息（修正变量引用）
                    print("选择了关卡(\(index) + 1)")
                    
                    // 验证索引有效性
                    guard index >= 0 && index < levelButtons.count else {
                        print("无效的关卡索引: (index)")
                        return
                    }
                    
                    // 创建游戏场景并配置关卡
                    let gameScene = GameSceneWithGrid(size: self.size)
                    gameScene.scaleMode = .aspectFill
                    
                    // 配置对应关卡
                    gameScene.configureLevel(level: index + 1)
                    
                    // 场景切换动画
                    let transition = SKTransition.fade(withDuration: 1.0)
                    
                    // 切换到游戏场景
                    if let view = self.view {
                        view.presentScene(gameScene, transition: transition)
                    }
                }
            }
        }
    }
}
