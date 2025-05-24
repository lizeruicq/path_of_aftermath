//
//  PausePanel.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

// 暂停面板代理协议
protocol PausePanelDelegate: AnyObject {
    func pausePanelDidRequestContinue()
    func pausePanelDidRequestExit()
}

class PausePanel: SKNode {
    
    // 代理
    weak var delegate: PausePanelDelegate?
    
    // UI元素
    private var backgroundOverlay: SKSpriteNode!
    private var panelBackground: SKSpriteNode!
    private var continueButton: SKSpriteNode!
    private var exitButton: SKSpriteNode!
    private var continueLabel: SKLabelNode!
    private var exitLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    
    // 面板尺寸
    private let panelWidth: CGFloat
    private let panelHeight: CGFloat
    
    // 是否正在显示
    private(set) var isShowing: Bool = false
    
    // 初始化
    init(sceneSize: CGSize) {
        // 计算面板尺寸 (16:9比例，占屏幕高度的1/3)
        panelHeight = sceneSize.height / 3
        panelWidth = panelHeight * 16 / 9
        
        super.init()
        
        setupPanel(sceneSize: sceneSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置面板
    private func setupPanel(sceneSize: CGSize) {
        // 创建半透明背景覆盖层
        backgroundOverlay = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.5), size: sceneSize)
        backgroundOverlay.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        backgroundOverlay.zPosition = 100
        backgroundOverlay.name = "pauseOverlay"
        addChild(backgroundOverlay)
        
        // 创建面板背景
        panelBackground = SKSpriteNode(color: SKColor.darkGray.withAlphaComponent(0.9), size: CGSize(width: panelWidth, height: panelHeight))
        panelBackground.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2)
        panelBackground.zPosition = 101
        
        // 添加圆角效果（通过创建圆角矩形路径）
        let cornerRadius: CGFloat = 20
        let path = CGMutablePath()
        let rect = CGRect(x: -panelWidth/2, y: -panelHeight/2, width: panelWidth, height: panelHeight)
        path.addRoundedRect(in: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        
        let shapeNode = SKShapeNode(path: path)
        shapeNode.fillColor = SKColor.darkGray.withAlphaComponent(0.9)
        shapeNode.strokeColor = SKColor.white.withAlphaComponent(0.3)
        shapeNode.lineWidth = 2
        shapeNode.position = panelBackground.position
        shapeNode.zPosition = 101
        addChild(shapeNode)
        
        // 创建标题
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "游戏暂停"
        titleLabel.fontSize = 28
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 + panelHeight / 4)
        titleLabel.zPosition = 102
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        addChild(titleLabel)
        
        // 创建继续游戏按钮
        let buttonWidth: CGFloat = panelWidth * 0.6
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 20
        
        continueButton = SKSpriteNode(color: SKColor.green.withAlphaComponent(0.8), size: CGSize(width: buttonWidth, height: buttonHeight))
        continueButton.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 + buttonSpacing / 2)
        continueButton.zPosition = 102
        continueButton.name = "continueButton"
        
        // 添加按钮圆角
        let continueButtonPath = CGMutablePath()
        let continueButtonRect = CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight)
        continueButtonPath.addRoundedRect(in: continueButtonRect, cornerWidth: 10, cornerHeight: 10)
        
        let continueButtonShape = SKShapeNode(path: continueButtonPath)
        continueButtonShape.fillColor = SKColor.green.withAlphaComponent(0.8)
        continueButtonShape.strokeColor = SKColor.white.withAlphaComponent(0.5)
        continueButtonShape.lineWidth = 1
        continueButtonShape.position = continueButton.position
        continueButtonShape.zPosition = 102
        continueButtonShape.name = "continueButton"
        addChild(continueButtonShape)
        
        continueLabel = SKLabelNode(fontNamed: "Helvetica")
        continueLabel.text = "继续游戏"
        continueLabel.fontSize = 20
        continueLabel.fontColor = SKColor.white
        continueLabel.position = continueButton.position
        continueLabel.zPosition = 103
        continueLabel.verticalAlignmentMode = .center
        continueLabel.horizontalAlignmentMode = .center
        addChild(continueLabel)
        
        // 创建退出按钮
        exitButton = SKSpriteNode(color: SKColor.red.withAlphaComponent(0.8), size: CGSize(width: buttonWidth, height: buttonHeight))
        exitButton.position = CGPoint(x: sceneSize.width / 2, y: sceneSize.height / 2 - buttonSpacing / 2 - buttonHeight)
        exitButton.zPosition = 102
        exitButton.name = "exitButton"
        
        // 添加按钮圆角
        let exitButtonPath = CGMutablePath()
        let exitButtonRect = CGRect(x: -buttonWidth/2, y: -buttonHeight/2, width: buttonWidth, height: buttonHeight)
        exitButtonPath.addRoundedRect(in: exitButtonRect, cornerWidth: 10, cornerHeight: 10)
        
        let exitButtonShape = SKShapeNode(path: exitButtonPath)
        exitButtonShape.fillColor = SKColor.red.withAlphaComponent(0.8)
        exitButtonShape.strokeColor = SKColor.white.withAlphaComponent(0.5)
        exitButtonShape.lineWidth = 1
        exitButtonShape.position = exitButton.position
        exitButtonShape.zPosition = 102
        exitButtonShape.name = "exitButton"
        addChild(exitButtonShape)
        
        exitLabel = SKLabelNode(fontNamed: "Helvetica")
        exitLabel.text = "退出游戏"
        exitLabel.fontSize = 20
        exitLabel.fontColor = SKColor.white
        exitLabel.position = exitButton.position
        exitLabel.zPosition = 103
        exitLabel.verticalAlignmentMode = .center
        exitLabel.horizontalAlignmentMode = .center
        addChild(exitLabel)
        
        // 初始状态为隐藏
        self.isHidden = true
    }
    
    // 显示面板
    func show() {
        guard !isShowing else { return }
        
        isShowing = true
        self.isHidden = false
        
        // // 添加淡入动画
        // self.alpha = 0
        // let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        // self.run(fadeInAction)
        
        print("暂停面板已显示")
    }
    
    // 隐藏面板
    func hide() {
        guard isShowing else { return }
        
        isShowing = false
        self.isHidden = true
        
        // 添加淡出动画
        // let fadeOutAction = SKAction.fadeOut(withDuration: 0.3)
        // let hideAction = SKAction.run {
        //     self.isHidden = true
        // }
        
        // self.run(SKAction.sequence([fadeOutAction, hideAction]))
        
        print("暂停面板已隐藏")
    }
    
    // 处理触摸事件
    func handleTouch(at location: CGPoint) -> Bool {
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "continueButton" {
                delegate?.pausePanelDidRequestContinue()
                return true
            } else if node.name == "exitButton" {
                delegate?.pausePanelDidRequestExit()
                return true
            }
        }
        
        return false
    }
}
