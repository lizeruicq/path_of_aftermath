
import SpriteKit

class Boomer: Zombie {
    // 移动速度（重写父类属性）
    override var speed: CGFloat {
        get {
            return super.speed
        }
        set {
            super.speed = newValue
        }
    }

    init() {
 
        let config = zombieConfigs[ZombieType.boomer.rawValue] ?? [:]
        let health = config["health"] as? Int ?? 30
        let speed = config["speed"] as? CGFloat ?? 30
        let damage = config["damage"] as? Int ?? 10
        let attackRate = config["attackRate"] as? Double ?? 1.0
        let rewardMoney = config["rewardMoney"] as? Int ?? 10

        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: "boomer_move_1")
        super.init(texture: texture, speed: speed, health: health, damage: damage, attackrate: attackRate, rewardMoney: rewardMoney)

        // 设置各种状态的动画
        setupAnimations()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置各种状态的动画
    private func setupAnimations() {
        // 设置移动动画
        setupMoveAnimation()

        // 设置攻击动画
        setupAttackAnimation()

        // 设置死亡动画
        setupDieAnimation()
    }

    // 设置移动动画
    private func setupMoveAnimation() {
        // 从ResourceManager获取动画
        if let animation = ResourceManager.shared.createAnimation(forKey: "boomer_move", timePerFrame: 0.1, repeatForever: true) {
            // 保存移动动画
            moveAnimation = animation

            // 默认播放移动动画
            self.run(animation, withKey: "animation")
        } else {
            // 如果从ResourceManager获取失败，创建备用动画
            print("警告：无法从ResourceManager获取boomer_move动画，创建备用动画")

            // 创建动画帧数组
            var frames: [SKTexture] = []

            // 加载7帧动画
            for i in 1...4/Users/zeruili/projects/末日小径/末日小径/zombie/Trans.swift {
                let textureName = "boomer_move_\(i)"
                let texture = ResourceManager.shared.getTexture(named: textureName)
                frames.append(texture)
            }

            // 创建动画动作
            let animation = SKAction.animate(with: frames, timePerFrame: 0.1)

            // 创建永久循环动作
            let repeatForever = SKAction.repeatForever(animation)

            // 保存移动动画
            moveAnimation = repeatForever

            // 默认播放移动动画
            self.run(repeatForever, withKey: "animation")
        }
    }

    // 设置攻击动画
    private func setupAttackAnimation() {
        // 由于没有专门的攻击动画帧，我们使用移动帧的变体作为攻击动画
        var frames: [SKTexture] = []

        
        let attackFrameNames = ["boomer_attack_1", "boomer_attack_2", "boomer_attack_3", "boomer_attack_4"]

        for frameName in attackFrameNames {
            let texture = ResourceManager.shared.getTexture(named: frameName)
            frames.append(texture)
        }

        // 创建攻击动画（更快的帧率）
        let animation = SKAction.animate(with: frames, timePerFrame: 0.08)

        // 创建永久循环的攻击动画（持续攻击直到目标被摧毁）
        let repeatForever = SKAction.repeatForever(animation)

        // 保存攻击动画
        attackAnimation = repeatForever
    }

    // 设置死亡动画
    private func setupDieAnimation() {
        // 由于没有专门的死亡动画帧，我们使用颜色变化和缩放效果

        // 创建颜色变化动作（变灰）
        let colorizeAction = SKAction.colorize(with: .gray, colorBlendFactor: 0.8, duration: 0.3)

//        // 创建旋转动作（倒下）
//        let rotateAction = SKAction.rotate(toAngle: CGFloat.pi / 2, duration: 0.5)

        // 创建缩放动作（略微缩小）
//        let scaleAction = SKAction.scale(to: 0.8, duration: 0.3)

        // 组合动作
        let dieAction = SKAction.group([colorizeAction])

        // 保存死亡动画
        dieAnimation = dieAction
    }
}
