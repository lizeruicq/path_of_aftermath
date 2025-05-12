//
//  GridCell.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class GridCell: SKShapeNode {
    
    // 网格位置（行和列）
    let row: Int
    let column: Int
    
    // 是否可以建造
    var isBuildable: Bool = false {
        didSet {
            updateAppearance()
        }
    }
    
    // 初始化方法
    init(row: Int, column: Int, size: CGSize) {
        self.row = row
        self.column = column
        
        super.init()
        
        // 创建矩形形状
        let rect = CGRect(origin: .zero, size: size)
        self.path = CGPath(rect: rect, transform: nil)
        
        // 设置基本属性
        self.lineWidth = 1.0
        self.strokeColor = SKColor.darkGray
        
        // 设置名称，用于识别
        self.name = "cell_\(row)_\(column)"
        
        // 初始外观
        updateAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 更新外观，根据是否可建造设置不同颜色
    private func updateAppearance() {
        if isBuildable {
            // 可建造 - 浅绿色透明
            self.fillColor = SKColor.green.withAlphaComponent(0.1)
        } else {
            // 不可建造 - 浅红色透明
            self.fillColor = SKColor.red.withAlphaComponent(0.0)
        }
    }
    
    // 高亮显示（当用户触摸时）
    func highlight() {
        let highlightAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.7, duration: 0.1),
            SKAction.fadeAlpha(to: 0.3, duration: 0.1)
        ])
        
        self.run(highlightAction)
    }
}
