//
//  GameSceneWithGrid.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/2.
//

import SpriteKit
import GameplayKit

class GameSceneWithGrid: GameScene, BuildPanelDelegate {

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
    }

    // 设置建造面板
    private func setupBuildPanel() {
        // 创建建造面板
        buildPanel = BuildPanel(size: self.size)
        buildPanel.delegate = self

        // 添加到场景
        addChild(buildPanel)
    }

    // 设置背景
    private func setupBackground() {
        // 创建背景精灵节点
        backgroundNode = SKSpriteNode(color: SKColor.black, size: self.size)

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

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

                    print("添加单元格: row=\(row), column=\(column), position=\(cell.position)")

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
                        // 保存选中的格子
                        selectedCell = cell

                        // 配置并显示建造面板
                        buildPanel.configure(forLevel: currentLevel, selectedCell: cell)
                        buildPanel.show()
                    } else {
                        print("单元格不满足条件: isBuildable=\(cell.isBuildable), hasTower=\(cell.hasTower)")
                    }

                    // 找到了单元格，不需要继续遍历
                    return
                }
            }
        }

        // 如果点击了其他区域，隐藏建造面板
        print("点击了其他区域，隐藏建造面板")
        buildPanel.hide()
        selectedCell = nil
    }

    // BuildPanelDelegate方法：处理炮塔选择
    func didSelectTower(_ towerType: TowerType) {
        // 确保有选中的格子
        guard let cell = selectedCell else { return }

        // 创建选中类型的炮塔
        if let tower = TowerFactory.shared.createTower(type: towerType) {
            // 尝试放置炮塔
            if cell.placeTower(tower) {
                // 放置成功，播放音效
                let placeSoundAction = SKAction.playSoundFileNamed("tower_place.mp3", waitForCompletion: false)
                run(placeSoundAction)

                // 清除选中的格子
                selectedCell = nil
            }
        }
    }
}
