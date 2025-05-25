//
//  GameEndPanel.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

// 游戏结束类型
enum GameEndType {
    case victory    // 胜利
    case defeat     // 失败
}

// 游戏结束面板委托协议
protocol GameEndPanelDelegate: AnyObject {
    func gameEndPanelDidRequestReturn(_ panel: GameEndPanel)
    func gameEndPanelDidRequestRestart(_ panel: GameEndPanel)
}

class GameEndPanel: SKNode {
    
    // 委托
    weak var delegate: GameEndPanelDelegate?
    
    // UI元素
    private var backgroundOverlay: SKSpriteNode!
    private var panelBackground: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var returnButton: SKShapeNode!
    private var restartButton: SKShapeNode!
    private var returnButtonLabel: SKLabelNode!
    private var restartButtonLabel: SKLabelNode!
    
    // 面板尺寸
    private let panelWidth: CGFloat
    private let panelHeight: CGFloat
    private let sceneSize: CGSize
    
    // 游戏结束类型
    private var endType: GameEndType = .victory
    
    // 是否正在显示
    private(set) var isShowing: Bool = false
    
    // 初始化
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        
        // 计算面板尺寸 (16:9比例，占屏幕高度的40%)
        panelHeight = sceneSize.height * 0.4
        panelWidth = panelHeight * 16 / 9
        
        super.init()
        
        setupPanel()
        
        // 初始状态为隐藏
        isHidden = true
//        alpha = 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置面板
    private func setupPanel() {
        // 创建半透明背景覆盖层
        backgroundOverlay = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.7), size: sceneSize)
        backgroundOverlay.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        backgroundOverlay.zPosition = 100
        addChild(backgroundOverlay)
        
        // 创建面板背景
        let cornerRadius: CGFloat = 20
        panelBackground = SKShapeNode(rectOf: CGSize(width: panelWidth, height: panelHeight), cornerRadius: cornerRadius)
        panelBackground.fillColor = SKColor.darkGray.withAlphaComponent(0.95)
        panelBackground.strokeColor = SKColor.white
        panelBackground.lineWidth = 3
        panelBackground.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2)
        panelBackground.zPosition = 101
        addChild(panelBackground)
        
        // 创建标题标签
        titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.fontSize = 32
        titleLabel.verticalAlignmentMode = .center
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2 + 60)
        titleLabel.zPosition = 102
        addChild(titleLabel)
        
        // 创建副标题标签
        subtitleLabel = SKLabelNode(fontNamed: "Helvetica")
        subtitleLabel.fontSize = 18
        subtitleLabel.fontColor = SKColor.lightGray
        subtitleLabel.verticalAlignmentMode = .center
        subtitleLabel.horizontalAlignmentMode = .center
        subtitleLabel.position = CGPoint(x: sceneSize.width/2, y: sceneSize.height/2 + 20)
        subtitleLabel.zPosition = 102
        addChild(subtitleLabel)
        
        // 创建按钮
        setupButtons()
    }
    
    // 设置按钮
    private func setupButtons() {
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 50
        let buttonSpacing: CGFloat = 40
        let buttonY = sceneSize.height/2 - 40
        
        // 返回按钮
        returnButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        returnButton.fillColor = SKColor.red.withAlphaComponent(0.8)
        returnButton.strokeColor = SKColor.white
        returnButton.lineWidth = 2
        returnButton.position = CGPoint(x: sceneSize.width/2 - buttonSpacing, y: buttonY)
        returnButton.name = "returnButton"
        returnButton.zPosition = 102
        addChild(returnButton)
        
        returnButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        returnButtonLabel.text = "返回"
        returnButtonLabel.fontSize = 18
        returnButtonLabel.fontColor = SKColor.white
        returnButtonLabel.verticalAlignmentMode = .center
        returnButtonLabel.horizontalAlignmentMode = .center
        returnButtonLabel.position = CGPoint.zero
        returnButtonLabel.zPosition = 103
        returnButton.addChild(returnButtonLabel)
        
        // 重新开始按钮
        restartButton = SKShapeNode(rectOf: CGSize(width: buttonWidth, height: buttonHeight), cornerRadius: 10)
        restartButton.fillColor = SKColor.green.withAlphaComponent(0.8)
        restartButton.strokeColor = SKColor.white
        restartButton.lineWidth = 2
        restartButton.position = CGPoint(x: sceneSize.width/2 + buttonSpacing, y: buttonY)
        restartButton.name = "restartButton"
        restartButton.zPosition = 102
        addChild(restartButton)
        
        restartButtonLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        restartButtonLabel.text = "重新开始"
        restartButtonLabel.fontSize = 18
        restartButtonLabel.fontColor = SKColor.white
        restartButtonLabel.verticalAlignmentMode = .center
        restartButtonLabel.horizontalAlignmentMode = .center
        restartButtonLabel.position = CGPoint.zero
        restartButtonLabel.zPosition = 103
        restartButton.addChild(restartButtonLabel)
    }
    
    // 显示面板
    func show(endType: GameEndType) {
        self.endType = endType
        
        // 更新内容
        updateContent()
        
        // 显示动画
        isHidden = false
        isShowing = true
        
        
        panelBackground.setScale(0.8)

        
        print("游戏结束面板已显示: \(endType == .victory ? "胜利" : "失败")")
    }
    
    // 隐藏面板
    func hide() {
        guard isShowing else { return }
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.3)
        scaleDown.timingMode = .easeIn
        
        let hideAction = SKAction.sequence([
            SKAction.group([fadeOut, scaleDown]),
            SKAction.run { [weak self] in
                self?.isHidden = true
                self?.isShowing = false
            }
        ])
        
        run(hideAction)
        
        print("游戏结束面板已隐藏")
    }
    
    // 更新面板内容
    private func updateContent() {
        switch endType {
        case .victory:
            titleLabel.text = "🎉 胜利！"
            titleLabel.fontColor = SKColor.yellow
            subtitleLabel.text = "恭喜您成功完成了这一关！"
            
        case .defeat:
            titleLabel.text = "💀 失败"
            titleLabel.fontColor = SKColor.red
            subtitleLabel.text = "僵尸突破了防线，再试一次吧！"
        }
    }
    
    // 处理触摸事件
    func handleTouch(at location: CGPoint) {
        guard isShowing else { return }
        
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "returnButton" || node.parent?.name == "returnButton" {
                handleReturnButtonTapped()
                break
            } else if node.name == "restartButton" || node.parent?.name == "restartButton" {
                handleRestartButtonTapped()
                break
            }
        }
    }
    
    // 处理返回按钮点击
    private func handleReturnButtonTapped() {
        print("点击了返回按钮")
        
        // 添加按钮点击效果
        addButtonClickEffect(to: returnButton)
        
        // 延迟执行以显示点击效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.delegate?.gameEndPanelDidRequestReturn(self)
        }
    }
    
    // 处理重新开始按钮点击
    private func handleRestartButtonTapped() {
        print("点击了重新开始按钮")
        
        // 添加按钮点击效果
        addButtonClickEffect(to: restartButton)
        
        // 延迟执行以显示点击效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            self.delegate?.gameEndPanelDidRequestRestart(self)
        }
    }
    
    // 添加按钮点击效果
    private func addButtonClickEffect(to button: SKNode) {
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.05)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
        let clickEffect = SKAction.sequence([scaleDown, scaleUp])
        
        button.run(clickEffect)
    }
}
