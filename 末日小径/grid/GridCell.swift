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

    // 当前放置的炮塔
    private var tower: Defend?

    // 是否有炮塔
    var hasTower: Bool {
        return tower != nil
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

        // 确保节点可以接收触摸事件
        self.isUserInteractionEnabled = false  // 改为false，让触摸事件传递到父节点

        // 创建内部小方块
        createInnerSquare()

        // 初始外观
        updateAppearance()

        print("创建GridCell: row=\(row), column=\(column), size=\(size), name=\(self.name ?? "无名称")")
    }

    // 重写触摸事件处理方法，确保打印调试信息
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("GridCell touchesBegan: row=\(row), column=\(column)")
        // 将触摸事件传递给父节点
        super.touchesBegan(touches, with: event)
    }

    // 重写 contains 方法，确保能够正确检测点击位置是否在单元格内
    override func contains(_ p: CGPoint) -> Bool {
        // 创建一个矩形，表示单元格的边界
        let rect = CGRect(x: 0, y: 0, width: cellSize.width, height: cellSize.height)

        // 检查点击位置是否在矩形内
        let result = rect.contains(p)

        print("GridCell contains: row=\(row), column=\(column), point=\(p), result=\(result)")

        return result
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 创建内部小方块（带圆角）
    private func createInnerSquare() {
        // 计算内部小方块的大小（比单元格小一些，创建间距效果）
        let padding: CGFloat = cellSize.width * 0.15 // 15%的间距
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
        square.name = "inner_square"

        // 设置填充颜色（确保可见）
        square.fillColor = SKColor.green.withAlphaComponent(0.3)

        // 添加到单元格
        addChild(square)

        // 保存引用
        innerSquare = square

        print("创建内部小方块: \(square), 位置: \(square.position), 大小: \(innerWidth)x\(innerHeight), 颜色: \(square.fillColor)")
    }

    // 更新外观，根据是否可建造和是否有炮塔设置不同颜色
    private func updateAppearance() {
        if isBuildable {
            if hasTower {
                // 已有炮塔 - 浅灰色透明
                innerSquare?.fillColor = SKColor.gray.withAlphaComponent(0.2)
            } else {
                // 可建造且无炮塔 - 浅绿色透明
                innerSquare?.fillColor = SKColor.green.withAlphaComponent(0.3)
            }
            // 显示单元格
            isHidden = false
        } else {
            // 不可建造 - 完全隐藏单元格
            isHidden = true
        }
    }

    // 高亮显示（当用户触摸时）
    func highlight() {
        // 如果单元格已有炮塔，不显示高亮效果
        if hasTower {
            print("单元格已有炮塔，不显示高亮效果")
            return
        }

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

        print("显示单元格高亮效果")
    }

    // 放置炮塔
    func placeTower(_ newTower: Defend) -> Bool {
        // 如果单元格不可建造或已有炮塔，返回失败
        if !isBuildable || hasTower {
            return false
        }

        // 设置炮塔位置（单元格中心）
        newTower.position = CGPoint(x: cellSize.width / 2, y: cellSize.height / 2)

        // 将炮塔添加到单元格
        addChild(newTower)

        // 保存炮塔引用
        tower = newTower

        // 更新外观
        updateAppearance()

        return true
    }

    // 移除炮塔
    func removeTower() {
        // 如果有炮塔，移除它
        if let tower = tower {
            tower.removeFromParent()
            self.tower = nil

            // 更新外观
            updateAppearance()
        }
    }

    // 更新方法（在场景的update方法中调用）
    func update(deltaTime: TimeInterval) {
        // 如果有炮塔，更新它
        if let tower = tower {
            tower.update(deltaTime: deltaTime)
        }
    }
}
