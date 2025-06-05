// 僵尸父类
import SpriteKit

// 僵尸状态枚举
enum ZombieState {
    case moving     // 移动状态
    case attacking  // 攻击状态
    case dying      // 死亡状态
}

class Zombie: SKSpriteNode {
    // 移动速度（改为计算属性以允许子类重写）
    override open var speed: CGFloat {
        get {
            return _speed
        }
        set {
            _speed = newValue
        }
    }
    private var _speed: CGFloat

    // 血量
    var health: Int {
        didSet {
            // 当血量变为0或更低时，触发死亡
            if health <= 0 && currentState != .dying {
                die()
            }
        }
    }
    // 攻击频率
    var attackRate: Double

    // 伤害
    var damage: Int

    // 击杀奖励金币
    var rewardMoney: Int

    // 当前状态
    private(set) var currentState: ZombieState = .moving

    // 攻击目标
    weak var attackTarget: SKNode?

    // 攻击计时器
    private var attackTimer: TimeInterval = 0

    // 攻击间隔（基于攻击频率计算）
    private var attackInterval: TimeInterval {
        return 1.0 / attackRate
    }

    // 移动动画
    var moveAnimation: SKAction?

    // 攻击动画
    var attackAnimation: SKAction?

    // 死亡动画
    var dieAnimation: SKAction?

    // 当前移动动作
    private var currentMoveAction: SKAction?

    // 当前动画动作
    private var currentAnimationAction: SKAction?

    init(texture: SKTexture, speed: CGFloat, health: Int, damage: Int, attackrate: Double, rewardMoney: Int = 10) {
        self._speed = speed
        self.health = health
        self.damage = damage
        self.attackRate = attackrate
        self.rewardMoney = rewardMoney
//        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))
        super.init(texture: texture, color: .clear, size: texture.size())

        // 设置zPosition确保僵尸显示在正确的层级
        self.zPosition = 100

        // 设置物理体
        setupPhysicsBody()
    }

    // 兼容旧代码的初始化方法
    init(imageNamed name: String, speed: CGFloat, health: Int, damage: Int, attackrate: Double, rewardMoney: Int = 10) {
        self._speed = speed
        self.health = health
        self.damage = damage
        self.attackRate = attackrate
        self.rewardMoney = rewardMoney

        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: name)
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))

        // 设置zPosition确保僵尸显示在正确的层级
        self.zPosition = 100

        // 设置物理体
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置物理体
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.allowsRotation = false

        // 设置碰撞检测类别（需要在项目中定义物理类别常量）
        self.physicsBody?.categoryBitMask = 0x1 << 1      // 僵尸类别
        self.physicsBody?.contactTestBitMask = 0x1 << 2   // 炮塔类别
        self.physicsBody?.collisionBitMask = 0            // 不进行物理碰撞
    }

    // 开始移动
    func startMoving(to destination: CGPoint, duration: TimeInterval) {
        // 如果已经死亡，不执行任何操作
        if currentState == .dying {
            return
        }

        // 切换到移动状态
        changeState(to: .moving)

        // 创建移动动作
        let moveAction = SKAction.move(to: destination, duration: duration)

        // 保存当前移动动作引用
        currentMoveAction = moveAction

         // 移动完成后移除僵尸
         let removeAction = SKAction.run { [weak self] in
             guard let self = self else { return }
             // 通知GameManager移除僵尸
             GameManager.shared.removeZombie(self)
         }

//         运行动作序列
         self.run(SKAction.sequence([moveAction, removeAction]), withKey: "movement")

    }

    // 停止移动
    func stopMoving() {
        // 移除移动动作
        self.removeAction(forKey: "movement")
    }

    // 攻击目标
    func attack(target: SKNode) {
        // 如果已经死亡，不执行任何操作
        if currentState == .dying {
            return
        }

        print("僵尸开始攻击目标: \(target.name ?? "未知")")

        // 停止移动
        stopMoving()

        // 设置攻击目标
        attackTarget = target

        // 重置攻击计时器
        attackTimer = 0

        // 切换到攻击状态
        changeState(to: .attacking)

    }

    // 执行一次攻击
    private func performAttack() {
        guard let target = attackTarget else { return }

        // 检查目标是否仍然有效
//        if target.parent == nil {
//            // 目标已被移除，恢复移动
//            resumeMovement()
//            return
//        }

        // 如果目标是炮塔，对其造成伤害
        if let tower = target as? Defend {
            // 检查炮塔是否已被摧毁
            if tower.currentState == .destroyed {
                // 炮塔已被摧毁，恢复移动
                resumeMovement()
                return
            }
            // 如果有攻击动画，播放攻击动画
            if let attackAnimation = attackAnimation {
                self.run(attackAnimation, withKey: "attacking")
            }

            // 对炮塔造成伤害
            tower.takeDamage(damage)
            print("僵尸对炮塔造成\(damage)点伤害，炮塔剩余血量：\(tower.health)")

            // 检查炮塔是否被摧毁
            if tower.health <= 0 {
                // 炮塔被摧毁，恢复移动
                resumeMovement()
                return
            }
        }
    }

    // 恢复移动状态
    func resumeMovement() {
        print("僵尸恢复移动状态")

        // 清除攻击目标
        attackTarget = nil

        // 如果僵尸还活着，恢复移动状态
        if currentState != .dying {
            // 切换到移动状态
            changeState(to: .moving)

            // 计算到屏幕底部的距离
            let destinationY = -self.size.height
            let destination = CGPoint(x: self.position.x, y: destinationY)

            // 计算剩余距离
            let remainingDistance = self.position.y - destinationY

            // 计算剩余时间（基于僵尸速度）
            let remainingDuration = TimeInterval(remainingDistance / self.speed)

            // 创建新的移动动作
            let newMoveAction = SKAction.move(to: destination, duration: remainingDuration)

            // 移动完成后移除僵尸
            let removeAction = SKAction.run { [weak self] in
                guard let self = self else { return }
                GameManager.shared.removeZombie(self)
            }

            // 运行新的动作序列
            self.run(SKAction.sequence([newMoveAction, removeAction]), withKey: "movement")
        }
    }

    // 更新方法（在GameManager的update方法中调用）
    func update(deltaTime: TimeInterval) {
        // 如果僵尸已死亡，不执行任何操作
        if currentState == .dying {
            return
        }

       

        // 如果在攻击状态，更新攻击计时器
        if currentState == .attacking {
            attackTimer += deltaTime

            // 如果达到攻击间隔，执行攻击
            if attackTimer >= attackInterval {
                attackTimer = 0
               
                performAttack()
            }
        }
    }

    // 受到伤害
    func takeDamage(_ amount: Int) {
        // 减少血量
        health -= amount

        // 如果僵尸还活着且不在攻击状态，添加被击中的反馈
        if health > 0 && currentState != .attacking {
//            // 暂时停止移动
//            let currentPosition = self.position
//
//            // 移除当前的移动动作
//            self.removeAction(forKey: "movement")

            // 创建轻微的抖动效果
            let shakeRight = SKAction.moveBy(x: 0, y: 3, duration: 0.05)
            let shakeLeft = SKAction.moveBy(x: 0, y: -3, duration: 0.05)
            let shakeSequence = SKAction.sequence([shakeRight, shakeLeft, shakeRight, shakeLeft])

            // 创建短暂的停顿
            let pauseAction = SKAction.wait(forDuration: 0.2)

            // 创建恢复移动的动作
            let resumeAction = SKAction.run { [weak self] in
                guard let self = self, self.health > 0, self.currentState != .dying else { return }

                // 如果僵尸还活着且不在攻击状态，恢复移动
                if self.currentState != .attacking {
                    // 计算到屏幕底部的距离
//                    guard let scene = self.scene else { return }
                    let destinationY = -self.size.height
                    let destination = CGPoint(x: self.position.x, y: destinationY)

                    // 计算剩余距离
                    let remainingDistance = self.position.y - destinationY

                    // 计算剩余时间（基于僵尸速度）
                    let remainingDuration = TimeInterval(remainingDistance / self.speed)

                    // 创建新的移动动作
                    let newMoveAction = SKAction.move(to: destination, duration: remainingDuration)

                    // 移动完成后移除僵尸
                    let removeAction = SKAction.run { [weak self] in
                        guard let self = self else { return }
                        GameManager.shared.removeZombie(self)
                    }

                    // 运行新的动作序列
                    self.run(SKAction.sequence([newMoveAction, removeAction]), withKey: "movement")
                }
            }

            // 运行被击中反馈序列
            self.run(SKAction.sequence([shakeSequence, pauseAction, resumeAction]))

            // 添加闪烁效果
//            let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
//            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
//            let flash = SKAction.sequence([fadeOut, fadeIn])
//            self.run(flash)
        }
    }
    
    private func playFallSound() {
        // 使用 SoundManager 控制音效播放
        if let scene = self.scene {
            SoundManager.shared.playSoundEffect("zombie_death", in: scene)
        }
    }

    // 死亡
    func die() {
        // 切换到死亡状态
        changeState(to: .dying)
        
        playFallSound()
        // 停止所有动作
        self.removeAllActions()

        // 禁用物理碰撞，防止死亡后仍然与子弹碰撞
        self.physicsBody?.categoryBitMask = 0
        self.physicsBody?.contactTestBitMask = 0
        self.physicsBody?.collisionBitMask = 0

        // 给玩家奖励金币
        PlayerEconomyManager.shared.addFunds(rewardMoney)

        // 播放金币奖励动画
        showRewardAnimation()

        // 如果有死亡动画，播放死亡动画
        if let dieAnimation = dieAnimation {
            self.run(dieAnimation)
        } else {
            // 没有死亡动画时的默认行为
            // 改变颜色为灰色表示死亡
            self.color = .gray
            self.colorBlendFactor = 0.8
        }

        // 5秒后移除僵尸
        let waitAction = SKAction.wait(forDuration: 1.0)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            GameManager.shared.removeZombie(self)
        }

        self.run(SKAction.sequence([waitAction, fadeOutAction, removeAction]))
    }

    // 显示金币奖励动画
    private func showRewardAnimation() {
        guard let scene = self.scene else { return }

        // 创建金币奖励文本
        let rewardLabel = SKLabelNode(text: "$+\(rewardMoney)")
        rewardLabel.fontName = "Arial-Bold"
        rewardLabel.fontSize = 16
        rewardLabel.fontColor = .yellow
        rewardLabel.position = self.position
        rewardLabel.zPosition = 200 // 确保在最上层显示


        // 添加到场景
        scene.addChild(rewardLabel)

        // 创建动画效果
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)

        // 组合动画
        let scaleAnimation = SKAction.sequence([scaleUp, scaleDown])
        let moveAndFade = SKAction.group([moveUp, fadeOut])
        let removeLabel = SKAction.removeFromParent()

        // 执行动画序列
        let animationSequence = SKAction.sequence([scaleAnimation, moveAndFade, removeLabel])
        rewardLabel.run(animationSequence)
    }

    // 改变状态
    func changeState(to newState: ZombieState) {
        // 如果状态没有变化，不执行任何操作
        if currentState == newState {
            return
        }

        print("僵尸状态从\(currentState)变为\(newState)")

        // 移除当前动画
        self.removeAction(forKey: "animation")

        // 短暂延迟，确保动画切换平滑
        let waitAction = SKAction.wait(forDuration: 0.05)

        // 更新当前状态
        currentState = newState

        // 根据新状态执行相应的动画
        let startAnimationAction = SKAction.run { [weak self] in
            guard let self = self else { return }

            switch newState {
            case .moving:
            print("开始移动")
                // 播放移动动画
                if let moveAnimation = self.moveAnimation {
                    self.run(moveAnimation, withKey: "animation")
                }
            case .attacking:
            print("开始攻击")
                // 攻击动画在attack方法中处理
                break
            case .dying:
            print("死亡")
                // 死亡动画在die方法中处理
                break
            }
        }

        // 运行动画序列
        self.run(SKAction.sequence([waitAction, startAnimationAction]))
    }
}
