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

// 僵尸配置数据
let zombieConfigs: [String: [String: Any]] = [
    ZombieType.walker.rawValue: [
        "name": "行走者",
        "health": 30,
        "speed": 30,
        "damage": 10,
        "attackRate": 1.0,
        "rewardMoney": 50  // 击杀奖励金币
    ]
    // 未来可以添加更多僵尸类型的配置
    // "runner": [
    //     "name": "奔跑者",
    //     "health": 5,
    //     "speed": 20,
    //     "damage": 5,
    //     "attackRate": 1.0,
    //     "rewardMoney": 15
    // ],
    // "tank": [
    //     "name": "坦克",
    //     "health": 100,
    //     "speed": 5,
    //     "damage": 15,
    //     "attackRate": 1.0,
    //     "rewardMoney": 25
    // ]
]

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
        "attackRange": 300.0
    ],

    TowerType.shotgun.rawValue: [
        "name": "霰弹枪手",
        "image": "shotgun_idle",
        "attackPower": 5,
        "fireRate": 1.0,
        "health": 50,
        "price": 150,
        "attackRange": 300.0
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
        ),
        ChapterConfig(
            id: 3,
            name: "盐湖城",
            levels: [
                LevelInfo(id: 9, name: "郊区"),
                LevelInfo(id: 10, name: "工厂"),
                LevelInfo(id: 11, name: "大桥"),
                LevelInfo(id: 12, name: "终点")
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
        "initialFunds": 500, // 初始金币
        "waves": [
            [ // walker僵尸
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 20
            ],
            [ // walker僵尸
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 30
            ]
        ],
        "availableTowers": [
            TowerType.rifle.rawValue

        ]
    ],
    [ // 第二关配置
        "level": 2,
        "initialFunds": 700, // 初始金币
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
    ],
    [ // 第三关配置
        "level": 3,
        "initialFunds": 800,
        "waves": [
            [
                "enemyType": ZombieType.walker.rawValue,
                "count": 25
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
