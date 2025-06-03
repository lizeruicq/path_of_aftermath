//
//  GameSceneWithGrid.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/2.
//

import SpriteKit
import GameplayKit

class GameSceneWithGrid: GameScene, BuildPanelDelegate, PlayerEconomyDelegate, PausePanelDelegate, GameEndPanelDelegate {

    // 网格尺寸
    let gridRows: Int = 19
    let gridColumns: Int = 9

    // 网格配置
    private var gridConfig: GridConfig!
    // 网格节点
    private var gridNode: SKNode!
    // 可建造网格颜色（绿色）
    private let buildableColor = UIColor.green.withAlphaComponent(0.2) // 设置透明度为20%
    // 不可建造网格颜色（红色）
    private let unbuildableColor = UIColor.red.withAlphaComponent(0.0) // 设置透明度为0%，完全隐藏

     override init(size: CGSize) {
         super.init(size: size)
         // 初始化网格配置（从grid_config.json加载）
         gridConfig = GridConfig(rows: 16, columns: 9) // 修改行数和列数以匹配grid_config.json的实际尺寸
         if !gridConfig.loadFromFile(fileName: "grid_config") {
             // 如果加载失败，创建默认配置
             print("无法加载网格配置")
         }

     }

     required init?(coder aDecoder: NSCoder) {

         fatalError("init(coder:) has not been implemented")
     }

    // 创建网格
    private func createGrid() {
        // 创建一个新节点来承载整个网格
        gridNode = SKNode()
        addChild(gridNode)

        // 计算每个单元格的大小
        let cellWidth = size.width / CGFloat(gridConfig.columns)
        let cellHeight = size.height / CGFloat(gridConfig.rows)

        // 遍历所有单元格
        for row in 0..<gridConfig.rows {
            for col in 0..<gridConfig.columns {
                // 只创建可建造的单元格
                if gridConfig.isCellBuildable(row: row, column: col) {
                    // 创建单元格
                    let cell = GridCell(row: row, column: col, size: CGSize(width: cellWidth, height: cellHeight))

                    // 设置位置
                    cell.position = CGPoint(x: CGFloat(col) * cellWidth, y: CGFloat(row) * cellHeight)

                    // 设置为可建造
                    cell.isBuildable = true

                    // 将单元格添加到网格节点
                    gridNode.addChild(cell)
                }
            }
        }

        // 设置网格位置
        gridNode.position = CGPoint.zero
    }

    // 存储所有可建造的网格单元格的数组
    private var gridCells: [[GridCell]] = []

    // 网格容器节点
    private var gridContainer: SKNode!

    // 背景节点
    private var backgroundNode: SKSpriteNode?

    // 上次更新时间
    private var lastUpdateTime: TimeInterval = 0

    // 建造面板
    private var buildPanel: BuildPanel!

    // 当前选中的格子
    private var selectedCell: GridCell?

    // 摧毁按钮
    private var destroyButton: SKShapeNode?

    // 当前选中要摧毁的炮塔
    private var selectedTowerForDestroy: Defend?

    // 金币显示UI
    private var currencyDisplay: SKNode!
    private var currencyIcon: SKSpriteNode!
    private var currencyLabel: SKLabelNode!

    // 暂停功能
    private var pauseButton: SKSpriteNode!
    private var pausePanel: PausePanel!

    // 游戏结束面板
    internal var gameEndPanel: GameEndPanel!

    override func didMove(to view: SKView) {
        // 确保场景可以接收触摸事件
        self.isUserInteractionEnabled = true

        // 设置场景
        setupScene()

        // 加载网格配置
        loadGridConfiguration()

        // 创建网格
        setupGrid()

        // 添加点击处理
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleCellTap(_:)))
        view.addGestureRecognizer(tapRecognizer)

        print("场景初始化完成，isUserInteractionEnabled = \(self.isUserInteractionEnabled)")
    }

    // 设置场景基本元素
    private func setupScene() {
        // 设置背景
        setupBackground()

        // 创建网格容器节点
        gridContainer = SKNode()
        gridContainer.position = CGPoint(x: 0, y: 0)
        gridContainer.zPosition = 10
        gridContainer.name = "gridContainer"
        gridContainer.isUserInteractionEnabled = true
        addChild(gridContainer)

        print("创建网格容器节点")

        // 创建建造面板
        setupBuildPanel()

        // 创建金币显示UI
        setupCurrencyDisplay()

        // 初始化经济系统
        initializeEconomy()

        // 创建暂停按钮
        setupPauseButton()

        // 创建暂停面板
        setupPausePanel()

        // 创建游戏结束面板
        setupGameEndPanel()
    }

    // 设置金币显示UI
    private func setupCurrencyDisplay() {
        // 创建容器节点
        currencyDisplay = SKNode()
        currencyDisplay.position = CGPoint(x: 60, y: 60)
        currencyDisplay.zPosition = 1000 // 确保显示在最上层

        // 创建金币图标
        let iconTexture = SKTexture(imageNamed: "coin_icon") // 需要添加金币图标到资源中
        currencyIcon = SKSpriteNode(texture: iconTexture, color: .clear, size: CGSize(width: 30, height: 30))
        currencyIcon.position = CGPoint(x: -40, y: 0)

        // 如果没有金币图标，使用一个简单的圆形代替
        if currencyIcon.texture == nil {
            let circle = SKShapeNode(circleOfRadius: 15)
            circle.fillColor = .yellow
            circle.strokeColor = .orange
            circle.position = CGPoint(x: -40, y: 0)
            currencyDisplay.addChild(circle)
        } else {
            currencyDisplay.addChild(currencyIcon)
        }

        // 创建金币数量标签
        currencyLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        currencyLabel.fontSize = 24
        currencyLabel.fontColor = .yellow
        currencyLabel.horizontalAlignmentMode = .left
        currencyLabel.verticalAlignmentMode = .center
        currencyLabel.position = CGPoint(x: -20, y: 0)
        currencyLabel.text = "0"

        // 添加标签到容器
        currencyDisplay.addChild(currencyLabel)

        // 添加容器到场景
        addChild(currencyDisplay)
    }

    // 初始化经济系统
    private func initializeEconomy() {
        // 设置经济管理器的委托
        PlayerEconomyManager.shared.delegate = self

        // 初始化当前关卡的资金
        PlayerEconomyManager.shared.initializeForLevel(currentLevel)
    }

    // 设置建造面板
    private func setupBuildPanel() {
        // 创建建造面板
        buildPanel = BuildPanel(size: self.size)
        buildPanel.delegate = self

        // 初始配置面板（只需配置一次）
        buildPanel.configure(forLevel: currentLevel)

        // 添加到场景
        addChild(buildPanel)
    }

    // 设置暂停按钮
    private func setupPauseButton() {
        // 创建暂停按钮
        let buttonSize: CGFloat = 50
        pauseButton = SKSpriteNode(color: SKColor.gray.withAlphaComponent(0.8), size: CGSize(width: buttonSize, height: buttonSize))

        // 设置按钮位置（右下角）
        pauseButton.position = CGPoint(x: self.size.width - buttonSize/2 - 20, y: buttonSize/2 + 20)
        pauseButton.zPosition = 1000
        pauseButton.name = "pauseButton"

        // 添加圆角效果
        let cornerRadius: CGFloat = 10
        let path = CGMutablePath()
        let rect = CGRect(x: -buttonSize/2, y: -buttonSize/2, width: buttonSize, height: buttonSize)
        path.addRoundedRect(in: rect, cornerWidth: cornerRadius, cornerHeight: cornerRadius)

        let shapeNode = SKShapeNode(path: path)
        shapeNode.fillColor = SKColor.gray.withAlphaComponent(0.8)
        shapeNode.strokeColor = SKColor.white.withAlphaComponent(0.5)
        shapeNode.lineWidth = 2
        shapeNode.position = pauseButton.position
        shapeNode.zPosition = 1000
        shapeNode.name = "pauseButton"
        addChild(shapeNode)

        // 创建暂停图标（两个竖线）
        let lineWidth: CGFloat = 4
        let lineHeight: CGFloat = buttonSize * 0.4
        let lineSpacing: CGFloat = 6

        // 左竖线
        let leftLine = SKShapeNode(rect: CGRect(x: -lineSpacing/2 - lineWidth, y: -lineHeight/2, width: lineWidth, height: lineHeight))
        leftLine.fillColor = SKColor.white
        leftLine.strokeColor = SKColor.clear
        leftLine.position = pauseButton.position
        leftLine.zPosition = 1001
        addChild(leftLine)

        // 右竖线
        let rightLine = SKShapeNode(rect: CGRect(x: lineSpacing/2, y: -lineHeight/2, width: lineWidth, height: lineHeight))
        rightLine.fillColor = SKColor.white
        rightLine.strokeColor = SKColor.clear
        rightLine.position = pauseButton.position
        rightLine.zPosition = 1001
        addChild(rightLine)

        print("暂停按钮已创建")
    }

    // 设置暂停面板
    private func setupPausePanel() {
        // 创建暂停面板
        pausePanel = PausePanel(sceneSize: self.size)
        pausePanel.delegate = self
        pausePanel.zPosition = 2000

        // 添加到场景
        addChild(pausePanel)

        print("暂停面板已创建")
    }

    // 设置游戏结束面板
    private func setupGameEndPanel() {
        gameEndPanel = GameEndPanel(sceneSize: size)
        gameEndPanel.delegate = self
        gameEndPanel.zPosition = 5000  // 确保在暂停面板之上
        addChild(gameEndPanel)

        print("游戏结束面板已创建")
    }

    // 测试方法：显示游戏结束面板
    private func testGameEndPanel() {
        // 测试胜利面板
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.gameEndPanel.show(endType: .victory)
        }

        // 测试失败面板
        // DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
        //     self?.gameEndPanel.show(endType: .defeat)
        // }
    }

    // 设置背景
    private func setupBackground() {
        // 创建背景精灵节点
        backgroundNode = SKSpriteNode(color: SKColor.black, size: self.size)

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

            // 设置zPosition确保背景在最底层
            backgroundNode.zPosition = 0

            // 将背景添加到场景
            addChild(backgroundNode)
        }
    }

    // 加载网格配置
    private func loadGridConfiguration() {
        // 尝试从JSON文件加载配置
        if !gridConfig.loadFromFile(fileName: "grid_config") {
            // 如果加载失败，使用默认配置（可选）
            gridConfig.createDefaultConfig()
            print("使用默认网格配置")
        } else {
            print("已从grid_config.json加载网格配置")
        }
    }

    // 设置网格
    private func setupGrid() {
        // 计算单元格大小
        let cellWidth = self.size.width / CGFloat(gridColumns)
        let cellHeight = self.size.height / CGFloat(gridRows)
        let cellSize = CGSize(width: cellWidth, height: cellHeight)

        print("设置网格: 单元格大小 = \(cellSize)")

        // 初始化网格单元格数组（使用可选类型，因为不是所有位置都会有单元格）
        var tempGridCells: [[GridCell?]] = Array(repeating: Array(repeating: nil, count: gridColumns), count: gridRows)

        // 只创建可建造的单元格
        for row in 0..<gridRows {
            for column in 0..<gridColumns {
                // 只创建可建造的单元格
                if gridConfig.isCellBuildable(row: row, column: column) {
                    // 创建单元格
                    let cell = GridCell(row: row, column: column, size: cellSize)

                    // 设置单元格位置
                    cell.position = CGPoint(x: CGFloat(column) * cellWidth, y: CGFloat(row) * cellHeight)

                    // 设置为可建造
                    cell.isBuildable = true

                    // 将单元格添加到网格容器
                    gridContainer.addChild(cell)

//                    print("添加单元格: row=\(row), column=\(column), position=\(cell.position)")

                    // 存储单元格引用
                    tempGridCells[row][column] = cell
                }
            }
        }

        // 转换为非可选类型的数组，只包含实际创建的单元格
        gridCells = []
        for row in 0..<gridRows {
            var rowCells: [GridCell] = []
            for column in 0..<gridColumns {
                if let cell = tempGridCells[row][column] {
                    rowCells.append(cell)
                }
            }
            if !rowCells.isEmpty {
                gridCells.append(rowCells)
            }
        }

    }

    // 更新方法
    override func update(_ currentTime: TimeInterval) {
        // 计算时间增量
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }

        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // 更新所有炮塔
        updateTowers(deltaTime: dt)

        // 调用父类的更新方法
        super.update(currentTime)
    }

    // 更新所有炮塔
    private func updateTowers(deltaTime: TimeInterval) {
        // 遍历所有网格单元格
        for row in gridCells {
            for cell in row {
                // 更新单元格中的炮塔
                cell.update(deltaTime: deltaTime)
            }
        }




    }

    // 处理触摸事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        // 不在这里处理触摸事件，而是让手势识别器来处理
        print("touchesBegan 被调用，但不处理触摸事件")
        return


//        // 检查是否点击了网格单元格
//
//        print("点击的节点: \(touchedNode), 类型: \(type(of: touchedNode)), 名称: \(touchedNode.name ?? "无名称")")
//
//        // 如果点击的不是GridCell，尝试查找父节点
//        var nodeToCheck = touchedNode
//        var depth = 0
//        while !(nodeToCheck is GridCell) && nodeToCheck.parent != nil && depth < 5 {
//            nodeToCheck = nodeToCheck.parent!
//            depth += 1
//            print("检查父节点: \(nodeToCheck), 类型: \(type(of: nodeToCheck)), 名称: \(nodeToCheck.name ?? "无名称")")
//        }
//
//        // 如果点击了网格单元格
//        if let cell = nodeToCheck as? GridCell {
//            print("找到GridCell: row=\(cell.row), column=\(cell.column), isBuildable=\(cell.isBuildable), hasTower=\(cell.hasTower)")
//
//            // 高亮显示
//            cell.highlight()
//
//            // 如果单元格可建造且没有炮塔，显示建造面板
//            if cell.isBuildable && !cell.hasTower {
//                print("点击可建造单元格，显示建造面板")
//                // 保存选中的格子
//                selectedCell = cell
//
//                // 配置并显示建造面板
//                buildPanel.configure(forLevel: currentLevel, selectedCell: cell)
//                buildPanel.show()
//            } else {
//                print("单元格不满足条件: isBuildable=\(cell.isBuildable), hasTower=\(cell.hasTower)")
//            }
//        } else {
//            print("未找到GridCell，点击了其他区域，隐藏建造面板")
//            // 如果点击了其他区域，隐藏建造面板
//            buildPanel.hide()
//            selectedCell = nil
//        }
    }

    // 处理单元格点击
    @objc func handleCellTap(_ recognizer: UITapGestureRecognizer) {
        // 获取点击位置
        let location = recognizer.location(in: self.view)
        let sceneLocation = self.convertPoint(fromView: location)

        print("处理单元格点击: 位置=\(sceneLocation)")

        // 首先检查是否点击了游戏结束面板
        if gameEndPanel.isShowing {
            gameEndPanel.handleTouch(at: sceneLocation)
            return // 游戏结束面板处理了点击事件
        }

        // 检查是否点击了暂停面板
        if pausePanel.isShowing {
            if pausePanel.handleTouch(at: sceneLocation) {
                return // 暂停面板处理了点击事件
            }
        }

        // 检查是否点击了暂停按钮
        let touchedNodes = nodes(at: sceneLocation)
        for node in touchedNodes {
            if node.name == "pauseButton" {
                handlePauseButtonTap()
                return
            }
        }

        // 首先检查是否点击了摧毁按钮
        if let button = destroyButton {
            print("检查摧毁按钮点击，按钮存在")
            print("按钮位置: \(button.position)")
            print("按钮父节点: \(button.parent?.name ?? "无名称")")

            // 将点击位置转换为按钮的父节点坐标系
            if let buttonParent = button.parent {
                let locationInButtonParent = self.convert(sceneLocation, to: buttonParent)
                print("点击位置在按钮父节点坐标系中: \(locationInButtonParent)")
                print("按钮边界检查: \(button.contains(locationInButtonParent))")

                // 检查点击位置是否在按钮内
                if button.contains(locationInButtonParent) {
                    print("✅ 点击了摧毁按钮")
                    handleDestroyButtonTap()
                    return
                } else {
                    print("❌ 点击位置不在摧毁按钮内")
                }
            } else {
                print("❌ 摧毁按钮没有父节点")
            }
        } else {
            print("没有摧毁按钮存在")
        }

        // 遍历所有网格单元格，检查点击位置是否在单元格内
        for row in gridCells {
            for cell in row {
                // 将点击位置转换为单元格坐标系
                let locationInCell = self.convert(sceneLocation, to: cell)

                // 检查点击位置是否在单元格内
                if cell.contains(locationInCell) {
                    print("点击了单元格: row=\(cell.row), column=\(cell.column)")

                    // 高亮显示
                    cell.highlight()

                    // 如果单元格可建造且没有炮塔，显示建造面板
                    if cell.isBuildable && !cell.hasTower {
                        print("点击可建造单元格，显示建造面板")
                        // 隐藏摧毁按钮
                        hideDestroyButton()

                        // 保存选中的格子
                        selectedCell = cell

                        // 更新选中的格子并显示面板
                        buildPanel.updateSelectedCell(cell)
                        buildPanel.show()
                    } else if cell.isBuildable && cell.hasTower {
                        print("点击有炮塔的单元格，显示摧毁按钮")
                        // 隐藏建造面板
                        buildPanel.hide()
                        selectedCell = nil

                        // 显示摧毁按钮
                        showDestroyButton(for: cell)
                    } else {
                        print("单元格不满足条件: isBuildable=\(cell.isBuildable), hasTower=\(cell.hasTower)")
                        // 隐藏所有UI
                        hideDestroyButton()
                        buildPanel.hide()
                        selectedCell = nil
                    }

                    // 找到了单元格，不需要继续遍历
                    return
                }
            }
        }

        // 如果点击了其他区域，隐藏建造面板和摧毁按钮
        print("点击了其他区域，隐藏建造面板和摧毁按钮")
        buildPanel.hide()
        hideDestroyButton()
        selectedCell = nil
    }

    // BuildPanelDelegate方法：处理炮塔选择
    func didSelectTower(_ towerType: TowerType) {
        // 确保有选中的格子
        guard let cell = selectedCell else { return }

        // 获取炮塔价格
        let towerPrice = PlayerEconomyManager.shared.getTowerPrice(type: towerType)

        // 检查是否有足够的金币
        if !PlayerEconomyManager.shared.canAfford(towerPrice) {
            print("金币不足，无法建造炮塔")

            // 播放错误音效
            let errorSoundAction = SKAction.playSoundFileNamed("error.mp3", waitForCompletion: false)
            run(errorSoundAction)

            // 显示金币不足提示（可选）
            showInsufficientFundsMessage()

            return
        }

        // 创建选中类型的炮塔
        if let tower = TowerFactory.shared.createTower(type: towerType) {
            // 尝试放置炮塔
            if cell.placeTower(tower) {
                // 扣除金币
                if PlayerEconomyManager.shared.spendFunds(towerPrice) {
                    // 放置成功，播放音效
                    let placeSoundAction = SKAction.playSoundFileNamed("tower_place.mp3", waitForCompletion: false)
                    run(placeSoundAction)

                    // 清除选中的格子
                    selectedCell = nil

                    // 隐藏建造面板
                    buildPanel.hide()
                } else {
                    // 金币不足（理论上不会发生，因为前面已经检查过）
                    cell.removeTower()
                }
            }
        }
    }

    // 显示金币不足提示
    private func showInsufficientFundsMessage() {
        // 创建提示标签
        let messageLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        messageLabel.text = "金币不足!"
        messageLabel.fontSize = 30
        messageLabel.fontColor = .red
        messageLabel.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        messageLabel.zPosition = 2000
        addChild(messageLabel)

        // 创建动画序列
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])

        // 运行动画
        messageLabel.alpha = 0
        messageLabel.run(sequence)
    }

    // PlayerEconomyDelegate方法：处理金币变化
    func fundsDidChange(newAmount: Int) {
        // 更新金币显示
        currencyLabel.text = "\(newAmount)"

        // 添加简单的动画效果
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        currencyLabel.run(sequence)
    }

    // MARK: - 摧毁按钮管理

    // 显示摧毁按钮
    private func showDestroyButton(for cell: GridCell) {
        // 隐藏现有的摧毁按钮
        hideDestroyButton()

        // 确保格子有炮塔
        guard let tower = cell.currentTower else {
            print("格子没有炮塔，无法显示摧毁按钮")
            return
        }

        // 保存选中的炮塔
        selectedTowerForDestroy = tower

        // 创建摧毁按钮
        createDestroyButton(for: tower, in: cell)

        print("显示摧毁按钮")
    }

    // 创建摧毁按钮
    private func createDestroyButton(for tower: Defend, in cell: GridCell) {

        // 创建圆形按钮
        let buttonRadius: CGFloat = 10
        destroyButton = SKShapeNode(circleOfRadius: buttonRadius)

        guard let button = destroyButton else {
            print("错误：无法创建摧毁按钮")
            return
        }

        // 设置按钮外观
        button.fillColor = SKColor.red.withAlphaComponent(0.8)
        button.strokeColor = SKColor.white
        button.lineWidth = 2

        // 设置按钮位置（炮塔上方）
        let towerPosition = tower.position
        let buttonPosition = CGPoint(
            x: towerPosition.x,
            y: towerPosition.y + buttonRadius
        )
        button.position = buttonPosition

        print("按钮位置: \(buttonPosition)")

        // 设置zPosition确保显示在最上层
        button.zPosition = 1000

        // 设置名称用于识别
        button.name = "destroyButton"

        // 创建X符号
        let symbolNode = SKShapeNode()
        let path = CGMutablePath()
        let symbolSize: CGFloat = buttonRadius * 0.6

        // 绘制X形状
        path.move(to: CGPoint(x: -symbolSize/2, y: -symbolSize/2))
        path.addLine(to: CGPoint(x: symbolSize/2, y: symbolSize/2))
        path.move(to: CGPoint(x: -symbolSize/2, y: symbolSize/2))
        path.addLine(to: CGPoint(x: symbolSize/2, y: -symbolSize/2))

        symbolNode.path = path
        symbolNode.strokeColor = SKColor.white
        symbolNode.lineWidth = 3
        symbolNode.position = CGPoint.zero
        symbolNode.zPosition = 1

        // 将X符号添加到按钮
        button.addChild(symbolNode)

        // 将按钮添加到格子
        cell.addChild(button)
        print("按钮已添加到格子，按钮父节点: \(button.parent?.name ?? "无名称")")


        // 添加出现动画
        button.alpha = 0
        button.setScale(0.5)

        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUpAnimation = SKAction.scale(to: 1.0, duration: 0.2)
        let showAnimation = SKAction.group([fadeIn, scaleUpAnimation])

        button.run(showAnimation)

        print("摧毁按钮创建完成")
        print("=== 创建摧毁按钮完成 ===")
    }

    // 隐藏摧毁按钮
    private func hideDestroyButton() {
        if let button = destroyButton {
            // 播放消失动画
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let scaleDown = SKAction.scale(to: 0.5, duration: 0.2)
            let hideAnimation = SKAction.group([fadeOut, scaleDown])

            let removeAction = SKAction.run {
                button.removeFromParent()
            }

            button.run(SKAction.sequence([hideAnimation, removeAction]))

            destroyButton = nil
            selectedTowerForDestroy = nil

            print("隐藏摧毁按钮")
        }
    }

    // 处理摧毁按钮点击
    private func handleDestroyButtonTap() {
        print("=== 开始处理摧毁按钮点击 ===")

        guard let tower = selectedTowerForDestroy else {
            print("错误：没有选中要摧毁的炮塔")
            return
        }

        print("选中的炮塔: \(tower.name ?? "未知炮塔")")

        // 获取炮塔所在的格子
        guard let gridCell = tower.parent as? GridCell else {
            print("错误：炮塔不在格子中，父节点类型: \(type(of: tower.parent))")
            return
        }

        print("炮塔所在格子: row=\(gridCell.row), column=\(gridCell.column)")
        print("手动摧毁炮塔: \(tower.name ?? "未知炮塔")")

        // 播放摧毁音效
        let destroySoundAction = SKAction.playSoundFileNamed("tower_destroy.mp3", waitForCompletion: false)
        run(destroySoundAction)

        // 隐藏摧毁按钮
        hideDestroyButton()

        // 摧毁炮塔（不给予资金奖励）
        print("调用gridCell.removeTower()")
        gridCell.removeTower()

        print("炮塔已被手动摧毁，格子恢复为可建造状态")
        print("=== 摧毁按钮点击处理完成 ===")
    }

    // MARK: - 暂停功能

    // 处理暂停按钮点击
    private func handlePauseButtonTap() {
        print("点击了暂停按钮")

        // 检查是否可以暂停
        if gameManager.canPause() {
            // 暂停游戏
            gameManager.pauseGame()

            // 显示暂停面板
            pausePanel.show()
        } else {
            print("当前游戏状态不允许暂停")
        }
    }

    // MARK: - PausePanelDelegate

    // 暂停面板请求继续游戏
    func pausePanelDidRequestContinue() {
        print("暂停面板请求继续游戏")

        // 恢复游戏
        gameManager.resumeGame()
         // 隐藏暂停面板
        pausePanel.hide()
    }

    // 暂停面板请求退出游戏
    func pausePanelDidRequestExit() {
        print("暂停面板请求退出游戏")


        // 恢复游戏状态（避免场景切换时仍处于暂停状态）
        gameManager.resumeGame()


        // 隐藏暂停面板
        pausePanel.hide()

        // 返回关卡选择场景
        let levelSelectionScene = LevelSelectionScene(size: self.size)
        levelSelectionScene.scaleMode = .aspectFit

        // 刷新关卡按钮状态以反映最新的解锁进度
        levelSelectionScene.refreshLevelButtons()

        // 场景切换动画
        let transition = SKTransition.fade(withDuration: 1.0)

        // 切换到关卡选择场景
        if let view = self.view {
            view.presentScene(levelSelectionScene, transition: transition)
        }
    }

    // MARK: - GameEndPanelDelegate

    // 游戏结束面板请求返回
    func gameEndPanelDidRequestReturn(_ panel: GameEndPanel) {
        print("游戏结束面板请求返回关卡选择")

        // 隐藏游戏结束面板
        panel.hide()

        // 返回关卡选择场景
        let levelSelectionScene = LevelSelectionScene(size: self.size)
        levelSelectionScene.scaleMode = .aspectFit

        // 刷新关卡按钮状态以反映最新的解锁进度
        levelSelectionScene.refreshLevelButtons()

        // 场景切换动画
        let transition = SKTransition.fade(withDuration: 1.0)

        // 切换到关卡选择场景
        if let view = self.view {
            view.presentScene(levelSelectionScene, transition: transition)
        }
    }

    // 游戏结束面板请求重新开始
    func gameEndPanelDidRequestRestart(_ panel: GameEndPanel) {
        print("游戏结束面板请求重新开始游戏")

        // 隐藏游戏结束面板
        panel.hide()

        // 重新创建游戏场景
        let newGameScene = GameSceneWithGrid(size: self.size)
        newGameScene.scaleMode = .aspectFit

        // 配置相同的关卡
        newGameScene.configureLevel(level: currentLevel)

        // 场景切换动画
        let transition = SKTransition.fade(withDuration: 1.0)

        // 切换到新的游戏场景
        if let view = self.view {
            view.presentScene(newGameScene, transition: transition)
        }
    }
}
