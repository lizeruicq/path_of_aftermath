//
//  PlayerEconomyManager.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

protocol PlayerEconomyDelegate: AnyObject {
    func fundsDidChange(newAmount: Int)
}

class PlayerEconomyManager {
    // 单例模式
    static let shared = PlayerEconomyManager()
    
    // 当前金币数量
    private(set) var currentFunds: Int = 0
    
    // 委托，用于通知金币变化
    weak var delegate: PlayerEconomyDelegate?
    
    // 私有初始化方法
    private init() {}
    
    // 初始化关卡资金
    func initializeForLevel(_ level: Int) {
        // 从关卡配置中获取初始资金
        if let levelConfig = levelConfigs.first(where: { ($0["level"] as? Int) == level }),
           let initialFunds = levelConfig["initialFunds"] as? Int {
            currentFunds = initialFunds
            print("初始化关卡\(level)资金: \(currentFunds)")
            
            // 通知委托
            notifyFundsChanged()
        } else {
            // 如果找不到配置，使用默认值
            currentFunds = 500
            print("未找到关卡\(level)的资金配置，使用默认值: \(currentFunds)")
            
            // 通知委托
            notifyFundsChanged()
        }
    }
    
    // 增加金币
    func addFunds(_ amount: Int) {
        guard amount > 0 else { return }
        
        currentFunds += amount
        print("增加金币: +\(amount), 当前金币: \(currentFunds)")
        
        // 通知委托
        notifyFundsChanged()
    }
    
    // 消费金币
    func spendFunds(_ amount: Int) -> Bool {
        guard amount > 0 else { return false }
        
        // 检查是否有足够的金币
        if currentFunds >= amount {
            currentFunds -= amount
            print("消费金币: -\(amount), 当前金币: \(currentFunds)")
            
            // 通知委托
            notifyFundsChanged()
            return true
        } else {
            print("金币不足，无法消费: 需要\(amount), 当前\(currentFunds)")
            return false
        }
    }
    
    // 检查是否能够支付
    func canAfford(_ amount: Int) -> Bool {
        return currentFunds >= amount
    }
    
    // 获取炮塔价格
    func getTowerPrice(type: TowerType) -> Int {
        if let towerConfig = towerConfigs[type.rawValue],
           let price = towerConfig["price"] as? Int {
            return price
        }
        return 0
    }
    
    // 通知委托金币变化
    private func notifyFundsChanged() {
        delegate?.fundsDidChange(newAmount: currentFunds)
    }
}
