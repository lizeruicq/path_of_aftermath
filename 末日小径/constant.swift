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
    case runner = "runner"
    case tank = "tank"
}

// 关卡配置数据
let levelConfigs: [[String: Any]] = [
    [ // 第一关配置
        "level": 1,
        "waves": [
            [ // walker僵尸
                    "enemyType": ZombieType.walker.rawValue,
                    "count": 3
            ],
            
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
                [ // tank僵尸
                    "enemyType": ZombieType.tank.rawValue,
                    "count": 4
                ],
                [ // runner僵尸
                    "enemyType": ZombieType.runner.rawValue,
                    "count": 5
                ]
            ]
        ]
    ]
]