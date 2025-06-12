import SpriteKit


class SoldierTipPanel: SKNode {
    

    
    // 面板尺寸
    private let panelWidth: CGFloat = 400
    private let panelHeight: CGFloat = 100
    
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
        let panelY = (sceneSize.height - panelHeight) / 5
        self.position = CGPoint(x: panelX, y: panelY)
        
        
        
        // 创建士兵图片
        let soldierImage = SKSpriteNode(imageNamed: "char")
        soldierImage.size = CGSize(width: 120, height: 180)
        soldierImage.position = CGPoint(x: 70, y: panelHeight * 0.15)
        soldierImage.zPosition = 101
        addChild(soldierImage)
        
        // 创建文字标签
        let messageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        messageLabel.text = "临近的相同兵种会互相为对方增加10%攻击力，最多叠加两次"
        messageLabel.fontSize = 16
        messageLabel.fontColor = SKColor.white
        messageLabel.position = CGPoint(x: panelWidth/2 + 50, y: panelHeight * 0.4)
        messageLabel.zPosition = 101
        messageLabel.numberOfLines = 0
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.preferredMaxLayoutWidth = panelWidth * 0.6
        messageLabel.verticalAlignmentMode = .center
        addChild(messageLabel)
        

    }
    

}
