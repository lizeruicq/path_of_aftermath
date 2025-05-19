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

    // 当前状态
    private(set) var currentState: ZombieState = .moving

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

    init(imageNamed name: String, speed: CGFloat, health: Int, damage: Int, attackrate: Double) {
        self._speed = speed
        self.health = health
        self.damage = damage
        self.attackRate = attackrate
        super.init(texture: SKTexture(imageNamed: name), color: .clear, size: CGSize(width: 50, height: 50))

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
        // 如果已经死亡或已经在攻击，不执行任何操作
        if currentState == .dying || currentState == .attacking {
            return
        }

        // 停止移动
        stopMoving()

        // 切换到攻击状态
        changeState(to: .attacking)

        // 如果有攻击动画，播放攻击动画
        if let attackAnimation = attackAnimation {
            self.run(attackAnimation, withKey: "attacking")
        }

        // 这里可以添加对目标造成伤害的逻辑
    }

    // 受到伤害
    func takeDamage(_ amount: Int) {
        // 减少血量
        health -= amount

        // 如果僵尸还活着且不在攻击状态，添加被击中的反馈
        if health > 0 && currentState != .attacking {
            // 暂时停止移动
            let currentPosition = self.position

            // 移除当前的移动动作
            self.removeAction(forKey: "movement")

            // 创建轻微的抖动效果
            let shakeRight = SKAction.moveBy(x: 2, y: 0, duration: 0.05)
            let shakeLeft = SKAction.moveBy(x: -2, y: 0, duration: 0.05)
            let shakeSequence = SKAction.sequence([shakeRight, shakeLeft, shakeRight, shakeLeft])

            // 创建短暂的停顿
            let pauseAction = SKAction.wait(forDuration: 0.2)

            // 创建恢复移动的动作
            let resumeAction = SKAction.run { [weak self] in
                guard let self = self, self.health > 0, self.currentState != .dying else { return }

                // 如果僵尸还活着且不在攻击状态，恢复移动
                if self.currentState != .attacking {
                    // 计算到屏幕底部的距离
                    guard let scene = self.scene else { return }
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
            let fadeOut = SKAction.fadeAlpha(to: 0.5, duration: 0.1)
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.1)
            let flash = SKAction.sequence([fadeOut, fadeIn])
            self.run(flash)
        }
    }

    // 死亡
    func die() {
        // 切换到死亡状态
        changeState(to: .dying)

        // 停止所有动作
        self.removeAllActions()

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
        let waitAction = SKAction.wait(forDuration: 5.0)
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            GameManager.shared.removeZombie(self)
        }

        self.run(SKAction.sequence([waitAction, fadeOutAction, removeAction]))
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
