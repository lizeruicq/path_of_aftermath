//
//  cover.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class Cover: Defend {
    

  
    // 初始化方法
    init() {
        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: "cover")

        
        super.init(
            texture: texture, // 使用ResourceManager获取的纹理
            name: "掩体",
            attackPower: 0,          // 攻击力
            fireRate: 0,           // 射速（每秒2次）
            health: 100,              // 生命值
            price: 20,              // 价格
            attackRange: 0       // 攻击范围
        )

        // 设置刀战特有的属性
        self.setScale(1) // 调整大小
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 攻击目标
    override func attackTarget(_ target: Zombie) {
        return

    }

    
    
    
}
