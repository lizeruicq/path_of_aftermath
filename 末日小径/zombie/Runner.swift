// Runner僵尸子类
import SpriteKit

class Runner: Zombie {
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
        // 使用walker的第一帧初始化，但设置不同的颜色以区分
        super.init(imageNamed: "walker_move_1", speed: 20, health: 5, damage: 5, attackrate: 1)

        // 设置颜色为红色以区分
        self.color = .red
        self.colorBlendFactor = 0.5

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
        // 创建动画帧数组
        var frames: [SKTexture] = []

        // 加载7帧动画
        for i in 1...7 {
            let textureName = "walker_move_\(i)"
            let texture = SKTexture(imageNamed: textureName)
            frames.append(texture)
        }

        // 创建动画动作（比Walker更快的动画）
        let animation = SKAction.animate(with: frames, timePerFrame: 0.07)

        // 创建永久循环动作
        let repeatForever = SKAction.repeatForever(animation)

        // 保存移动动画
        moveAnimation = repeatForever

        // 默认播放移动动画
        self.run(repeatForever, withKey: "animation")
    }

    // 设置攻击动画
    private func setupAttackAnimation() {
        // 由于没有专门的攻击动画帧，我们使用移动帧的变体作为攻击动画
        var frames: [SKTexture] = []

        // 使用移动帧1, 3, 5, 7作为攻击帧
        let attackFrameNames = ["walker_move_1", "walker_move_3", "walker_move_5", "walker_move_7"]

        for frameName in attackFrameNames {
            let texture = SKTexture(imageNamed: frameName)
            frames.append(texture)
        }

        // 创建攻击动画（更快的帧率）
        let animation = SKAction.animate(with: frames, timePerFrame: 0.05) // Runner攻击更快

        // 创建永久循环的攻击动画（持续攻击直到目标被摧毁）
        let repeatForever = SKAction.repeatForever(animation)

        // 保存攻击动画
        attackAnimation = repeatForever
    }

    // 设置死亡动画
    private func setupDieAnimation() {
        // 由于没有专门的死亡动画帧，我们使用颜色变化和缩放效果

        // 创建颜色变化动作（变灰）
        let colorizeAction = SKAction.colorize(with: .gray, colorBlendFactor: 0.8, duration: 0.2)

        // 创建旋转动作（倒下）
        let rotateAction = SKAction.rotate(toAngle: CGFloat.pi / 2, duration: 0.3)

        // 创建缩放动作（略微缩小）
        let scaleAction = SKAction.scale(to: 0.8, duration: 0.2)

        // 组合动作
        let dieAction = SKAction.group([colorizeAction, rotateAction, scaleAction])

        // 保存死亡动画
        dieAnimation = dieAction
    }
}
