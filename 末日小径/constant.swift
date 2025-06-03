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

// 僵尸配置数据
let zombieConfigs: [String: [String: Any]] = [
    ZombieType.walker.rawValue: [
        "name": "行走者",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,  // 击杀奖励金币
        "scale":0.18
    ],
    ZombieType.sword.rawValue: [
        "name": "武士",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,
        "scale":0.25
    ],
    ZombieType.runner.rawValue: [
        "name": "跑者",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,  // 击杀奖励金币
        "scale": 0.6
    ],
    ZombieType.boomer.rawValue: [
        "name": "毒气",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,  // 击杀奖励金币
        "scale":0.26
    ],
    ZombieType.trans.rawValue: [
        "name": "化身",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,  // 击杀奖励金币
        "scale":0.23
    ],
    ZombieType.plant.rawValue: [
        "name": "植物",
        "health": 50,
        "speed": NSNumber(value: 50.0),
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50,  // 击杀奖励金币
        "scale":0.23
    ]

]

// 炮塔类型枚举
enum TowerType: String {
    case rifle = "rifle"       // 步枪
    case shotgun = "shotgun"       // 霰弹枪
    case supergun = "super"       // 霰弹枪
    case chaingun = "chaingun"   // 机枪
    case knife = "knife"       // 刀战
    case cover = "cover"

}

// 炮塔配置数据
let towerConfigs: [String: [String: Any]] = [
    TowerType.rifle.rawValue: [
        "name": "步枪手",
        "image": "rifle_icon",
        "attackPower": 3,
        "fireRate": 2.0,
        "health": 50,
        "price": 10,
        "attackRange": 400.0
    ],
    
    TowerType.chaingun.rawValue: [
        "name": "机枪手",
        "image": "chaingun_icon",
        "attackPower": 2,
        "fireRate": 6.0,
        "health": 50,
        "price": 20,
        "attackRange": 400.0
    ],

    TowerType.shotgun.rawValue: [
        "name": "霰弹枪手",
        "image": "shotgun_icon",
        "attackPower": 3,
        "fireRate": 1.0,
        "health": 50,
        "price": 15,
        "attackRange": 200.0
    ],
    
    TowerType.supergun.rawValue: [
        "name": "超级战士",
        "image": "super_icon",
        "attackPower": 5,
        "fireRate": 1.0,
        "health": 50,
        "price": 15,
        "attackRange": 300.0
    ],
    
    TowerType.knife.rawValue: [
        "name": "刀战手",
        "image": "knife_icon",
        "attackPower": 10,
        "fireRate": 2.0,
        "health": 50,
        "price": 10,
        "attackRange": 50.0
    ],
    
    TowerType.cover.rawValue: [
        "name": "掩体",
        "image": "cover_icon",
        "attackPower": 0,
        "fireRate": 0,
        "health": 100,
        "price": 20,
        "attackRange": 0
    ],

]

// 关卡结构配置
struct LevelStructure {
    static let chapters = [
        ChapterConfig(
            id: 1,
            name: "西雅图",
            levels: [
                LevelInfo(id: 1, name: "黎明"),
                LevelInfo(id: 2, name: "街道"),
                LevelInfo(id: 3, name: "商场"),
                LevelInfo(id: 4, name: "港口")
            ]
        ),
        ChapterConfig(
            id: 2,
            name: "杰克逊",
            levels: [
                LevelInfo(id: 5, name: "农场"),
                LevelInfo(id: 6, name: "小镇"),
                LevelInfo(id: 7, name: "学校"),
                LevelInfo(id: 8, name: "医院")
            ]
        )
//        ChapterConfig(
//            id: 3,
//            name: "盐湖城",
//            levels: [
//                LevelInfo(id: 9, name: "郊区"),
//                LevelInfo(id: 10, name: "工厂"),
//                LevelInfo(id: 11, name: "大桥"),
//                LevelInfo(id: 12, name: "终点")
//            ]
//        )
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
        "initialFunds": 500, // 初始金币
        "waves": [
              // walker僵尸
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "enemyType2": ZombieType.sword.rawValue,
                    "enemyType3": ZombieType.runner.rawValue,
                    "enemyType4": ZombieType.trans.rawValue,
                    "enemyType5": ZombieType.boomer.rawValue,
                    "enemyType6": ZombieType.plant.rawValue,
                    "count": 50
                ],
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "enemyType2": ZombieType.sword.rawValue,
                    "enemyType3": ZombieType.runner.rawValue,
                    "enemyType4": ZombieType.trans.rawValue,
                    "enemyType5": ZombieType.boomer.rawValue,
                    "enemyType6": ZombieType.plant.rawValue,
                    "count": 50
                ],
                [
                    "enemyType1": ZombieType.walker.rawValue,
                    "enemyType2": ZombieType.sword.rawValue,
                    "enemyType3": ZombieType.runner.rawValue,
                    "enemyType4": ZombieType.trans.rawValue,
                    "enemyType5": ZombieType.boomer.rawValue,
                    "enemyType6": ZombieType.plant.rawValue,
                    "count": 50
                ]
                    
            
            
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue,
            TowerType.supergun.rawValue,
            TowerType.chaingun.rawValue,
            TowerType.knife.rawValue,
            TowerType.cover.rawValue

        ]
    ],
    [ // 第二关配置
        "level": 2,
        "initialFunds": 700, // 初始金币
        "waves": [
            [
                [
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 20
                ],
                [
                    "enemyType": ZombieType.sword.rawValue,
                    "count": 10
                ]
            ],
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue,

        ]
    ],
    [ // 第三关配置
        "level": 3,
        "initialFunds": 800,
        "waves": [
            [
                [
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 20
                ],
                [
                    "enemyType": ZombieType.sword.rawValue,
                    "count": 10
                ]
            ],
            [
                [
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 25
                ],
                [
                    "enemyType": ZombieType.sword.rawValue,
                    "count": 10
                ]
            ],
            
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 35
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第四关配置
        "level": 4,
        "initialFunds": 900,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 30
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 40
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第五关配置
        "level": 5,
        "initialFunds": 1000,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 35
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 45
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第六关配置
        "level": 6,
        "initialFunds": 1100,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 40
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 50
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第七关配置
        "level": 7,
        "initialFunds": 1200,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 45
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 55
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第八关配置
        "level": 8,
        "initialFunds": 1300,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 50
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 60
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第九关配置
        "level": 9,
        "initialFunds": 1400,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 55
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 65
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第十关配置
        "level": 10,
        "initialFunds": 1500,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 60
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 70
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第十一关配置
        "level": 11,
        "initialFunds": 1600,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 65
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 75
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ],
    [ // 第十二关配置
        "level": 12,
        "initialFunds": 1700,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 70
            ],
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 80
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue,
            TowerType.shotgun.rawValue
        ]
    ]
]
