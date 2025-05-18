//
//  Rocket.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class Rocket: Defend {
    // 火箭速度
    private let rocketSpeed: CGFloat = 200.0
    
    // 火箭大小
    private let rocketSize = CGSize(width: 12, height: 6)
    
    // 火箭颜色
    private let rocketColor = SKColor.red
    
    // 爆炸范围
    private let explosionRadius: CGFloat = 80.0
    
    // 初始化方法
    init() {
        // 使用火箭炮特定的属性初始化
        super.init(
            imageName: "rocket_tower", // 火箭炮塔图片名称
            name: "火箭炮",
            attackPower: 15,         // 攻击力
            fireRate: 1.0,           // 射速（每秒1次）
            health: 60,              // 生命值
            price: 400,              // 价格
            attackRange: 250.0       // 攻击范围
        )
        
        // 设置火箭炮特有的属性
        self.setScale(0.9) // 调整大小
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 攻击目标
    override func attackTarget(_ target: Zombie) {
        // 确保目标仍然有效
        guard target.parent != nil && target.currentState != .dying else {
            return
        }
        
        // 创建火箭
        let rocket = SKShapeNode(rectOf: rocketSize)
        rocket.fillColor = rocketColor
        rocket.strokeColor = rocketColor
        rocket.zPosition = 5
        rocket.name = "rocket"
        
        // 设置火箭初始位置（炮塔位置）
        rocket.position = self.position
        
        // 计算火箭旋转角度（朝向目标）
        let dx = target.position.x - self.position.x
        let dy = target.position.y - self.position.y
        let angle = atan2(dy, dx)
        rocket.zRotation = angle
        
        // 添加火箭尾部粒子效果
        addRocketTrail(to: rocket)
        
        // 添加火箭到场景
        self.scene?.addChild(rocket)
        
        // 计算火箭飞行时间
        let distance = sqrt(dx * dx + dy * dy)
        let duration = TimeInterval(distance / rocketSpeed)
        
        // 创建火箭移动动作
        let moveAction = SKAction.move(to: target.position, duration: duration)
        
        // 创建火箭爆炸动作
        let explodeAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            // 创建爆炸效果
            self.createExplosion(at: rocket.position)
            
            // 对范围内的所有僵尸造成伤害
            self.damageZombiesInRadius(center: rocket.position, radius: self.explosionRadius)
            
            // 移除火箭
            rocket.removeFromParent()
        }
        
        // 运行火箭动作序列
        rocket.run(SKAction.sequence([moveAction, explodeAction]))
        
        // 播放发射音效
        playLaunchSound()
    }
    
    // 添加火箭尾部粒子效果
    private func addRocketTrail(to rocket: SKShapeNode) {
        // 创建尾部粒子效果
        let trail = SKEmitterNode()
        
        // 配置粒子系统
        trail.particleTexture = SKTexture(imageNamed: "spark") // 使用火花图片
        trail.particleBirthRate = 40
        trail.particleLifetime = 0.5
        trail.particleLifetimeRange = 0.2
        trail.emissionAngle = CGFloat.pi
        trail.emissionAngleRange = 0.2
        trail.particleSpeed = 20
        trail.particleSpeedRange = 10
        trail.particleAlpha = 0.7
        trail.particleAlphaRange = 0.2
        trail.particleAlphaSpeed = -1.0
        trail.particleScale = 0.2
        trail.particleScaleRange = 0.1
        trail.particleScaleSpeed = -0.2
        trail.particleColor = SKColor.orange
        trail.particleColorBlendFactor = 1.0
        trail.particleBlendMode = .add
        
        // 设置位置（火箭尾部）
        trail.position = CGPoint(x: -rocketSize.width / 2, y: 0)
        trail.zPosition = 4
        
        // 添加到火箭
        rocket.addChild(trail)
    }
    
    // 创建爆炸效果
    private func createExplosion(at position: CGPoint) {
        // 创建爆炸特效
        let explosion = SKEmitterNode()
        
        // 配置粒子系统
        explosion.particleTexture = SKTexture(imageNamed: "spark") // 使用火花图片
        explosion.particleBirthRate = 500
        explosion.numParticlesToEmit = 100
        explosion.particleLifetime = 0.7
        explosion.particleLifetimeRange = 0.3
        explosion.emissionAngle = 0
        explosion.emissionAngleRange = CGFloat.pi * 2
        explosion.particleSpeed = 100
        explosion.particleSpeedRange = 50
        explosion.particleAlpha = 0.9
        explosion.particleAlphaRange = 0.1
        explosion.particleAlphaSpeed = -1.5
        explosion.particleScale = 0.4
        explosion.particleScaleRange = 0.2
        explosion.particleScaleSpeed = -0.3
        explosion.particleColor = SKColor.orange
        explosion.particleColorBlendFactor = 1.0
        explosion.particleBlendMode = .add
        
        // 设置位置
        explosion.position = position
        explosion.zPosition = 6
        
        // 添加到场景
        self.scene?.addChild(explosion)
        
        // 创建爆炸范围指示器
        let rangeIndicator = SKShapeNode(circleOfRadius: explosionRadius)
        rangeIndicator.strokeColor = SKColor.orange.withAlphaComponent(0.7)
        rangeIndicator.fillColor = SKColor.orange.withAlphaComponent(0.3)
        rangeIndicator.position = position
        rangeIndicator.zPosition = 5
        
        // 添加到场景
        self.scene?.addChild(rangeIndicator)
        
        // 创建爆炸音效
        let explosionSound = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
        self.scene?.run(explosionSound)
        
        // 自动移除
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        explosion.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run { explosion.particleBirthRate = 0 },
            SKAction.wait(forDuration: 1.0),
            remove
        ]))
        
        rangeIndicator.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            fadeOut,
            remove
        ]))
    }
    
    // 对范围内的所有僵尸造成伤害
    private func damageZombiesInRadius(center: CGPoint, radius: CGFloat) {
        guard let scene = self.scene else { return }
        
        // 遍历场景中的所有节点
        scene.enumerateChildNodes(withName: "//Zombie*") { (node, _) in
            // 确保节点是僵尸类型
            guard let zombie = node as? Zombie else { return }
            
            // 确保僵尸没有死亡
            if zombie.currentState == .dying {
                return
            }
            
            // 计算距离
            let dx = zombie.position.x - center.x
            let dy = zombie.position.y - center.y
            let distance = sqrt(dx * dx + dy * dy)
            
            // 如果在爆炸范围内，造成伤害
            if distance <= radius {
                // 根据距离计算伤害衰减（越近伤害越高）
                let damageFactor = 1.0 - (distance / radius) * 0.5
                let damage = Int(Double(self.attackPower) * damageFactor)
                
                // 对僵尸造成伤害
                GameManager.shared.zombieTakeDamage(zombie, amount: damage)
            }
        }
    }
    
    // 播放发射音效
    private func playLaunchSound() {
        // 创建发射音效动作
        let soundAction = SKAction.playSoundFileNamed("rocket_launch.mp3", waitForCompletion: false)
        
        // 运行音效动作
        self.run(soundAction)
    }
    
    // 开始攻击动画
    override func startAttackingAnimation() {
        // 创建准备发射的动作
        let prepareAction = SKAction.sequence([
            SKAction.scaleX(to: 1.1, y: 0.9, duration: 0.3),
            SKAction.scaleX(to: 0.9, y: 1.1, duration: 0.3),
            SKAction.scale(to: 0.9, duration: 0.1)
        ])
        
        // 运行准备动作
        self.run(prepareAction, withKey: "attackingAnimation")
    }
    
    // 停止攻击动画
    override func stopAttackingAnimation() {
        // 停止准备动作
        self.removeAction(forKey: "attackingAnimation")
        
        // 重置缩放
        self.run(SKAction.scale(to: 0.9, duration: 0.1))
    }
}
