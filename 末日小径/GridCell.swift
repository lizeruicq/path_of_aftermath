//
//  GridCell.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit
import UIKit

class GridCell: SKNode {

    // 网格位置（行和列）
    let row: Int
    let column: Int

    // 内部小方块节点
    private var innerSquare: SKShapeNode?

    // 是否可以建造
    var isBuildable: Bool = false {
        didSet {
            updateAppearance()
        }
    }

    // 单元格大小
    private var cellSize: CGSize

    // 初始化方法
    init(row: Int, column: Int, size: CGSize) {
        self.row = row
        self.column = column
        self.cellSize = size

        super.init()

        // 设置名称，用于识别
        self.name = "cell_\(row)_\(column)"

        // 创建内部小方块
        createInnerSquare()

        // 初始外观
        updateAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 创建内部小方块（带圆角）
    private func createInnerSquare() {
        // 计算内部小方块的大小（比单元格小一些，创建间距效果）
        let padding: CGFloat = cellSize.width * 0.05 // 15%的间距
        let innerWidth = cellSize.width - (padding * 2)
        let innerHeight = cellSize.height - (padding * 2)

        // 计算圆角半径（使用小方块宽度的25%作为圆角半径）
        let cornerRadius = innerWidth * 0.25

        // 创建带圆角的矩形路径
        let rect = CGRect(x: 0, y: 0, width: innerWidth, height: innerHeight)
        let roundedRect = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)

        // 创建内部小方块
        let square = SKShapeNode(path: roundedRect.cgPath)
        square.position = CGPoint(
            x: cellSize.width / 2 - innerWidth / 2,
            y: cellSize.height / 2 - innerHeight / 2
        )
        square.lineWidth = 0 // 不显示边框

        // 添加到单元格
        addChild(square)

        // 保存引用
        innerSquare = square
    }

    // 更新外观，根据是否可建造设置不同颜色
    private func updateAppearance() {
        if isBuildable {
            // 可建造 - 浅绿色透明
            innerSquare?.fillColor = SKColor.green.withAlphaComponent(0.1)
            // 显示单元格
            isHidden = false
        } else {
            // 不可建造 - 完全隐藏单元格
            isHidden = true
        }
    }

    // 高亮显示（当用户触摸时）
    func highlight() {
        guard let square = innerSquare else { return }

        // 创建缩放效果
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)

        // 创建颜色变化效果
        let brighten = SKAction.run { square.fillColor = SKColor.green.withAlphaComponent(0.6) }
        let restore = SKAction.run { square.fillColor = SKColor.green.withAlphaComponent(0.3) }

        // 组合动作
        let highlightAction = SKAction.sequence([
            SKAction.group([scaleUp, brighten]),
            SKAction.wait(forDuration: 0.1),
            SKAction.group([scaleDown, restore])
        ])

        square.run(highlightAction)
    }
}
