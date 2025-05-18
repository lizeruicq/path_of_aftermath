//
//  GameManager.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit
import GameplayKit

// 游戏状态枚举
enum GameState {
    case waiting      // 等待开始
    case countdown    // 倒计时中
    case waveActive   // 波次进行中
    case completed    // 关卡完成
    case gameOver     // 游戏结束
}

class GameManager {
    // 单例模式
    static let shared = GameManager()

    // 当前游戏状态
    private(set) var gameState: GameState = .waiting

    // 当前关卡
    private(set) var currentLevel: Int = 1

    // 当前波次
    private(set) var currentWave: Int = 0

    // 当前关卡的波次配置
    private var waveConfigs: [[String: Any]] = []

    // 当前波次的僵尸配置
    private var currentWaveZombies: [[String: Any]] = []

    // 当前场景引用
    weak var gameScene: GameScene?

    // 倒计时时间（秒）
    private(set) var countdownTime: Int = 5

    // 倒计时标签
    private var countdownLabel: SKLabelNode?

    // 准备按钮
    private var readyButton: SKSpriteNode?

    // 活着的僵尸
    private var activeZombies: [Zombie] = []

    // 私有初始化方法（单例模式）
    private init() {}

    // 重置游戏管理器
    func reset() {
        gameState = .waiting
        currentWave = 0
        activeZombies.removeAll()
        countdownTime = 5
    }

    // 配置关卡
    func configureLevel(level: Int, scene: GameScene) {
        reset()
        currentLevel = level
        gameScene = scene

        // 从常量文件加载关卡配置
        loadLevelConfig()

        // 创建准备按钮
        createReadyButton()
    }

    // 从常量文件加载关卡配置
    private func loadLevelConfig() {
        // 查找当前关卡的配置
        if let levelConfig = levelConfigs.first(where: { ($0["level"] as? Int) == currentLevel }) {
            // 获取波次配置
            if let waves = levelConfig["waves"] as? [[String: Any]] {
                waveConfigs = waves
                print("已加载关卡\(currentLevel)的\(waves.count)波僵尸配置")
            }
        } else {
            print("未找到关卡\(currentLevel)的配置")
        }
    }

    // 创建准备按钮
    private func createReadyButton() {
        guard let scene = gameScene else { return }

        // 创建按钮背景
        let button = SKSpriteNode(color: .blue, size: CGSize(width: 200, height: 60))
        button.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 100)
        button.zPosition = 100
        button.name = "readyButton"

        // 创建按钮文本
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "准备完成"
        label.fontSize = 24
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.position = CGPoint.zero


        // 添加文本到按钮
        button.addChild(label)

        // 添加按钮到场景
        scene.addChild(button)

        // 保存按钮引用
        readyButton = button
    }

    // 处理准备按钮点击
    func handleReadyButtonTap() {
        // 移除准备按钮
        readyButton?.removeFromParent()
        readyButton = nil

        // 更新游戏状态
        gameState = .countdown

        // 开始第一波倒计时
        startWaveCountdown()
    }

    // 开始波次倒计时
    private func startWaveCountdown() {
        guard let scene = gameScene else { return }

        // 创建倒计时标签
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = "下一波: \(countdownTime)"
        label.fontSize = 36
        label.fontColor = .white
        label.position = CGPoint(x: scene.size.width / 2, y: scene.size.height - 100)
        label.zPosition = 100
        label.name = "countdownLabel"

        // 添加标签到场景
        scene.addChild(label)

        // 保存标签引用
        countdownLabel = label

        // 重置倒计时时间
        countdownTime = 5

        // 创建倒计时动作
        let countdown = SKAction.sequence([
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.countdownTime -= 1
                self.countdownLabel?.text = "下一波: \(self.countdownTime)"
            },
            SKAction.wait(forDuration: 1.0)
        ])

        let countdownSequence = SKAction.sequence([
            SKAction.repeat(countdown, count: 5),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.countdownLabel?.removeFromParent()
                self.countdownLabel = nil
                self.startNextWave()
            }
        ])

        // 运行倒计时动作
        label.run(countdownSequence, withKey: "countdown")
    }

    // 开始下一波僵尸
    private func startNextWave() {
        // 增加当前波次
        currentWave += 1

        // 检查是否还有波次
        if currentWave <= waveConfigs.count {
            // 更新游戏状态
            gameState = .waveActive

            // 获取当前波次的僵尸配置
            if let waveConfig = waveConfigs[currentWave - 1] as? [[String: Any]] {
                // 多种僵尸类型的情况
                currentWaveZombies = waveConfig
            } else if let waveConfig = waveConfigs[currentWave - 1] as? [String: Any] {
                // 单一僵尸类型的情况
                currentWaveZombies = [waveConfig]
            }

            // 生成僵尸
            spawnZombies()
        } else {
            // 所有波次完成
            gameState = .completed
            print("关卡完成！")
        }
    }

    // 生成僵尸
    private func spawnZombies() {
        guard let scene = gameScene else { return }

        // 计算中心三列的格子位置
        let gridColumns = 9 // 总列数
        let cellWidth = scene.size.width / CGFloat(gridColumns)

        // 中心三列的索引（3, 4, 5）
        let centerColumnIndices = [3, 4, 5]

        // 计算中心三列的X坐标位置
        var centerColumnPositions: [CGFloat] = []
        for columnIndex in centerColumnIndices {
            // 计算格子中心的X坐标
            let xPos = CGFloat(columnIndex) * cellWidth + cellWidth / 2
            centerColumnPositions.append(xPos)
        }

        // 用于跟踪每列最后一个僵尸的生成时间
        var lastSpawnTimeByColumn: [CGFloat: TimeInterval] = [:]
        // 初始化每列的最后生成时间为0
        for xPos in centerColumnPositions {
            lastSpawnTimeByColumn[xPos] = 0
        }

        // 当前总延迟时间
        var currentTotalDelay: TimeInterval = 0

        // 遍历当前波次的僵尸配置
        for zombieConfig in currentWaveZombies {
            // 获取僵尸类型和数量
            guard let typeString = zombieConfig["enemyType"] as? String,
                  let count = zombieConfig["count"] as? Int,
                  let type = ZombieType(rawValue: typeString) else {
                continue
            }

            // 生成指定数量的僵尸
            for i in 0..<count {
                // 创建僵尸
                let zombie = createZombie(type: type)

                // 随机选择中心三列之一的X坐标
                let randomIndex = Int.random(in: 0..<centerColumnPositions.count)
                let xPos = centerColumnPositions[randomIndex]

                // 计算垂直偏移，确保同一列的僵尸在垂直方向上有足够间隔
                // 使用僵尸索引来计算垂直偏移，确保每个僵尸的位置不同
                let verticalOffset = CGFloat(i) * zombie.size.height * 1.0 // 使用僵尸高度的1倍作为垂直间隔

                // 设置僵尸初始位置，添加垂直偏移
                let initialY = scene.size.height + verticalOffset
                zombie.position = CGPoint(x: xPos, y: initialY)

                // 添加僵尸到场景
                scene.addChild(zombie)

                // 添加到活动僵尸列表
                activeZombies.append(zombie)

                // 计算移动时间（基于僵尸速度）
                // 由于增加了垂直偏移，需要调整移动时间
                let totalDistance = initialY + zombie.size.height // 从初始位置到屏幕底部的总距离
                let baseDuration = TimeInterval(totalDistance / zombie.speed)

                // 不添加任何延迟，所有僵尸同时开始移动
                let totalDelay: TimeInterval = 0

                print("僵尸\(i+1)生成在x=\(xPos)，y=\(initialY)，无延迟")

                // 计算目标位置（屏幕底部以下）
                let destinationY = -zombie.size.height
                let destination = CGPoint(x: zombie.position.x, y: destinationY)

                // 直接开始移动，不添加延迟
                // 使用僵尸的startMoving方法
                zombie.startMoving(to: destination, duration: baseDuration)
                print("僵尸开始移动，从y=\(zombie.position.y)到y=\(destinationY)，持续时间=\(baseDuration)秒")
            }
        }
    }

    // 创建僵尸
    private func createZombie(type: ZombieType) -> Zombie {
        switch type {
        case .walker:
            return Walker()
//        case .runner:
//            return Runner()
//        case .tank:
//            return Tank()
        }
    }

    // 移除僵尸
    func removeZombie(_ zombie: Zombie) {
        // 从场景中移除
        zombie.removeFromParent()

        // 从活动僵尸列表中移除
        if let index = activeZombies.firstIndex(where: { $0 === zombie }) {
            activeZombies.remove(at: index)
        }

        // 检查是否所有僵尸都已移除
        checkWaveCompletion()
    }

    // 处理僵尸受到伤害
    func zombieTakeDamage(_ zombie: Zombie, amount: Int) {
        // 僵尸受到伤害
        zombie.takeDamage(amount)
    }

    // 检查波次是否完成
    private func checkWaveCompletion() {
        if activeZombies.isEmpty && gameState == .waveActive {
            // 当前波次完成，开始下一波倒计时
            gameState = .countdown
            startWaveCountdown()
        }
    }

    // 更新方法（在场景的update方法中调用）
    func update(_ currentTime: TimeInterval) {
        // 可以在这里添加额外的更新逻辑
    }

    // 处理僵尸与炮塔的碰撞
    func handleZombieTowerCollision(zombie: Zombie, tower: SKNode) {
        // 如果僵尸已经死亡，不处理碰撞
        if zombie.currentState == .dying {
            return
        }

        // 让僵尸攻击炮塔
        zombie.attack(target: tower)
    }
}
