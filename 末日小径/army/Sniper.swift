//
//  Sniper.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class Sniper: Defend {
    // 子弹速度
    private let bulletSpeed: CGFloat = 500.0
    
    // 子弹大小
    private let bulletSize = CGSize(width: 10, height: 3)
    
    // 子弹颜色
    private let bulletColor = SKColor.cyan
    
    // 初始化方法
    init() {
        // 使用狙击枪特定的属性初始化
        super.init(
            imageName: "sniper_tower", // 狙击枪炮塔图片名称
            name: "狙击枪",
            attackPower: 20,         // 攻击力
            fireRate: 0.5,           // 射速（每秒0.5次）
            health: 30,              // 生命值
            price: 300,              // 价格
            attackRange: 350.0       // 攻击范围
        )
        
        // 设置狙击枪特有的属性
        self.setScale(0.85) // 调整大小
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
        
        // 创建瞄准线
        createAimingLine(to: target)
        
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
    
    // 创建瞄准线
    private func createAimingLine(to target: Zombie) {
        // 计算方向
        let dx = target.position.x - self.position.x
        let dy = target.position.y - self.position.y
        let angle = atan2(dy, dx)
        
        // 创建瞄准线
        let aimLine = SKShapeNode()
        let path = CGMutablePath()
        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: attackRange, y: 0))
        aimLine.path = path
        aimLine.strokeColor = SKColor.red.withAlphaComponent(0.5)
        aimLine.lineWidth = 1
        aimLine.zPosition = 4
        aimLine.zRotation = angle
        
        // 添加到炮塔
        self.addChild(aimLine)
        
        // 创建闪烁和消失动作
        let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: 0.1)
        let fadeOut = SKAction.fadeAlpha(to: 0, duration: 0.2)
        let sequence = SKAction.sequence([fadeIn, fadeOut, SKAction.removeFromParent()])
        
        // 运行动作
        aimLine.run(sequence)
    }
    
    // 创建命中效果
    private func createHitEffect(at position: CGPoint) {
        // 创建命中特效（大型爆炸）
        let hitEffect = SKEmitterNode()
        
        // 配置粒子系统
        hitEffect.particleTexture = SKTexture(imageNamed: "spark") // 使用火花图片
        hitEffect.particleBirthRate = 30
        hitEffect.numParticlesToEmit = 15
        hitEffect.particleLifetime = 0.3
        hitEffect.particleLifetimeRange = 0.1
        hitEffect.emissionAngle = 0
        hitEffect.emissionAngleRange = CGFloat.pi * 2
        hitEffect.particleSpeed = 70
        hitEffect.particleSpeedRange = 30
        hitEffect.particleAlpha = 0.9
        hitEffect.particleAlphaRange = 0.1
        hitEffect.particleAlphaSpeed = -3.0
        hitEffect.particleScale = 0.3
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
            SKAction.wait(forDuration: 0.4),
            SKAction.removeFromParent()
        ]))
    }
    
    // 播放射击音效
    private func playShootSound() {
        // 创建射击音效动作
        let soundAction = SKAction.playSoundFileNamed("sniper_shot.mp3", waitForCompletion: false)
        
        // 运行音效动作
        self.run(soundAction)
    }
    
    // 开始攻击动画
    override func startAttackingAnimation() {
        // 创建后坐力动作
        let recoilBack = SKAction.moveBy(x: -3, y: 0, duration: 0.1)
        let recoilForward = SKAction.moveBy(x: 3, y: 0, duration: 0.3)
        let recoilSequence = SKAction.sequence([recoilBack, recoilForward])
        
        // 运行后坐力动作
        self.run(recoilSequence, withKey: "attackingAnimation")
    }
    
    // 停止攻击动画
    override func stopAttackingAnimation() {
        // 停止后坐力动作
        self.removeAction(forKey: "attackingAnimation")
        
        // 重置位置
        self.run(SKAction.move(to: CGPoint.zero, duration: 0.1))
    }
}
