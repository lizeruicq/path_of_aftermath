//
//  Defend.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

// 炮塔状态枚举
enum DefendState {
    case idle        // 空闲状态
    case attacking   // 攻击状态
    case destroyed   // 被摧毁状态
}

class Defend: SKSpriteNode {
    // 炮塔名称
    let towerName: String

    // 攻击力
    var attackPower: Int

    // 射速（每秒攻击次数）
    var fireRate: Double

    // 生命值
    var health: Int {
        didSet {
            // 当血量变为0或更低时，触发摧毁
            if health <= 0 && currentState != .destroyed {
                destroy()
            }
        }
    }

    // 价格
    let price: Int

    // 攻击范围
    var attackRange: CGFloat

    // 当前状态
    private(set) var currentState: DefendState = .idle

    // 攻击目标
    private weak var currentTarget: Zombie?

    // 攻击计时器
    private var attackTimer: TimeInterval = 0

    // 攻击间隔（基于射速计算）
    private var attackInterval: TimeInterval {
        return 1.0 / fireRate
    }

    // 初始化方法
    init(imageName: String, name: String, attackPower: Int, fireRate: Double, health: Int, price: Int, attackRange: CGFloat) {
        self.towerName = name
        self.attackPower = attackPower
        self.fireRate = fireRate
        self.health = health
        self.price = price
        self.attackRange = attackRange

        // 使用提供的图片初始化精灵节点
        let texture = SKTexture(imageNamed: imageName)
        super.init(texture: texture, color: .clear, size: CGSize(width: 50, height: 50))

        // 设置名称
        self.name = "tower_\(name)"

        // 设置物理体
        setupPhysicsBody()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置物理体
    private func setupPhysicsBody() {
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = false // 炮塔不受物理影响
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = 0x1 << 2 // 炮塔类别
        self.physicsBody?.contactTestBitMask = 0x1 << 1 // 僵尸类别
        self.physicsBody?.collisionBitMask = 0 // 不进行物理碰撞
    }

    // 更新方法（在场景的update方法中调用）
    func update(deltaTime: TimeInterval) {
        // 如果炮塔已被摧毁，不执行任何操作
        if currentState == .destroyed {
            return
        }

        // 如果有目标，检查目标是否仍然有效
        if let target = currentTarget {
            // 如果目标已死亡或不在场景中，清除目标
            if target.currentState == .dying || target.parent == nil {
                currentTarget = nil
                changeState(to: .idle)
            } else {
                // 检查目标是否仍在攻击范围内
                let distance = distanceTo(target: target)
                if distance > attackRange {
                    currentTarget = nil
                    changeState(to: .idle)
                } else {
                    // 更新攻击计时器
                    attackTimer += deltaTime

                    // 如果达到攻击间隔，执行攻击
                    if attackTimer >= attackInterval {
                        attackTimer = 0
                        attackTarget(target)
                    }
                }
            }
        } else {
            // 没有目标时，寻找新目标
            findNewTarget()
        }
    }

    // 寻找新目标
    func findNewTarget() {
        // 获取场景中的所有僵尸
        guard let scene = self.scene else { return }

        var closestZombie: Zombie?
        var closestDistance: CGFloat = CGFloat.greatestFiniteMagnitude

        // 获取炮塔在场景中的X坐标
        let towerX = self.convert(CGPoint.zero, to: scene).x

        // 计算列宽（假设有9列）
        let columnWidth = scene.size.width / 9

        // 计算炮塔所在的列
        let towerColumn = Int(towerX / columnWidth)

        // 遍历场景中的所有节点
        scene.enumerateChildNodes(withName: "//Zombie*") { (node, _) in
            // 确保节点是僵尸类型
            guard let zombie = node as? Zombie else { return }

            // 确保僵尸没有死亡
            if zombie.currentState == .dying {
                return
            }

            // 获取僵尸在场景中的X坐标
            let zombieX = zombie.position.x

            // 计算僵尸所在的列
            let zombieColumn = Int(zombieX / columnWidth)

            // 检查僵尸和炮塔是否在同一列
            if zombieColumn != towerColumn {
                return
            }

            // 计算距离
            let distance = self.distanceTo(target: zombie)

            // 如果在攻击范围内且比当前最近的僵尸更近，更新最近的僵尸
            if distance <= self.attackRange && distance < closestDistance {
                closestZombie = zombie
                closestDistance = distance
            }
        }

        // 如果找到目标，设置为当前目标并开始攻击
        if let target = closestZombie {
            currentTarget = target
            changeState(to: .attacking)
            print("炮塔找到目标：列 \(towerColumn)")
        }
    }

    // 计算到目标的距离
    private func distanceTo(target: SKNode) -> CGFloat {
        let dx = target.position.x - self.position.x
        let dy = target.position.y - self.position.y
        return sqrt(dx * dx + dy * dy)
    }

    // 攻击目标
    func attackTarget(_ target: Zombie) {
        // 子类实现具体的攻击效果
    }

    // 受到伤害
    func takeDamage(_ amount: Int) {
        health -= amount
    }

    // 被摧毁
    func destroy() {
        changeState(to: .destroyed)

        // 创建摧毁效果（可以在子类中重写以添加特定效果）
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()

        self.run(SKAction.sequence([fadeOut, remove]))
    }

    // 改变状态
    func changeState(to newState: DefendState) {
        // 如果状态没有变化，不执行任何操作
        if currentState == newState {
            return
        }

        // 更新当前状态
        currentState = newState

        // 根据新状态执行相应的操作
        switch newState {
        case .idle:
            // 空闲状态的操作
            stopAttackingAnimation()
        case .attacking:
            // 攻击状态的操作
            startAttackingAnimation()
        case .destroyed:
            // 被摧毁状态的操作
            stopAllAnimations()
        }
    }

    // 开始攻击动画
    func startAttackingAnimation() {
        // 子类实现具体的攻击动画
    }

    // 停止攻击动画
    func stopAttackingAnimation() {
        // 子类实现具体的停止攻击动画
    }

    // 停止所有动画
    func stopAllAnimations() {
        self.removeAllActions()
    }
}
