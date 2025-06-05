import SpriteKit
import UIKit

// 确认面板委托协议
protocol ConfirmationPanelDelegate: AnyObject {
    func confirmationPanelDidConfirm(_ panel: ConfirmationPanel)
    func confirmationPanelDidCancel(_ panel: ConfirmationPanel)
}

class ConfirmationPanel: SKNode {
    
    // 委托
    weak var delegate: ConfirmationPanelDelegate?
    
    // 面板尺寸
    private let panelWidth: CGFloat = 300
    private let panelHeight: CGFloat = 200
    
    // 初始化方法
    init(size: CGSize) {
        super.init()
        setupPanel(size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置面板
    private func setupPanel(_ sceneSize: CGSize) {
        // 计算面板位置（居中）
        let panelX = (sceneSize.width - panelWidth) / 2
        let panelY = (sceneSize.height - panelHeight) / 2
        self.position = CGPoint(x: panelX, y: panelY)
        // 创建面板背景
        let panelBackground = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.8), size: CGSize(width: panelWidth, height: panelHeight))
        panelBackground.position = CGPoint(x: panelWidth/2, y: panelHeight/2)
        panelBackground.zPosition = 100
        addChild(panelBackground)
        
        // 创建文字标签
        let messageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        messageLabel.text = "是否重置关卡进度到第一关"
        messageLabel.fontSize = 18
        messageLabel.fontColor = SKColor.white
        messageLabel.position = CGPoint(x: panelWidth/2, y: panelHeight * 0.6)
        messageLabel.zPosition = 101
        messageLabel.numberOfLines = 2
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.preferredMaxLayoutWidth = panelWidth * 0.8
        messageLabel.verticalAlignmentMode = .center
        messageLabel.horizontalAlignmentMode = .center
        addChild(messageLabel)
        
        // 按钮配置
        let buttonWidth: CGFloat = 100
        let buttonHeight: CGFloat = 40
        let buttonSpacing: CGFloat = 30
        
        // 是按钮
        let yesButton = createButton(text: "是", width: buttonWidth, height: buttonHeight)
        yesButton.position = CGPoint(x: panelWidth/2 - buttonSpacing/2 - buttonWidth/2, y: panelHeight * 0.3)
        yesButton.name = "yesButton"
        addChild(yesButton)
        
        // 否按钮
        let noButton = createButton(text: "否", width: buttonWidth, height: buttonHeight)
        noButton.position = CGPoint(x: panelWidth/2 + buttonSpacing/2 + buttonWidth/2, y: panelHeight * 0.3)
        noButton.name = "noButton"
        addChild(noButton)
        
    
    }
    
    // 创建按钮
    private func createButton(text: String, width: CGFloat, height: CGFloat) -> SKShapeNode {
        let button = SKShapeNode(rectOf: CGSize(width: width, height: height), cornerRadius: 10)
        button.fillColor = SKColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0)
        button.strokeColor = SKColor.white
        button.lineWidth = 2
        button.zPosition = 102
        
        let buttonText = SKLabelNode(fontNamed: "Helvetica")
        buttonText.text = text
        buttonText.fontSize = 18
        buttonText.fontColor = SKColor.white
        buttonText.position = CGPoint(x: 0, y: 0)
        buttonText.zPosition = 103
        buttonText.verticalAlignmentMode = .center
        buttonText.horizontalAlignmentMode = .center
        
        button.addChild(buttonText)
        return button
    }
    
    // 处理触摸开始
    func handleTouchBegan(at location: CGPoint) {
        // 检查点击的是哪个按钮
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if node.name == "yesButton" {
                delegate?.confirmationPanelDidConfirm(self)
                break
            } else if node.name == "noButton" {
                delegate?.confirmationPanelDidCancel(self)
                break
            } 
        }
    }
    
    // 处理触摸结束
    func handleTouchEnded(at location: CGPoint) {
        // 可以留空或添加额外的触摸处理逻辑
    }
}
