//
//  LevelSelectionPanel.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

// 关卡选择面板委托协议
protocol LevelSelectionPanelDelegate: AnyObject {
    func levelSelectionPanel(_ panel: LevelSelectionPanel, didSelectLevel levelId: Int)
    func levelSelectionPanelDidRequestShowError(_ panel: LevelSelectionPanel, message: String)
}

class LevelSelectionPanel: SKNode {

    // 委托
    weak var delegate: LevelSelectionPanelDelegate?

    // 面板尺寸
    private var panelSize: CGSize

    // 大关容器数组
    private var chapterContainers: [SKNode] = []

    // 关卡按钮映射 (levelId -> button)
    private var levelButtons: [Int: SKShapeNode] = [:]

    // 关卡进度管理器
    private let progressManager = LevelProgressManager.shared

    // 初始化方法
    init(size: CGSize) {
        self.panelSize = size
        super.init()
        setupPanel()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // 设置面板
    private func setupPanel() {
        // 面板配置
        let panelWidth = panelSize.width * 0.9
        let panelHeight = panelSize.height * 0.75  // 留出空间给返回按钮
        let panelX = panelSize.width * 0.05
        let panelY = panelSize.height * 0.2  // 从更高的位置开始，为返回按钮留空间

        // // 创建面板背景
        // let panelBackground = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.3), size: CGSize(width: panelWidth, height: panelHeight))
        // panelBackground.position = CGPoint(x: panelX + panelWidth/2, y: panelY + panelHeight/2)
        // panelBackground.zPosition = 1
        // addChild(panelBackground)

        // 大关间距和尺寸配置
        let chapterSpacing: CGFloat = 20
        let chapterHeight: CGFloat = (panelHeight - chapterSpacing * 4) / 3 // 3个大关

        // 创建每个大关的容器
        for (chapterIndex, chapter) in LevelStructure.chapters.enumerated() {
            let chapterContainer = createChapterContainer(
                chapter: chapter,
                containerWidth: panelWidth,
                containerHeight: chapterHeight,
                yPosition: panelY + panelHeight - (CGFloat(chapterIndex + 1) * (chapterHeight + chapterSpacing))
            )

            chapterContainer.position.x = panelX
            addChild(chapterContainer)
            chapterContainers.append(chapterContainer)
        }
    }

    // 创建大关容器
    private func createChapterContainer(chapter: ChapterConfig, containerWidth: CGFloat, containerHeight: CGFloat, yPosition: CGFloat) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: 0, y: yPosition)

        // 大关背景
        let chapterBackground = SKSpriteNode(color: SKColor.darkGray.withAlphaComponent(0.5), size: CGSize(width: containerWidth, height: containerHeight))
        chapterBackground.position = CGPoint(x: containerWidth/2, y: containerHeight/2)
        chapterBackground.zPosition = 2
        container.addChild(chapterBackground)

        // 大关标题
        let titleHeight: CGFloat = 40
        let chapterTitle = SKLabelNode(fontNamed: "Helvetica-Bold")
        chapterTitle.text = chapter.name
        chapterTitle.fontSize = 24
        chapterTitle.fontColor = SKColor.white
        chapterTitle.position = CGPoint(x: containerWidth/2, y: containerHeight - titleHeight/2)
        chapterTitle.verticalAlignmentMode = .center
        chapterTitle.horizontalAlignmentMode = .center
        chapterTitle.zPosition = 5
        container.addChild(chapterTitle)

        // 创建可滚动的关卡容器
        let levelsContainer = createLevelsScrollContainer(
            levels: chapter.levels,
            containerWidth: containerWidth,
            containerHeight: containerHeight - titleHeight,
            yOffset: 0
        )
        container.addChild(levelsContainer)

        return container
    }

    // 创建可滚动的关卡容器
    private func createLevelsScrollContainer(levels: [LevelInfo], containerWidth: CGFloat, containerHeight: CGFloat, yOffset: CGFloat) -> SKNode {
        // 创建裁剪容器
        let clipContainer = SKNode()
        clipContainer.position = CGPoint(x: 0, y: yOffset)

        // 创建裁剪遮罩
        let maskNode = SKSpriteNode(color: SKColor.white, size: CGSize(width: containerWidth, height: containerHeight))
        maskNode.position = CGPoint(x: containerWidth/2, y: containerHeight/2)

        // 创建可滚动的内容容器
        let scrollContainer = SKNode()
        scrollContainer.position = CGPoint(x: 0, y: 0)

        // 关卡按钮配置
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 60
        let buttonSpacing: CGFloat = 15
        let leftMargin: CGFloat = 20

        // 计算总宽度
        let totalButtonsWidth = CGFloat(levels.count) * buttonWidth + CGFloat(levels.count - 1) * buttonSpacing
        let scrollContentWidth = totalButtonsWidth + leftMargin * 2

        // 创建关卡按钮
        for (levelIndex, level) in levels.enumerated() {
            let button = createLevelButton(
                level: level,
                buttonSize: CGSize(width: buttonWidth, height: buttonHeight),
                xPosition: leftMargin + CGFloat(levelIndex) * (buttonWidth + buttonSpacing) + buttonWidth/2,
                yPosition: containerHeight/2
            )
            scrollContainer.addChild(button)
        }

        // 设置裁剪
        clipContainer.addChild(scrollContainer)

        // 如果内容宽度超过容器宽度，启用滑动功能
        if scrollContentWidth > containerWidth {
            setupScrolling(for: scrollContainer,
                          contentWidth: scrollContentWidth,
                          containerWidth: containerWidth,
                          containerHeight: containerHeight)

            // 添加滑动指示器
            addScrollIndicators(to: clipContainer, containerWidth: containerWidth, containerHeight: containerHeight)
        }

        // 应用裁剪遮罩
        let cropNode = SKCropNode()
        cropNode.maskNode = maskNode
        cropNode.addChild(clipContainer)
        cropNode.position = CGPoint(x: 0, y: yOffset)

        return cropNode
    }

    // 设置滑动功能
    private func setupScrolling(for scrollContainer: SKNode, contentWidth: CGFloat, containerWidth: CGFloat, containerHeight: CGFloat) {
        // 添加触摸检测区域
        let touchArea = SKSpriteNode(color: SKColor.clear, size: CGSize(width: containerWidth, height: containerHeight))
        touchArea.position = CGPoint(x: containerWidth/2, y: containerHeight/2)
        touchArea.name = "scrollTouchArea"
        touchArea.zPosition = 100

        // 存储滑动相关信息
        touchArea.userData = NSMutableDictionary()
        touchArea.userData?["scrollContainer"] = scrollContainer
        touchArea.userData?["contentWidth"] = contentWidth
        touchArea.userData?["containerWidth"] = containerWidth
        touchArea.userData?["maxScrollX"] = max(0, contentWidth - containerWidth)
        touchArea.userData?["currentScrollX"] = 0.0

        scrollContainer.parent?.addChild(touchArea)
    }

    // 添加滑动指示器
    private func addScrollIndicators(to container: SKNode, containerWidth: CGFloat, containerHeight: CGFloat) {
        // 左侧渐变指示器
        let leftIndicator = createGradientIndicator(width: 20, height: containerHeight, isLeft: true)
        leftIndicator.position = CGPoint(x: 10, y: containerHeight/2)
        leftIndicator.zPosition = 50
        container.addChild(leftIndicator)

        // 右侧渐变指示器
        let rightIndicator = createGradientIndicator(width: 20, height: containerHeight, isLeft: false)
        rightIndicator.position = CGPoint(x: containerWidth - 10, y: containerHeight/2)
        rightIndicator.zPosition = 50
        container.addChild(rightIndicator)

        // 添加滑动提示文字（可选）
        let scrollHint = SKLabelNode(fontNamed: "Helvetica")
        scrollHint.text = "← 滑动查看更多 →"
        scrollHint.fontSize = 12
        scrollHint.fontColor = SKColor.lightGray
        scrollHint.position = CGPoint(x: containerWidth/2, y: 10)
        scrollHint.verticalAlignmentMode = .center
        scrollHint.horizontalAlignmentMode = .center
        scrollHint.zPosition = 51
        container.addChild(scrollHint)

        // 添加淡入淡出动画
        let fadeAction = SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 1.0),
            SKAction.fadeAlpha(to: 0.8, duration: 1.0)
        ])
        scrollHint.run(SKAction.repeatForever(fadeAction))
    }

    // 创建渐变指示器
    private func createGradientIndicator(width: CGFloat, height: CGFloat, isLeft: Bool) -> SKNode {
        let indicator = SKNode()

        // 创建多个矩形来模拟渐变效果
        let steps = 5
        for i in 0..<steps {
            let alpha = isLeft ? CGFloat(i) / CGFloat(steps - 1) : CGFloat(steps - 1 - i) / CGFloat(steps - 1)
            let rect = SKSpriteNode(color: SKColor.black.withAlphaComponent(alpha * 0.5),
                                   size: CGSize(width: width / CGFloat(steps), height: height))
            rect.position = CGPoint(x: CGFloat(i) * width / CGFloat(steps) - width/2 + width/(CGFloat(steps)*2), y: 0)
            indicator.addChild(rect)
        }

        return indicator
    }

    // 创建关卡按钮
    private func createLevelButton(level: LevelInfo, buttonSize: CGSize, xPosition: CGFloat, yPosition: CGFloat) -> SKNode {
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: xPosition, y: yPosition)

        // 检查关卡是否解锁
        let isUnlocked = progressManager.isLevelUnlocked(level.id)

        // 按钮背景颜色
        let buttonColor = isUnlocked ? SKColor.blue.withAlphaComponent(0.8) : SKColor.gray.withAlphaComponent(0.5)

        // 添加圆角效果（通过创建圆角矩形路径）
        let cornerRadius: CGFloat = 10
        let roundedRect = SKShapeNode(rectOf: buttonSize, cornerRadius: cornerRadius)
        roundedRect.fillColor = buttonColor
        roundedRect.strokeColor = isUnlocked ? SKColor.white : SKColor.darkGray
        roundedRect.lineWidth = 2
        roundedRect.zPosition = 4
        roundedRect.name = "level_\(level.id)"

        // 关卡名称标签
        let levelLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        levelLabel.text = level.name
        levelLabel.fontSize = 16
        levelLabel.fontColor = isUnlocked ? SKColor.white : SKColor.darkGray
        levelLabel.position = CGPoint(x: 0, y: 8)
        levelLabel.verticalAlignmentMode = .center
        levelLabel.horizontalAlignmentMode = .center
        levelLabel.zPosition = 6

        // 关卡编号标签
        let levelNumberLabel = SKLabelNode(fontNamed: "Helvetica")
        levelNumberLabel.text = "\(level.id)"
        levelNumberLabel.fontSize = 12
        levelNumberLabel.fontColor = isUnlocked ? SKColor.lightGray : SKColor.darkGray
        levelNumberLabel.position = CGPoint(x: 0, y: -8)
        levelNumberLabel.verticalAlignmentMode = .center
        levelNumberLabel.horizontalAlignmentMode = .center
        levelNumberLabel.zPosition = 6

        // 组装按钮
        buttonContainer.addChild(roundedRect)
        buttonContainer.addChild(levelLabel)
        buttonContainer.addChild(levelNumberLabel)

        // 保存按钮引用
        levelButtons[level.id] = roundedRect

        // 如果未解锁，添加锁定图标或效果
        if !isUnlocked {
            let lockIcon = SKLabelNode(fontNamed: "Helvetica-Bold")
            lockIcon.text = "封锁中..."
            lockIcon.fontSize = 20
            lockIcon.position = CGPoint(x: buttonSize.width/2 - 15, y: buttonSize.height/2 - 15)
            lockIcon.zPosition = 7
            buttonContainer.addChild(lockIcon)
        }

        return buttonContainer
    }

    // 触摸相关属性
    private var touchStartLocation: CGPoint?
    private var touchStartTime: TimeInterval?
    private var isDragging = false
    private let dragThreshold: CGFloat = 10.0

    // 处理触摸开始
    func handleTouchBegan(at location: CGPoint) {
        touchStartLocation = location
        touchStartTime = CACurrentMediaTime()
        isDragging = false
    }

    // 处理触摸移动
    func handleTouchMoved(to location: CGPoint) {
        guard let startLocation = touchStartLocation else { return }

        let deltaX = location.x - startLocation.x

        // 检查是否开始拖拽
        if !isDragging && abs(deltaX) > dragThreshold {
            isDragging = true
        }

        if isDragging {
            // 查找可滚动的触摸区域
            let touchedNodes = nodes(at: startLocation)
            for node in touchedNodes {
                if node.name == "scrollTouchArea",
                   let userData = node.userData,
                   let scrollContainer = userData["scrollContainer"] as? SKNode,
                   let maxScrollX = userData["maxScrollX"] as? CGFloat,
                   let currentScrollX = userData["currentScrollX"] as? CGFloat {

                    // 计算新的滚动位置
                    let newScrollX = max(0, min(maxScrollX, currentScrollX - deltaX))

                    // 更新滚动容器位置
                    scrollContainer.position.x = -newScrollX

                    // 更新当前滚动位置
                    userData["currentScrollX"] = newScrollX

                    // 更新起始位置为当前位置，实现连续滑动
                    touchStartLocation = location
                    break
                }
            }
        }
    }

    // 处理触摸结束
    func handleTouchEnded(at location: CGPoint) {
        defer {
            touchStartLocation = nil
            touchStartTime = nil
            isDragging = false
        }

        // 如果是拖拽操作，不处理点击事件
        if isDragging {
            return
        }

        // 检查是否是快速点击（非拖拽）
        guard let startTime = touchStartTime,
              CACurrentMediaTime() - startTime < 0.3 else {
            return
        }

        // 处理关卡按钮点击
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            // 检查是否点击了关卡按钮
            if let buttonNode = node as? SKShapeNode,
               let buttonName = buttonNode.name,
               buttonName.hasPrefix("level_") {

                // 提取关卡ID
                let levelIdString = String(buttonName.dropFirst(6)) // 移除 "level_" 前缀
                guard let levelId = Int(levelIdString) else {
                    print("无效的关卡ID: \(levelIdString)")
                    return
                }

                // 检查关卡是否解锁
                if progressManager.isLevelUnlocked(levelId) {
                    print("选择了关卡\(levelId)")
                    delegate?.levelSelectionPanel(self, didSelectLevel: levelId)
                } else {
                    print("关卡\(levelId)尚未解锁")
                    delegate?.levelSelectionPanelDidRequestShowError(self, message: "关卡尚未解锁")
                }
                break
            }
        }
    }

    // 兼容旧的触摸处理方法
    func handleTouch(at location: CGPoint) {
        handleTouchBegan(at: location)
        handleTouchEnded(at: location)
    }

    // 刷新关卡按钮状态
    func refreshLevelButtons() {
        // 移除所有子节点
        removeAllChildren()

        // 清空容器和按钮引用
        chapterContainers.removeAll()
        levelButtons.removeAll()

        // 重新设置面板
        setupPanel()
    }
}
