//
//  ResourceManager.swift
//  末日小径
//
//  Created for 末日小径 game
//

import SpriteKit

class ResourceManager {
    // 单例模式
    static let shared = ResourceManager()
    
    // 纹理缓存
    private var textureCache: [String: SKTexture] = [:]
    
    // 纹理集缓存
    private var textureAtlasCache: [String: SKTextureAtlas] = [:]
    
    // 动画帧缓存
    private var animationFramesCache: [String: [SKTexture]] = [:]
    
    // 是否已预加载
    private var preloaded = false
    
//    let buttonimg = SKTexture(imageNamed: "button")
    
    // 私有初始化方法
    private init() {}
    
    // 预加载所有游戏资源
    func preloadAllResources(completion: @escaping (Bool) -> Void) {
        // 如果已经预加载过，直接返回成功
        if preloaded {
            completion(true)
            return
        }
        
        // 需要预加载的纹理名称
        var textureNames: [String] = []
        
        // 添加关卡背景
        for i in 1...9 {
            textureNames.append("level-\(i)")
        }
        
        textureNames.append("logo2")
        
        // 添加僵尸纹理
        for i in 1...7 {
            textureNames.append("walker_move_\(i)")
        }
        
        for i in 1...5 {
            textureNames.append("sword_move_\(i)")
        }
        for i in 1...4 {
            textureNames.append("runner_move_\(i)")
        }
        for i in 1...5 {
            textureNames.append("trans_move_\(i)")
        }
        for i in 1...4 {
            textureNames.append("boomer_move_\(i)")
        }
        for i in 1...4 {
            textureNames.append("plant_move_\(i)")
        }

        
        // 添加炮塔纹理
        textureNames.append("rifle_idle")
        for i in 1...3 {
            textureNames.append("rifle_shoot_\(i)")
        }
        textureNames.append("shotgun_idle")
        for i in 1...3 {
            textureNames.append("shotgun_shoot_\(i)")
        }
        textureNames.append("super_idle")
        for i in 1...5 {
            textureNames.append("super_shoot_\(i)")
        }
        textureNames.append("chaingun_idle")
        
        textureNames.append("knife_idle")
        for i in 1...5 {
            textureNames.append("knife_shoot_\(i)")
        }
        
        // 创建纹理数组
        let textures = textureNames.map { name -> SKTexture in
            let texture = SKTexture(imageNamed: name)
            texture.filteringMode = .linear
            return texture
        }
        
        // 将纹理添加到缓存
        for (index, name) in textureNames.enumerated() {
            textureCache[name] = textures[index]
        }
        
        // 预加载所有纹理
        SKTexture.preload(textures) {
            print("所有纹理预加载完成")
            
            // 预加载动画帧
            self.preloadAnimationFrames()
            
            // 标记为已预加载
            self.preloaded = true
            
            // 在主线程上调用完成回调
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
    
    // 预加载动画帧
    private func preloadAnimationFrames() {
        // 预加载僵尸移动动画
        var walkerMoveFrames: [SKTexture] = []
        for i in 1...7 {
            let textureName = "walker_move_\(i)"
            if let texture = textureCache[textureName] {
                walkerMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                walkerMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["walker_move"] = walkerMoveFrames
        
        var swordMoveFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "sword_move_\(i)"
            if let texture = textureCache[textureName] {
                swordMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                swordMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["sword_move"] = swordMoveFrames
        
        var runnerMoveFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "runner_move_\(i)"
            if let texture = textureCache[textureName] {
                runnerMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                runnerMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["runner_move"] = runnerMoveFrames
        
        var transMoveFrames: [SKTexture] = []
        for i in 1...3 {
            let textureName = "trans_move_\(i)"
            if let texture = textureCache[textureName] {
                transMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                transMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["trans_move"] = transMoveFrames
        
        var boomerMoveFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "boomer_move_\(i)"
            if let texture = textureCache[textureName] {
                boomerMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                boomerMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["boomer_move"] = boomerMoveFrames
        
        var plantMoveFrames: [SKTexture] = []
        for i in 1...4 {
            let textureName = "plant_move_\(i)"
            if let texture = textureCache[textureName] {
                plantMoveFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                plantMoveFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["plant_move"] = plantMoveFrames
        
        
        
        // 预加载步枪射击动画
        var rifleShootFrames: [SKTexture] = []
        for i in 1...3 {
            let textureName = "rifle_shoot_\(i)"
            if let texture = textureCache[textureName] {
                rifleShootFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                rifleShootFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["rifle_shoot"] = rifleShootFrames
        
        // 预加载霰弹枪射击动画
        var shotgunShootFrames: [SKTexture] = []
        for i in 1...3 {
            let textureName = "shotgun_shoot_\(i)"
            if let texture = textureCache[textureName] {
                shotgunShootFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                shotgunShootFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["shotgun_shoot"] = shotgunShootFrames
        
        // 预加超级战士射击动画
        var supergunShootFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "super_shoot_\(i)"
            if let texture = textureCache[textureName] {
                supergunShootFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                supergunShootFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["super_shoot"] = supergunShootFrames
        
        // 预加刀战兵射击动画
        var knifeShootFrames: [SKTexture] = []
        for i in 1...5 {
            let textureName = "knife_shoot_\(i)"
            if let texture = textureCache[textureName] {
                knifeShootFrames.append(texture)
            } else {
                let texture = SKTexture(imageNamed: textureName)
                texture.filteringMode = .linear
                knifeShootFrames.append(texture)
                textureCache[textureName] = texture
            }
        }
        animationFramesCache["knife_shoot"] = knifeShootFrames
    
}
    
    // 获取纹理
    func getTexture(named name: String) -> SKTexture {
        // 如果缓存中有，直接返回
        if let texture = textureCache[name] {
            return texture
        }
        
        // 否则创建新的纹理并缓存
        let texture = SKTexture(imageNamed: name)
        texture.filteringMode = .linear
        textureCache[name] = texture
        return texture
    }
    
    // 获取动画帧
    func getAnimationFrames(forKey key: String) -> [SKTexture]? {
        return animationFramesCache[key]
    }
    
    // 创建动画动作
    func createAnimation(forKey key: String, timePerFrame: TimeInterval, repeatForever: Bool = false) -> SKAction? {
        guard let frames = animationFramesCache[key] else {
            return nil
        }
        
        let animation = SKAction.animate(with: frames, timePerFrame: timePerFrame)
        
        if repeatForever {
            return SKAction.repeatForever(animation)
        } else {
            return animation
        }
    }
}
