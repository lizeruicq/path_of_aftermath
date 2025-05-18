//
//  Rifle.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class ShotGun: Defend {
    // 子弹速度
    private let bulletSpeed: CGFloat = 300.0
    
    // 子弹大小
    private let bulletSize = CGSize(width: 8, height: 3)
    
    // 子弹颜色
    private let bulletColor = SKColor.yellow
    
    // 初始化方法
    init() {
        // 使用步枪特定的属性初始化
        super.init(
            imageName: "shotgun_idle", // 步枪炮塔图片名称
            name: "霰弹枪手",
            attackPower: 5,          // 攻击力
            fireRate: 1.0,           // 射速（每秒2次）
            health: 50,              // 生命值
            price: 150,              // 价格
            attackRange: 100.0       // 攻击范围
        )
        
        // 设置步枪特有的属性
        self.setScale(1) // 调整大小
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
        
        // 创建子弹
        let bullet = SKShapeNode(rectOf: bulletSize)
        bullet.fillColor = bulletColor
        bullet.strokeColor = bulletColor
        bullet.zPosition = 5
        bullet.name = "bullet"
        
        // 设置子弹初始位置（炮塔位置）
        bullet.position = self.position
        
        // 计算子弹旋转角度（朝向目标）
        let dx = target.position.x - self.position.x
        let dy = target.position.y - self.position.y
        let angle = atan2(dy, dx)
        bullet.zRotation = angle
        
        // 添加子弹到场景
        self.scene?.addChild(bullet)
        
        // 计算子弹飞行时间
        let distance = sqrt(dx * dx + dy * dy)
        let duration = TimeInterval(distance / bulletSpeed)
        
        // 创建子弹移动动作
        let moveAction = SKAction.move(to: target.position, duration: duration)
        
        // 创建子弹命中动作
        let hitAction = SKAction.run { [weak self, weak target] in
            guard let self = self, let target = target, target.parent != nil else {
                bullet.removeFromParent()
                return
            }
            
            // 对目标造成伤害
            GameManager.shared.zombieTakeDamage(target, amount: self.attackPower)
            
            // 创建命中效果
            self.createHitEffect(at: bullet.position)
            
            // 移除子弹
            bullet.removeFromParent()
        }
        
        // 创建子弹移除动作（如果子弹没有命中目标）
        let removeAction = SKAction.removeFromParent()
        
        // 运行子弹动作序列
        bullet.run(SKAction.sequence([moveAction, hitAction, removeAction]))
        
        // 播放射击音效
        playShootSound()
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
        hitEffect.zPosition = 6
        
        // 添加到场景
        self.scene?.addChild(hitEffect)
        
        // 自动移除
        hitEffect.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }
    
    // 播放射击音效
    private func playShootSound() {
        // 创建射击音效动作
        let soundAction = SKAction.playSoundFileNamed("rifle_shot.mp3", waitForCompletion: false)
        
        // 运行音效动作
        self.run(soundAction)
    }
    
    // 开始攻击动画
    override func startAttackingAnimation() {
        // 创建轻微的旋转动作，模拟炮塔瞄准
        let rotateRight = SKAction.rotate(byAngle: 0.05, duration: 0.1)
        let rotateLeft = SKAction.rotate(byAngle: -0.05, duration: 0.1)
        let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])
        
        // 循环执行旋转动作
        self.run(SKAction.repeatForever(rotateSequence), withKey: "attackingAnimation")
    }
    
    // 停止攻击动画
    override func stopAttackingAnimation() {
        // 停止旋转动作
        self.removeAction(forKey: "attackingAnimation")
        
        // 重置旋转角度
        self.run(SKAction.rotate(toAngle: 0, duration: 0.1))
    }
}
