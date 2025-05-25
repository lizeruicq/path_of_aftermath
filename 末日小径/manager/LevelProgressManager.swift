//
//  LevelProgressManager.swift
//  末日小径
//
//  Created for 末日小径 game
//

import Foundation

class LevelProgressManager {
    // 单例模式
    static let shared = LevelProgressManager()

    // UserDefaults 键
    private let unlockedLevelsKey = "UnlockedLevels"

    // 已解锁的关卡集合
    private var unlockedLevels: Set<Int> = []

    // 私有初始化方法
    private init() {
        loadProgress()
    }

    // MARK: - 数据持久化

    // 从 UserDefaults 加载进度
    private func loadProgress() {
        let savedLevels = UserDefaults.standard.array(forKey: unlockedLevelsKey) as? [Int] ?? []
        unlockedLevels = Set(savedLevels)

        // 如果没有保存的进度，默认解锁第一关
        if unlockedLevels.isEmpty {
            unlockedLevels.insert(1)
            saveProgress()
        }

        print("已加载关卡进度: \(unlockedLevels.sorted())")
    }

    // 保存进度到 UserDefaults
    private func saveProgress() {
        let levelsArray = Array(unlockedLevels).sorted()
        UserDefaults.standard.set(levelsArray, forKey: unlockedLevelsKey)
        UserDefaults.standard.synchronize()
        print("已保存关卡进度: \(levelsArray)")
    }

    // MARK: - 关卡解锁逻辑

    // 检查关卡是否已解锁
    func isLevelUnlocked(_ levelId: Int) -> Bool {
        return unlockedLevels.contains(levelId)
    }

    // 解锁关卡
    func unlockLevel(_ levelId: Int) {
        guard levelId > 0 && levelId <= getTotalLevels() else {
            print("无效的关卡ID: \(levelId)")
            return
        }

        if !unlockedLevels.contains(levelId) {
            unlockedLevels.insert(levelId)
            saveProgress()
            print("🔓 关卡 \(levelId) 已解锁")
        }
    }

    // 完成关卡时的解锁逻辑
    func completeLevel(_ levelId: Int) {
        // 确保当前关卡已解锁
        unlockLevel(levelId)

        // 解锁下一关
        let nextLevelId = levelId + 1
        if nextLevelId <= getTotalLevels() {
            unlockLevel(nextLevelId)
        }

        // 检查是否完成了当前大关，如果是，解锁下一个大关的第一关
        checkAndUnlockNextChapter(completedLevelId: levelId)
    }

    // 检查并解锁下一个大关
    private func checkAndUnlockNextChapter(completedLevelId: Int) {
        let chapters = LevelStructure.chapters

        for (chapterIndex, chapter) in chapters.enumerated() {
            // 检查完成的关卡是否是当前大关的最后一关
            if let lastLevel = chapter.levels.last, lastLevel.id == completedLevelId {
                // 如果不是最后一个大关，解锁下一个大关的第一关
                if chapterIndex + 1 < chapters.count {
                    let nextChapter = chapters[chapterIndex + 1]
                    if let firstLevelOfNextChapter = nextChapter.levels.first {
                        unlockLevel(firstLevelOfNextChapter.id)
                        print("🎉 完成大关 \(chapter.name)，解锁新大关 \(nextChapter.name)")
                    }
                }
                break
            }
        }
    }

    // MARK: - 辅助方法

    // 获取总关卡数
    func getTotalLevels() -> Int {
        return LevelStructure.chapters.reduce(0) { total, chapter in
            total + chapter.levels.count
        }
    }

    // 获取已解锁的关卡列表
    func getUnlockedLevels() -> [Int] {
        return Array(unlockedLevels).sorted()
    }

    // 获取关卡信息
    func getLevelInfo(for levelId: Int) -> (chapterName: String, levelName: String)? {
        for chapter in LevelStructure.chapters {
            for level in chapter.levels {
                if level.id == levelId {
                    return (chapter.name, level.name)
                }
            }
        }
        return nil
    }

    // 获取大关的解锁状态
    func getChapterUnlockStatus() -> [(chapter: ChapterConfig, unlockedCount: Int, totalCount: Int)] {
        return LevelStructure.chapters.map { chapter in
            let unlockedCount = chapter.levels.filter { isLevelUnlocked($0.id) }.count
            return (chapter, unlockedCount, chapter.levels.count)
        }
    }

    // 重置所有进度（用于测试或重新开始游戏）
    func resetProgress() {
        unlockedLevels.removeAll()
        unlockedLevels.insert(1) // 重新解锁第一关
        saveProgress()
        print("🔄 已重置所有关卡进度")
    }

    // MARK: - 调试方法

    // 解锁所有关卡（仅用于调试）
    func unlockAllLevels() {
        for i in 1...getTotalLevels() {
            unlockedLevels.insert(i)
        }
        saveProgress()
        print("🔓 已解锁所有关卡（调试模式）")
    }

    // 解锁前几关用于测试（仅用于调试）
    func unlockFirstFewLevels() {
        for i in 1...6 { // 解锁前6关用于测试
            unlockedLevels.insert(i)
        }
        saveProgress()
        print("🔓 已解锁前6关用于测试")
    }
}
