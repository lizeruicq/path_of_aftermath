//
//  constant.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/14.
//

import Foundation

// 僵尸类型枚举
enum ZombieType: String {
    case walker = "walker"
//    case runner = "runner"
//    case tank = "tank"
}

// 炮塔类型枚举
enum TowerType: String {
    case rifle = "rifle"       // 步枪
    case shotgun = "shotgun"       // 霰弹枪
//    case machineGun = "machineGun"  // 机关枪
//    case sniper = "sniper"     // 狙击枪
//    case rocket = "rocket"     // 火箭炮
}

// 炮塔配置数据
let towerConfigs: [String: [String: Any]] = [
    TowerType.rifle.rawValue: [
        "name": "步枪手",
        "image": "rifle_idle",
        "attackPower": 5,
        "fireRate": 2.0,
        "health": 50,
        "price": 100,
        "attackRange": 200.0
    ],
    
    TowerType.shotgun.rawValue: [
        "name": "霰弹枪手",
        "image": "shotgun_idle",
        "attackPower": 5,
        "fireRate": 1.0,
        "health": 50,
        "price": 150,
        "attackRange": 100.0
    ],
    
//    TowerType.machineGun.rawValue: [
//        "name": "机关枪",
//        "image": "machinegun_tower",
//        "attackPower": 3,
//        "fireRate": 5.0,
//        "health": 40,
//        "price": 200,
//        "attackRange": 150.0
//    ],
//    TowerType.sniper.rawValue: [
//        "name": "狙击枪",
//        "image": "sniper_tower",
//        "attackPower": 20,
//        "fireRate": 0.5,
//        "health": 30,
//        "price": 300,
//        "attackRange": 350.0
//    ],
//    TowerType.rocket.rawValue: [
//        "name": "火箭炮",
//        "image": "rocket_tower",
//        "attackPower": 15,
//        "fireRate": 1.0,
//        "health": 60,
//        "price": 400,
//        "attackRange": 250.0
//    ]
]

// 关卡配置数据
let levelConfigs: [[String: Any]] = [
    [ // 第一关配置
        "level": 1,
        "waves": [
            [ // walker僵尸
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 5
            ],
        ],
        "availableTowers": [
            TowerType.rifle.rawValue
            
        ]
    ],
    [ // 第二关配置
        "level": 2,
        "waves": [
            [ // 第一波敌人
                [ // walker僵尸
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 3
                ],
                
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue,
//            TowerType.machineGun.rawValue,
//            TowerType.sniper.rawValue,
//            TowerType.rocket.rawValue
        ]
    ]
]
