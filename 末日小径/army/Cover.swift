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
        
        let config = towerConfigs[TowerType.cover.rawValue] ?? [:]
        let name = config["name"] as? String ?? ""
        let attackPower = config["attackPower"] as? Int ?? 30
        let fireRate = config["fireRate"] as? Double ?? 30.0
        let price = config["price"] as? Int ?? 30
        let health = config["health"] as? Int ?? 30
        let attackRange = config["attackRange"] as? CGFloat ?? 30
            

        // 使用步枪特定的属性初始化
        super.init(
            texture: texture, // 使用ResourceManager获取的纹理
            name: name,
            attackPower: attackPower,          // 攻击力
            fireRate: fireRate,           // 射速（每秒2次）
            health: health,              // 生命值
            price: price,              // 价格
            attackRange: attackRange      // 攻击范围
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
