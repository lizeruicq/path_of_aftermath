//
//  BuildPanel.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

protocol BuildPanelDelegate: AnyObject {
    func didSelectTower(_ towerType: TowerType)
}

class BuildPanel: SKNode {
    // 面板背景
    private var background: SKSpriteNode!

    // 面板尺寸
    private let panelWidth: CGFloat
    private let panelHeight: CGFloat

    // 当前选中的格子
    private weak var selectedCell: GridCell?

    // 可用的炮塔类型
    private var availableTowers: [TowerType] = []

    // 委托
    weak var delegate: BuildPanelDelegate?

    // 是否正在显示
    private(set) var isShowing = false

    // 初始化方法
    init(size: CGSize) {
        // 设置面板尺寸（屏幕宽度的20%，高度的50%）
        panelWidth = size.width * 0.2
        panelHeight = size.height * 0.5

        super.init()

        // 设置面板位置（屏幕右侧外部）
        self.position = CGPoint(x: size.width + panelWidth, y: (size.height - panelHeight) / 2)

        // 设置名称
        self.name = "buildPanel"

        // 设置zPosition确保面板显示在最上层
        self.zPosition = 1000

        // 确保节点可以接收触摸事件
        self.isUserInteractionEnabled = true

        // 创建面板背景
        setupBackground()

        // 设置面板为隐藏状态
        self.isHidden = true

        print("创建建造面板: 大小=\(panelWidth)x\(panelHeight), 位置=\(self.position), zPosition=\(self.zPosition)")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置面板背景
    private func setupBackground() {
        // 创建背景精灵
        background = SKSpriteNode(color: SKColor.darkGray.withAlphaComponent(0.8), size: CGSize(width: panelWidth, height: panelHeight))
        background.position = CGPoint.zero
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.zPosition = 0  // 背景在面板的最底层

        // 添加背景到面板
        addChild(background)

        // 添加标题
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "防线"
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: panelWidth / 2, y: panelHeight - 30)
        titleLabel.zPosition = 1  // 标题在背景之上

        // 添加标题到面板
        addChild(titleLabel)
    }

    // 配置面板内容 - 初始化时调用一次
    func configure(forLevel level: Int) {
        print("配置建造面板")

        // 获取当前关卡可用的炮塔类型
        availableTowers = TowerFactory.shared.getAvailableTowerTypes(forLevel: level)

        // 清除现有内容
        clearContent()

        // 创建炮塔列表
        createTowerList()
    }

    // 更新选中的格子
    func updateSelectedCell(_ cell: GridCell) {
        self.selectedCell = cell
    }

    // 清除面板内容
    private func clearContent() {
        // 移除除背景外的所有子节点
        for child in children {
            if child != background {
                child.removeFromParent()
            }
        }
    }

    // 创建炮塔列表
    private func createTowerList() {
        // 设置列表参数
        let itemSize: CGFloat = panelWidth * 0.5
        let padding: CGFloat = (panelWidth - itemSize) / 2
        let startY = panelHeight - 60 - itemSize / 2
        let spacing: CGFloat = 20

        // 添加标题
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "防线"
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: panelWidth / 2, y: panelHeight - 30)
        titleLabel.zPosition = 1  // 标题在背景之上
        addChild(titleLabel)

        // 遍历可用炮塔类型
        for (index, towerType) in availableTowers.enumerated() {
            // 获取炮塔配置
            guard let towerConfig = TowerFactory.shared.getTowerConfig(for: towerType) else {
                continue
            }

            // 创建炮塔项容器
            let itemContainer = SKNode()
            itemContainer.position = CGPoint(x: padding + itemSize / 2, y: startY - CGFloat(index) * (itemSize + spacing))
            itemContainer.name = "tower_item_\(towerType.rawValue)"
            itemContainer.zPosition = 2  // 确保炮塔项在标题之上

            // 创建背景框
            let itemBackground = SKShapeNode(rectOf: CGSize(width: itemSize, height: itemSize), cornerRadius: 10)
            itemBackground.fillColor = SKColor.lightGray.withAlphaComponent(0.3)
            itemBackground.strokeColor = SKColor.white.withAlphaComponent(0.5)
            itemBackground.lineWidth = 2
            itemBackground.position = CGPoint.zero
            itemBackground.zPosition = 0  // 背景在容器的最底层
            itemBackground.name = "tower_item_background_\(towerType.rawValue)"

            // 创建炮塔图片
            let imageName = towerConfig["image"] as? String ?? "default_tower"
            let texture = ResourceManager.shared.getTexture(named: imageName)
            let towerImage = SKSpriteNode(texture: texture)
            towerImage.size = CGSize(width: itemSize * 0.8, height: itemSize * 0.8)
            towerImage.position = CGPoint.zero
            towerImage.zPosition = 1  // 图片在背景之上
            towerImage.name = "tower_image_\(towerType.rawValue)"

//            // 创建名称标签
//            let nameLabel = SKLabelNode(fontNamed: "Helvetica")
//            nameLabel.text = towerConfig["name"] as? String ?? "未知炮塔"
//            nameLabel.fontSize = 14
//            nameLabel.fontColor = SKColor.white
//            nameLabel.position = CGPoint(x: 0, y: -itemSize / 2 - 15)
//            nameLabel.zPosition = 2  // 名称在图片之上

            // 创建价格标签
            let priceLabel = SKLabelNode(fontNamed: "Helvetica")
            let price = towerConfig["price"] as? Int ?? 0
            priceLabel.text = "$: \(price)"
            priceLabel.fontSize = 12
            priceLabel.fontColor = SKColor.yellow
            priceLabel.position = CGPoint(x: 0, y: -itemSize / 2 - 12)
            priceLabel.zPosition = 2  // 价格在图片之上
            priceLabel.name = "price_label_\(towerType.rawValue)"

            // 创建禁用覆盖层（初始隐藏）
            let disabledOverlay = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.7), size: CGSize(width: itemSize, height: itemSize))
            disabledOverlay.position = CGPoint.zero
            disabledOverlay.zPosition = 3  // 覆盖层在最上层
            disabledOverlay.name = "disabled_overlay_\(towerType.rawValue)"
            disabledOverlay.isHidden = true

            // 创建禁用图标
            let disabledIcon = SKSpriteNode(imageNamed: "disabled_icon")
            if disabledIcon.texture == nil {
                // 如果没有禁用图标，创建一个简单的X形状
                let disabledSymbol = SKShapeNode()
                let path = CGMutablePath()
                let size: CGFloat = itemSize * 0.4
                path.move(to: CGPoint(x: -size/2, y: -size/2))
                path.addLine(to: CGPoint(x: size/2, y: size/2))
                path.move(to: CGPoint(x: -size/2, y: size/2))
                path.addLine(to: CGPoint(x: size/2, y: -size/2))
                disabledSymbol.path = path
                disabledSymbol.strokeColor = .red
                disabledSymbol.lineWidth = 4
                disabledOverlay.addChild(disabledSymbol)
            } else {
                disabledIcon.size = CGSize(width: itemSize * 0.5, height: itemSize * 0.5)
                disabledIcon.position = CGPoint.zero
                disabledOverlay.addChild(disabledIcon)
            }

            // 添加到容器
            itemContainer.addChild(itemBackground)
            itemContainer.addChild(towerImage)
//            itemContainer.addChild(nameLabel)
            itemContainer.addChild(priceLabel)
            itemContainer.addChild(disabledOverlay)

            // 添加到面板
            addChild(itemContainer)
        }
    }

    // 更新炮塔可购买状态
    func updateAffordability() {
        // 遍历所有炮塔项
        for towerType in availableTowers {
            // 获取炮塔价格
            let price = PlayerEconomyManager.shared.getTowerPrice(type: towerType)

            // 检查是否有足够的金币
            let canAfford = PlayerEconomyManager.shared.canAfford(price)

            // 获取禁用覆盖层
            if let itemContainer = self.childNode(withName: "tower_item_\(towerType.rawValue)"),
               let disabledOverlay = itemContainer.childNode(withName: "disabled_overlay_\(towerType.rawValue)") {
                // 更新禁用覆盖层的可见性
                disabledOverlay.isHidden = canAfford
            }
        }
    }

    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 获取触摸位置
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 获取点击的节点
        let touchedNode = self.atPoint(location)

        // 查找点击的炮塔项背景或容器
        var towerItemNode: SKNode? = touchedNode
        while towerItemNode != nil &&
              !(towerItemNode!.name?.starts(with: "tower_item_background_") ?? false) &&
              !(towerItemNode!.name?.starts(with: "tower_item_") ?? false) {
            towerItemNode = towerItemNode?.parent
        }

        // 如果找到炮塔项
        if let towerItemNode = towerItemNode {
            var towerTypeString: String? = nil

            // 从背景节点名称中提取炮塔类型
            if let name = towerItemNode.name, name.starts(with: "tower_item_background_") {
                towerTypeString = name.replacingOccurrences(of: "tower_item_background_", with: "")
            }
            // 从容器节点名称中提取炮塔类型
            else if let name = towerItemNode.name, name.starts(with: "tower_item_") {
                towerTypeString = name.replacingOccurrences(of: "tower_item_", with: "")
            }

            // 如果找到炮塔类型
            if let towerTypeString = towerTypeString, let towerType = TowerType(rawValue: towerTypeString) {
                // 检查是否有足够的金币
                let price = PlayerEconomyManager.shared.getTowerPrice(type: towerType)
                if !PlayerEconomyManager.shared.canAfford(price) {
                    if let scene = self.scene {
                        // 播放错误音效
                        SoundManager.shared.playSoundEffect("error", in: scene)
                    }

                    // 显示禁用状态动画
                    if let itemContainer = self.childNode(withName: "tower_item_\(towerType.rawValue)"),
                       let disabledOverlay = itemContainer.childNode(withName: "disabled_overlay_\(towerType.rawValue)") {
                        // 创建闪烁动画
                        let fadeIn = SKAction.fadeIn(withDuration: 0.1)
                        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
                        let flash = SKAction.sequence([fadeIn, fadeOut, fadeIn, fadeOut])

                        // 确保覆盖层可见
                        disabledOverlay.isHidden = false
                        disabledOverlay.alpha = 0

                        // 运行动画
                        disabledOverlay.run(flash) {
                            // 动画完成后恢复正常状态
                            disabledOverlay.alpha = 1
                        }
                    }

                    return
                }

                // 通知委托
                delegate?.didSelectTower(towerType)

                // 隐藏面板
                hide()
            }
        }
    }

    // 显示面板
    func show() {
        // 如果已经在显示，只需更新位置确保正确显示
        if isShowing {
            print("建造面板已经在显示中")
            // 确保面板位置正确
            let targetX = self.scene!.size.width - panelWidth
            if self.position.x != targetX {
                self.position.x = targetX
            }

            // 更新炮塔可购买状态
            updateAffordability()
            return
        }

        // 设置为可见
        self.isHidden = false

        print("显示建造面板，当前位置: \(self.position)")

        // 创建滑入动画
        let targetX = self.scene!.size.width - panelWidth
        let slideInAction = SKAction.moveTo(x: targetX, duration: 0.3)
        slideInAction.timingMode = .easeOut

        print("建造面板滑入动画，目标位置X: \(targetX)")

        // 更新炮塔可购买状态
        updateAffordability()

        // 运行动画
        self.run(slideInAction)

        // 更新状态
        isShowing = true
    }

    // 隐藏面板
    func hide() {
        // 如果已经隐藏，不执行任何操作
        if !isShowing {
            print("建造面板已经隐藏")
            return
        }

        print("隐藏建造面板，当前位置: \(self.position)")

        // 创建滑出动画
        let targetX = self.scene!.size.width + panelWidth
        let slideOutAction = SKAction.moveTo(x: targetX, duration: 0.3)
        slideOutAction.timingMode = .easeIn

        print("建造面板滑出动画，目标位置X: \(targetX)")

        // 创建隐藏动作
        let hideAction = SKAction.run {
            self.isHidden = true
            print("建造面板已隐藏")
        }

        // 运行动画序列
        self.run(SKAction.sequence([slideOutAction, hideAction]))

        // 更新状态
        isShowing = false
    }
}

