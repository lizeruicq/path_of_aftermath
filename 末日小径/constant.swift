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
    case sword = "sword"
    case runner = "runner"
    case boomer = "boomer"
    case trans = "trans"
    case plant = "plant"

}



// 炮塔类型枚举
enum TowerType: String {
    case rifle = "rifle"       // 步枪
    case shotgun = "shotgun"       // 霰弹枪
    case supergun = "super"       // 霰弹枪
    case chaingun = "chaingun"   // 机枪
    case knife = "knife"       // 刀战
    case cover = "cover"

}

// 僵尸配置数据
let zombieConfigs: [String: [String: Any]] = [
    ZombieType.walker.rawValue: [
        "name": "行走者",
        "health": 50,
        "speed": NSNumber(value: 60.0),
        "damage": 15,
        "attackRate": 1.0,
        "rewardMoney": 2,  // 击杀奖励金币
        "scale":0.18
    ],
    
    ZombieType.runner.rawValue: [
        "name": "跑者",
        "health": 50,
        "speed": NSNumber(value: 110.0),
        "damage": 15,
        "attackRate": 1.0,
        "rewardMoney": 2,  // 击杀奖励金币
        "scale": 0.6
    ],
    
    ZombieType.plant.rawValue: [
        "name": "植物",
        "health": 100,
        "speed": NSNumber(value: 70.0),
        "damage": 30,
        "attackRate": 1.0,
        "rewardMoney": 3,  // 击杀奖励金币
        "scale":0.23
    ],
    
    ZombieType.boomer.rawValue: [
        "name": "毒气",
        "health": 200,
        "speed": NSNumber(value: 60.0),
        "damage": 20,
        "attackRate": 2.0,
        "rewardMoney": 4,  // 击杀奖励金币
        "scale":0.26
    ],
    
    ZombieType.trans.rawValue: [
        "name": "化身",
        "health": 120,
        "speed": NSNumber(value: 80.0),
        "damage": 30,
        "attackRate": 1.0,
        "rewardMoney": 4,  // 击杀奖励金币
        "scale":0.23
    ],
    
    ZombieType.sword.rawValue: [
        "name": "武士",
        "health": 100,
        "speed": NSNumber(value: 110.0),
        "damage": 50,
        "attackRate": 2.0,
        "rewardMoney": 5,
        "scale":0.25
    ],
    

]

// 炮塔配置数据
let towerConfigs: [String: [String: Any]] = [
    TowerType.rifle.rawValue: [
        "name": "rifle",
        "image": "rifle_icon",
        "attackPower": 5,
        "fireRate": 1.5,
        "health": 35,
        "price": 20,
        "attackRange": NSNumber(value: 250),
    ],
    
    TowerType.knife.rawValue: [
        "name": "knife",
        "image": "knife_icon",
        "attackPower": 30,
        "fireRate": 2.0,
        "health": 65,
        "price": 20,
        "attackRange": NSNumber(value: 50),
    ],
    
    TowerType.shotgun.rawValue: [
        "name": "shotgun",
        "image": "shotgun_icon",
        "attackPower": 5,
        "fireRate": 2.0,
        "health": 50,
        "price": 30,
        "attackRange": NSNumber(value: 200),
    ],
    
    TowerType.chaingun.rawValue: [
        "name": "chaingun",
        "image": "chaingun_icon",
        "attackPower": 5,
        "fireRate": 3.0,
        "health": 70,
        "price": 50,
        "attackRange": NSNumber(value: 350),
    ],

    TowerType.supergun.rawValue: [
        "name": "super",
        "image": "super_icon",
        "attackPower": 35,
        "fireRate": 1.0,
        "health": 50,
        "price": 70,
        "attackRange": NSNumber(value: 300),
    ],
    
    
    TowerType.cover.rawValue: [
        "name": "cover",
        "image": "cover_icon",
        "attackPower": 0,
        "fireRate": 0,
        "health": 100,
        "price": 5,
        "attackRange": NSNumber(value: 0),
    ],

]

// 关卡结构配置
struct LevelStructure {
    static let chapters = [
        ChapterConfig(
            id: 1,
            name: "郊外",
            levels: [
                LevelInfo(id: 1, name: "丛林"),
                LevelInfo(id: 2, name: "荒原"),
                LevelInfo(id: 3, name: "湖畔"),
                LevelInfo(id: 4, name: "公路")
            ]
        ),
        ChapterConfig(
            id: 2,
            name: "市区",
            levels: [
                LevelInfo(id: 5, name: "机场"),
                LevelInfo(id: 6, name: "哨所"),
                LevelInfo(id: 7, name: "医院"),
                LevelInfo(id: 8, name: "议会")
            ]
        ),
        ChapterConfig(
            id: 3,
            name: "终章",
            levels: [
                LevelInfo(id: 9, name: "小径"),
                
            ]
        )
    ]
}

struct ChapterConfig {
    let id: Int
    let name: String
    let levels: [LevelInfo]
}

struct LevelInfo {
    let id: Int
    let name: String
}

// 关卡配置数据
let levelConfigs: [[String: Any]] = [
    [ // 第一关配置
        "level": 1,
        "initialFunds": 200, // 初始金币
        "waves": [
              // walker僵尸
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "count": 5
                ],
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "count": 10
                ],
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "count": 30
                ],
                
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue

        ]
    ],
    [ // 第二关配置
        "level": 2,
        "initialFunds": 200, // 初始金币
        "waves": [
            [
                "enemyType1": ZombieType.walker.rawValue,
                "count": 5
            ],
            [
                "enemyType1": ZombieType.walker.rawValue,
                "count": 10
            ],
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "count": 10
            ],
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "count": 15
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "count": 5
            ],

        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue
        ]
    ],
    [ // 第三关配置
        "level": 3,
        "initialFunds": 300,
        "waves": [
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "count": 20
            ],
            [
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.plant.rawValue,
                "count": 30
            ],
            [
                "enemyType3": ZombieType.plant.rawValue,
                "count": 40
            ],
            [
                "enemyType3": ZombieType.plant.rawValue,
                "count": 60
            ],
           

        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第四关配置
        "level": 4,
        "initialFunds": 500,
        "waves": [
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.plant.rawValue,
                "count": 10
            ],
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.boomer.rawValue,
                "enemyType4": ZombieType.plant.rawValue,
                "count": 20
            ],
            [
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.boomer.rawValue,
                "enemyType4": ZombieType.plant.rawValue,
                "count": 30
            ],
            [
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.boomer.rawValue,
                "count": 40
            ],
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue

        ]
    ],
    [ // 第五关配置
        "level": 5,
        "initialFunds": 600,
        "waves": [
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.plant.rawValue,
                "enemyType3": ZombieType.runner.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.boomer.rawValue,
                "enemyType2": ZombieType.plant.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.boomer.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 50
            ],
            
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.supergun.rawValue
        ]
    ],
    [ // 第六关配置
        "level": 6,
        "initialFunds": 800,
        "waves": [
            [
                "enemyType2": ZombieType.boomer.rawValue,
                "enemyType3": ZombieType.runner.rawValue,
                "count": 20
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.runner.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.boomer.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.trans.rawValue,
                "count": 30
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.boomer.rawValue,
                "count": 30
            ],
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.supergun.rawValue
        ]
    ],
    [ // 第七关配置
        "level": 7,
        "initialFunds": 800,
        "waves": [
            [
                "enemyType1": ZombieType.plant.rawValue,
                "enemyType2": ZombieType.trans.rawValue,
                "count": 20
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "count": 50
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.boomer.rawValue,
                "enemyType3": ZombieType.sword.rawValue,
                "count": 40
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.sword.rawValue,
                "count": 50
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "count": 50
            ],
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.supergun.rawValue
        ]
    ],
    [ // 第八关配置
        "level": 8,
        "initialFunds": 800,
        "waves": [
            [
                "enemyType1": ZombieType.runner.rawValue,
                "count": 50
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.boomer.rawValue,
                "count": 60
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.trans.rawValue,
                "count": 70
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "count": 80
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "count": 90
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "count": 100
            ],
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.supergun.rawValue
        ]
    ],
    [ // 第九关配置
        "level": 9,
        "initialFunds": 1000,
        "waves": [
            [
                "enemyType1": ZombieType.walker.rawValue,
                "enemyType4": ZombieType.trans.rawValue,
                "enemyType5": ZombieType.boomer.rawValue,
                "enemyType6": ZombieType.plant.rawValue,
                "count": 100
            ],
            [
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.runner.rawValue,
                "enemyType4": ZombieType.trans.rawValue,
                "count": 100
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "enemyType2": ZombieType.trans.rawValue,
                "count": 100
            ],
            [
                "enemyType1": ZombieType.runner.rawValue,
                "enemyType2": ZombieType.boomer.rawValue,
                "count": 100
            ],
            [
                "enemyType2": ZombieType.sword.rawValue,
                "count": 100
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.runner.rawValue,
                "enemyType4": ZombieType.trans.rawValue,
                "enemyType5": ZombieType.boomer.rawValue,
                "enemyType6": ZombieType.runner.rawValue,
                "count": 200
            ],
            [
                "enemyType1": ZombieType.sword.rawValue,
                "enemyType2": ZombieType.sword.rawValue,
                "enemyType3": ZombieType.runner.rawValue,
                "enemyType4": ZombieType.boomer.rawValue,
                "count": 300
            ],
        ],
        "availableTowers": [
            TowerType.cover.rawValue,
            TowerType.rifle.rawValue,
            TowerType.knife.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.supergun.rawValue
        ]
    ],
    
]
