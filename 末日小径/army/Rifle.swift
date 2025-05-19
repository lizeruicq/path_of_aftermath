//
//  Rifle.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class Rifle: Defend {
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
            imageName: "rifle_idle", // 步枪炮塔图片名称
            name: "步枪手",
            attackPower: 5,          // 攻击力
            fireRate: 2.0,           // 射速（每秒2次）
            health: 50,              // 生命值
            price: 100,              // 价格
            attackRange: 500.0       // 攻击范围
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

        // 播放射击动画
        playShootAnimation()

        // 创建子弹
        let bullet = SKShapeNode(rectOf: bulletSize)
        bullet.fillColor = bulletColor
        bullet.strokeColor = bulletColor
        bullet.zPosition = 5
        bullet.name = "bullet"

        // 设置子弹垂直向上（-90度，即π/2弧度）
        bullet.zRotation = -CGFloat.pi / 2

        // 获取场景和父节点
        if let scene = self.scene, let parent = self.parent {
            // 将炮塔位置转换到场景坐标系
            let towerPositionInScene = parent.convert(self.position, to: scene)

            // 设置子弹初始位置在炮塔上方一点（Y坐标增加20）
            bullet.position = CGPoint(x: towerPositionInScene.x, y: towerPositionInScene.y + 20)
            scene.addChild(bullet)
        }

        let distance = self.attackRange
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
    }

    // 创建命中效果
    private func createHitEffect(at position: CGPoint) {
        // 创建命中特效（小型爆炸）
        let hitEffect = SKEmitterNode()

        // 配置粒子系统
//        hitEffect.particleTexture = SKTexture(imageNamed: "spark") // 使用火花图片
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

    // 静态纹理缓存
    static var shootTextureCache: [SKTexture]?

    // 开始攻击动画
    override func startAttackingAnimation() {
        // 使用静态缓存，避免重复加载纹理
        var frames: [SKTexture]

        if let cachedTextures = Rifle.shootTextureCache {
            // 使用缓存的纹理
            frames = cachedTextures
            print("使用缓存的Rifle射击动画纹理")
        } else {
            // 创建新的纹理数组
            frames = []

            // 加载3帧射击动画
            for i in 1...3 {
                let textureName = "rifle_shoot_\(i)"
                // 使用高质量纹理过滤模式
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                frames.append(texture)
            }

            // 保存到静态缓存
            Rifle.shootTextureCache = frames

            // 预加载所有纹理，避免首次使用时的闪烁
            SKTexture.preload(frames) {
                print("Rifle射击动画纹理预加载完成")
            }
        }

        // 保存原始纹理，用于动画结束后恢复
//        let originalTexture = self.texture

//         创建轻微的旋转动作，模拟炮塔瞄准
        let rotateRight = SKAction.rotate(byAngle: 0.05, duration: 0.1)
        let rotateLeft = SKAction.rotate(byAngle: -0.05, duration: 0.1)
        let rotateSequence = SKAction.sequence([rotateRight, rotateLeft])

//         循环执行旋转动作
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
        self.texture = SKTexture(imageNamed: "rifle_idle")
    }

    // 播放射击动画
    private func playShootAnimation() {
        // 如果缓存不存在，创建缓存
        if Rifle.shootTextureCache == nil {
            Rifle.shootTextureCache = []

            // 加载3帧射击动画
            for i in 1...3 {
                let textureName = "rifle_shoot_\(i)"
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                Rifle.shootTextureCache?.append(texture)
            }

            // 预加载所有纹理
            if let textures = Rifle.shootTextureCache {
                SKTexture.preload(textures) {
                    print("Rifle射击动画纹理预加载完成")
                }
            }
        }

        // 获取射击动画帧
        guard let frames = Rifle.shootTextureCache else { return }

        // 创建射击动画
        let shootAnimation = SKAction.animate(with: frames, timePerFrame: 0.05, resize: false, restore: true)

        // 播放射击动画
        self.run(shootAnimation, withKey: "shootAnimation")

        // 播放射击音效
        playShootSound()
    }
}
