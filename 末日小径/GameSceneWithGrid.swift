//
//  GameSceneWithGrid.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/2.
//

import SpriteKit
import GameplayKit

class GameSceneWithGrid: GameScene {

    // 网格尺寸
    let gridRows: Int = 16
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
        
        // 创建网格
        createGrid()
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
                // 创建单元格
                let cell = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellHeight))
                
                // 设置位置
                cell.position = CGPoint(x: CGFloat(col) * cellWidth + cellWidth / 2,
                                        y: CGFloat(row) * cellHeight + cellHeight / 2)
                
                // 设置样式
                cell.lineWidth = 2.0
                
                // 根据是否可建造设置颜色
                if gridConfig.isCellBuildable(row: row, column: col) {
                    cell.fillColor = buildableColor
                } else {
                    // cell.fillColor = unbuildableColor
                    // do nothing
                }
                
                // 将单元格添加到网格节点
                gridNode.addChild(cell)
            }
        }
        
        // 设置网格位置在屏幕中心
        gridNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    // 存储所有网格单元格的数组
    private var gridCells: [[GridCell]] = []

    // 网格容器节点
    private var gridContainer: SKNode!

    // 背景节点
    private var backgroundNode: SKSpriteNode?

    // 上次更新时间
    private var lastUpdateTime: TimeInterval = 0

    override func didMove(to view: SKView) {
        // 设置场景
        setupScene()

        // 加载网格配置
        loadGridConfiguration()

        // 创建网格
        setupGrid()
    }

    // 设置场景基本元素
    private func setupScene() {
        // 设置背景
        setupBackground()

        // 创建网格容器节点
        gridContainer = SKNode()
        gridContainer.position = CGPoint(x: 0, y: 0)
        gridContainer.zPosition = 10
        addChild(gridContainer)
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

        // 初始化网格单元格数组
        gridCells = Array(repeating: Array(repeating: GridCell(row: 0, column: 0, size: cellSize), count: gridColumns), count: gridRows)

        // 创建所有网格单元格
        for row in 0..<gridRows {
            for column in 0..<gridColumns {
                // 创建单元格
                let cell = GridCell(row: row, column: column, size: cellSize)

                // 设置单元格位置
                cell.position = CGPoint(x: CGFloat(column) * cellWidth, y: CGFloat(row) * cellHeight)

                // 设置是否可建造
                cell.isBuildable = gridConfig.isCellBuildable(row: row, column: column)

                // 将单元格添加到网格容器
                gridContainer.addChild(cell)

                // 存储单元格引用
                gridCells[row][column] = cell
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

        // 这里可以添加游戏逻辑更新
    }
}
