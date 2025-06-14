//
//  Rifle.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class Super: Defend {
    // 子弹速度
    private let bulletSpeed: CGFloat = 1500.0

    // 子弹大小
    private let bulletSize = CGSize(width: 15, height: 3)

    // 子弹颜色
    private var bulletColor = SKColor.cyan

    // 初始化方法
    init() {
        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: "super_idle")
        let config = towerConfigs[TowerType.supergun.rawValue] ?? [:]
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

        // 设置步枪特有的属性
        self.setScale(1.7) // 调整大小
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 攻击目标
    override func attackTarget(_ target: Zombie) {
        // 播放射击动画
        playShootAnimation()

        // 创建子弹
        let bullet = SKShapeNode(rectOf: bulletSize)
        bullet.fillColor = bulletColor
        bullet.strokeColor = bulletColor
        bullet.zPosition = 150  // 设置子弹的zPosition高于僵尸，确保可见
        bullet.name = "bullet"

        // 设置子弹垂直向上（-90度，即π/2弧度）
        bullet.zRotation = -CGFloat.pi / 2

        // 获取场景和父节点
        guard let scene = self.scene, let parent = self.parent else { return }

        // 将炮塔位置转换到场景坐标系
        let towerPositionInScene = parent.convert(self.position, to: scene)

        // 设置子弹初始位置在炮塔上方一点（Y坐标增加20）
        bullet.position = CGPoint(x: towerPositionInScene.x + 10, y: towerPositionInScene.y + 20)

        // 添加子弹到场景
        scene.addChild(bullet)

        // 计算子弹飞行距离和时间
        let distance = self.attackRange
        let duration = TimeInterval(distance / bulletSpeed)

        // 计算目标位置（直线向上）
        let targetY = towerPositionInScene.y + distance
        let targetPosition = CGPoint(x: towerPositionInScene.x, y: targetY)

        // 创建子弹移动动作
        let moveAction = SKAction.move(to: targetPosition, duration: duration)

        // 创建子弹移除动作
        let removeAction = SKAction.removeFromParent()

        // 创建子弹更新动作，用于检测碰撞
        let updateAction = SKAction.customAction(withDuration: duration) { [weak self] (node, elapsedTime) in
            guard let bullet = node as? SKShapeNode,
                  let self = self,
                  let scene = bullet.scene else { return }

            // 获取所有活着的僵尸
            let zombies = GameManager.shared.activeZombies

            // 检查是否与任何僵尸碰撞
            for zombie in zombies {
                // 跳过已死亡的僵尸
                if zombie.currentState == .dying || zombie.parent == nil || zombie.health <= 0 {
                    continue
                }

                // 计算子弹和僵尸之间的距离
                let bulletRect = CGRect(x: bullet.position.x - self.bulletSize.width/2,
                                       y: bullet.position.y - self.bulletSize.height/2,
                                       width: self.bulletSize.width,
                                       height: self.bulletSize.height)

                let zombieRect = CGRect(x: zombie.position.x - zombie.size.width/2,
                                       y: zombie.position.y - zombie.size.height/2,
                                       width: zombie.size.width,
                                       height: zombie.size.height)

                // 如果碰撞
                if bulletRect.intersects(zombieRect) {
                    // 对僵尸造成伤害
                    GameManager.shared.zombieTakeDamage(zombie, amount: self.attackPower)

                    // 创建命中效果
                    self.createHitEffect(at: zombie.position)

                    // 移除子弹
                    bullet.removeAllActions()
                    bullet.removeFromParent()
                    return
                }
            }
        }

        // 组合动作：移动 + 持续检查碰撞
        let moveWithCheckAction = SKAction.group([
            moveAction,
            SKAction.repeat(updateAction, count: Int(duration * 60)) // 假设60fps
        ])
        
        

        // 运行子弹动作序列
        bullet.run(SKAction.sequence([moveWithCheckAction, removeAction]))
    }

    // 创建命中效果
    private func createHitEffect(at position: CGPoint) {
        // 创建命中特效（小型爆炸）
        let hitEffect = SKEmitterNode()

        // 配置粒子系统
       hitEffect.particleTexture = SKTexture(imageNamed: "spark") // 使用火花图片
        hitEffect.particleBirthRate = 20
        hitEffect.numParticlesToEmit = 10
        hitEffect.particleLifetime = 0.2
        hitEffect.particleLifetimeRange = 0.1
        hitEffect.emissionAngle = 0
        hitEffect.emissionAngleRange = CGFloat.pi * 2
        hitEffect.particleSpeed = 50
        hitEffect.particleSpeedRange = 20
        hitEffect.particleAlpha = 0.8
        hitEffect.particleAlphaRange = 0.2
        hitEffect.particleAlphaSpeed = -4.0
        hitEffect.particleScale = 0.2
        hitEffect.particleScaleRange = 0.1
        hitEffect.particleScaleSpeed = -0.5
        hitEffect.particleColor = bulletColor
        hitEffect.particleColorBlendFactor = 1.0
        hitEffect.particleBlendMode = .add

        // 设置位置
        hitEffect.position = position
        hitEffect.zPosition = 160  // 设置命中效果的zPosition高于子弹，确保可见

        // 添加到场景
        self.scene?.addChild(hitEffect)

        // 自动移除
        hitEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // 播放射击动画
    private func playShootAnimation() {
        // 从ResourceManager获取动画
        if let animation = ResourceManager.shared.createAnimation(forKey: "super_shoot", timePerFrame: 0.05) {
            // 播放射击动画
            self.run(animation, withKey: "shootAnimation")
        } else {
            // 如果从ResourceManager获取失败，创建备用动画
            print("警告：无法从ResourceManager获取super_shoot动画，创建备用动画")

            // 创建动画帧数组
            var frames: [SKTexture] = []

            // 加载3帧射击动画
            for i in 1...5 {
                let textureName = "super_shoot_\(i)"
                let texture = ResourceManager.shared.getTexture(named: textureName)
                frames.append(texture)
            }

            // 创建射击动画
            let shootAnimation = SKAction.animate(with: frames, timePerFrame: 0.05, resize: false, restore: true)
           
            // 播放射击动画
            self.run(shootAnimation, withKey: "shootAnimation")
        }
        playShootSound()
    }

    // 开始攻击动画
    override func startAttackingAnimation() {
        // 创建轻微的旋转动作，模拟炮塔瞄准
        let rotateRight = SKAction.rotate(byAngle: 0.05, duration: 0.1)
        let rotateLeft = SKAction.rotate(byAngle: -0.05, duration: 0.1)
        let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])

        // 循环执行旋转动作
        self.run(SKAction.repeatForever(rotateSequence), withKey: "rotateAnimation")
    }

    // 停止攻击动画
    override func stopAttackingAnimation() {
        // 停止旋转动作
        self.removeAction(forKey: "rotateAnimation")
        self.removeAction(forKey: "shootAnimation")

        // 重置旋转角度
        self.run(SKAction.rotate(toAngle: 0, duration: 0.1))

        // 恢复原始纹理
        self.texture = ResourceManager.shared.getTexture(named: "super_idle")
    }
    
    override func updateAttackPower() {
        super.updateAttackPower()
        switch buffLevel {
        case 1:
            bulletColor = SKColor.orange
        case 2:
            bulletColor = SKColor.red
        default:
            bulletColor = SKColor.cyan
        }
    }
}
