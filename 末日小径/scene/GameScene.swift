//
//  GameScene.swift
//  末日小径
//
//  Created by zerui lī on 2025/5/2.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {

    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()

    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?

    // 当前关卡
    var currentLevel: Int = 1

    // 背景图片节点
    private var backgroundNode: SKSpriteNode?

    // 游戏管理器引用
    var gameManager: GameManager = GameManager.shared

    override init(size: CGSize) {
        super.init(size: size)
        // 设置默认背景颜色为深灰色
        backgroundColor = SKColor.darkGray

        // 设置物理世界
        setupPhysicsWorld()
    }

    // 设置物理世界
    private func setupPhysicsWorld() {
        // 设置物理世界
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



    // 配置关卡
    func configureLevel(level: Int) {
        currentLevel = level
        setupBackground()

        // 配置游戏管理器
        gameManager.configureLevel(level: level, scene: self)
    }

    // 设置背景
    private func setupBackground() {
        // 根据关卡号选择背景图片（level1 -> level1，level2 -> level2，以此类推）
        print("当前关卡为\(currentLevel)")

        let backgroundName = "level-\(currentLevel)"

        // 使用ResourceManager获取纹理
        let texture = ResourceManager.shared.getTexture(named: backgroundName)

        // 创建背景精灵节点
        backgroundNode = SKSpriteNode(texture: texture)

        if let backgroundNode = backgroundNode {
            // 设置背景位置为屏幕中心
            backgroundNode.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)

            // 调整背景大小以填充整个屏幕
//            backgroundNode.size = self.size
            
            let scale = max(self.size.width / backgroundNode.size.width,
                            self.size.height / backgroundNode.size.height)
            backgroundNode.setScale(scale)

            // 设置zPosition确保背景在最底层
            backgroundNode.zPosition = 0

            // 将背景添加到场景
            addChild(backgroundNode)
        } else {
            print("未能加载背景图片：\(backgroundName)")
            // 如果指定的关卡背景不存在，则使用默认背景
            backgroundColor = SKColor.darkGray
        }
    }

    override func sceneDidLoad() {
        self.lastUpdateTime = 0

        // // Get label node from scene and store it for use later
        // self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        // if let label = self.label {
        //     label.alpha = 0.0
        //     label.run(SKAction.fadeIn(withDuration: 2.0))
        // }

        // 查找并加载rode节点
//        if let roadNode = self.childNode(withName: "//road") {
//            print("找到了road节点: \(roadNode)")
//        } else {
//            print("未找到road节点")
//        }

        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)

        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5

            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }


    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }

    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }

    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }

        // 获取触摸位置
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)


        // 检查是否点击了准备按钮
        for node in touchedNodes {
            if node.name == "readyButton" || node.parent?.name == "readyButton" {
                gameManager.handleReadyButtonTap()
                return
            }
        }

        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }


    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered

        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }

        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime

        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }

        // 更新游戏管理器
        gameManager.update(currentTime)

        self.lastUpdateTime = currentTime
    }

    // 处理物理碰撞
    func didBegin(_ contact: SKPhysicsContact) {
        // 获取碰撞的两个物体
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB

        // 检查是否是僵尸和炮塔的碰撞
        let zombieCategory: UInt32 = 0x1 << 1
        let towerCategory: UInt32 = 0x1 << 2

        // 僵尸和炮塔碰撞
        if (bodyA.categoryBitMask == zombieCategory && bodyB.categoryBitMask == towerCategory) {
            if let zombie = bodyA.node as? Zombie, let tower = bodyB.node {
                // 检查僵尸和炮塔是否在同一列
                if isSameColumn(zombie: zombie, tower: tower) {
                    gameManager.handleZombieTowerCollision(zombie: zombie, tower: tower)
                }
            }
        } else if (bodyA.categoryBitMask == towerCategory && bodyB.categoryBitMask == zombieCategory) {
            if let zombie = bodyB.node as? Zombie, let tower = bodyA.node {
                // 检查僵尸和炮塔是否在同一列
                if isSameColumn(zombie: zombie, tower: tower) {
                    gameManager.handleZombieTowerCollision(zombie: zombie, tower: tower)
                }
            }
        }
    }

    // 检查僵尸和炮塔是否在同一列
    private func isSameColumn(zombie: Zombie, tower: SKNode) -> Bool {
        // 获取僵尸和炮塔的X坐标（在场景坐标系中）
        let zombieX = zombie.position.x
        let towerX = tower.convert(CGPoint.zero, to: self).x

        // 计算列宽（假设有9列）
        let columnWidth = self.size.width / 9

        // 计算僵尸和炮塔所在的列
        let zombieColumn = Int(zombieX / columnWidth)
        let towerColumn = Int(towerX / columnWidth)

        // 打印调试信息
        print("碰撞检测 - 僵尸X坐标: \(zombieX), 列: \(zombieColumn), 炮塔X坐标: \(towerX), 列: \(towerColumn)")

        // 检查是否在同一列
        return zombieColumn == towerColumn
    }
}
