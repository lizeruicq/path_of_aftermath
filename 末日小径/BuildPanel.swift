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

        // 确保节点可以接收触摸事件
        self.isUserInteractionEnabled = true

        // 创建面板背景
        setupBackground()

        // 设置面板为隐藏状态
        self.isHidden = true

        print("创建建造面板: 大小=\(panelWidth)x\(panelHeight), 位置=\(self.position)")
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

        // 添加背景到面板
        addChild(background)

        // 添加标题
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "建造炮塔"
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: panelWidth / 2, y: panelHeight - 30)

        // 添加标题到面板
        addChild(titleLabel)
    }

    // 配置面板内容
    func configure(forLevel level: Int, selectedCell: GridCell) {
        // 保存选中的格子
        self.selectedCell = selectedCell

        // 获取当前关卡可用的炮塔类型
        availableTowers = TowerFactory.shared.getAvailableTowerTypes(forLevel: level)

        // 清除现有内容
        clearContent()

        // 创建炮塔列表
        createTowerList()
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
        let itemSize: CGFloat = panelWidth * 0.7
        let padding: CGFloat = (panelWidth - itemSize) / 2
        let startY = panelHeight - 60 - itemSize / 2
        let spacing: CGFloat = 20

        // 添加标题
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "建造炮塔"
        titleLabel.fontSize = 20
        titleLabel.fontColor = SKColor.white
        titleLabel.position = CGPoint(x: panelWidth / 2, y: panelHeight - 30)
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

            // 创建炮塔图片
            let imageName = towerConfig["image"] as? String ?? "default_tower"
            let towerImage = SKSpriteNode(imageNamed: imageName)
            towerImage.size = CGSize(width: itemSize * 0.8, height: itemSize * 0.8)
            towerImage.position = CGPoint.zero

            // 创建背景框
            let itemBackground = SKShapeNode(rectOf: CGSize(width: itemSize, height: itemSize), cornerRadius: 10)
            itemBackground.fillColor = SKColor.lightGray.withAlphaComponent(0.3)
            itemBackground.strokeColor = SKColor.white.withAlphaComponent(0.5)
            itemBackground.lineWidth = 2
            itemBackground.position = CGPoint.zero

            // 创建名称标签
            let nameLabel = SKLabelNode(fontNamed: "Helvetica")
            nameLabel.text = towerConfig["name"] as? String ?? "未知炮塔"
            nameLabel.fontSize = 14
            nameLabel.fontColor = SKColor.white
            nameLabel.position = CGPoint(x: 0, y: -itemSize / 2 - 15)

            // 创建价格标签
            let priceLabel = SKLabelNode(fontNamed: "Helvetica")
            let price = towerConfig["price"] as? Int ?? 0
            priceLabel.text = "价格: \(price)"
            priceLabel.fontSize = 12
            priceLabel.fontColor = SKColor.yellow
            priceLabel.position = CGPoint(x: 0, y: -itemSize / 2 - 30)

            // 添加到容器
            itemContainer.addChild(itemBackground)
            itemContainer.addChild(towerImage)
            itemContainer.addChild(nameLabel)
            itemContainer.addChild(priceLabel)

            // 添加到面板
            addChild(itemContainer)

            // 设置用户交互
            itemBackground.name = "tower_item_background_\(towerType.rawValue)"
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
                // 通知委托
                delegate?.didSelectTower(towerType)

                // 隐藏面板
                hide()
            }
        }
    }

    // 显示面板
    func show() {
        // 如果已经在显示，不执行任何操作
        if isShowing {
            print("建造面板已经在显示中")
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
