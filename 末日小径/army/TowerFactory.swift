//
//  TowerFactory.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class TowerFactory {
    // 单例模式
    static let shared = TowerFactory()
    
    // 私有初始化方法
    private init() {}
    
    // 根据类型创建炮塔
    func createTower(type: TowerType) -> Defend? {
        switch type {
        case .rifle:
            return Rifle()
        case .shotgun:
            return ShotGun()
        case .supergun:
            return Super()
        case .chaingun:
            return Chaingun()
        case .knife:
            return Knife()
        case .cover:
            return Cover()

        }
    }
    
    // 获取当前关卡可用的炮塔类型
    func getAvailableTowerTypes(forLevel level: Int) -> [TowerType] {
        // 查找当前关卡配置
        guard let levelConfig = levelConfigs.first(where: { ($0["level"] as? Int) == level }) else {
            return [.rifle] // 默认只提供步枪
        }
        
        // 获取可用炮塔类型
        guard let availableTowerStrings = levelConfig["availableTowers"] as? [String] else {
            return [.rifle] // 默认只提供步枪
        }
        
        // 将字符串转换为TowerType枚举
        var towerTypes: [TowerType] = []
        for towerString in availableTowerStrings {
            if let towerType = TowerType(rawValue: towerString) {
                towerTypes.append(towerType)
            }
        }
        
        return towerTypes
    }
    
    // 获取炮塔配置
    func getTowerConfig(for type: TowerType) -> [String: Any]? {
        return towerConfigs[type.rawValue]
    }
}
