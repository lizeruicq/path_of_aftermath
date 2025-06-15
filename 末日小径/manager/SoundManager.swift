import SpriteKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
    // 音效优先级（数字越大优先级越高）
    private let soundPriorities: [String: Int] = [
        "zombie_death":3,
        "tower_destroy":3,
        "super_shot": 2,
        "shotgun_shot": 3,
        "rifle_shot": 3,
        "knife_shot": 1,
        "chaingun_shot": 2
    ]
    
    // 全局音效冷却计时器
    private var globalSoundCooldownTimer: TimeInterval = 0
    private let globalSoundCooldownDuration: TimeInterval = 0.05  // 50毫秒的全局冷却时间
    
    // 最大同时播放的音效数量
    private let maxConcurrentSounds = 4
    private var currentlyPlayingSounds = 0
    
    private init() {
        configureAudioSession()
        setupBackgroundMusic()
        setupSoundEffects()
    }
    
    var isSoundEnabled: Bool = true
    
    func toggleSound() {
        isSoundEnabled = !isSoundEnabled
        
        if isSoundEnabled {
            playBackgroundMusic()
            resetCooldownTimer()
        } else {
            stopBackgroundMusic()
        }
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func setupBackgroundMusic() {
        print("Setting up background music...")
        if let path = Bundle.main.path(forResource: "bgm", ofType: "mp3") {
            print("Found background music file at: \(path)")
            let url = URL(fileURLWithPath: path)
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: url)
                backgroundMusicPlayer?.prepareToPlay()
                backgroundMusicPlayer?.numberOfLoops = -1 // 无限循环
                backgroundMusicPlayer?.volume = 0.8 // 设置音量
                print("Successfully created background music player")
            } catch {
                print("Failed to load background music: \(error)")
            }
        } else {
            print("Background music file not found")
        }
    }
    
    private func setupSoundEffects() {
        print("Setting up sound effects...")

        // 配置所有音效（包含不同格式）
        let soundEffects: [String: String] = [
            "touch": "pistol.wav",
            "chaingun_shot":"chaingun_shot.wav",
            "click":"click.flac",
            "zombie_death":"zombie_death.wav",
            "error":"error.flac",
            "knife_shot":"knife_shot.mp3",
            "rifle_shot":"rifle_shot.wav",
            "shotgun_shot":"shotgun_shot.wav",
            "super_shot":"super_shot.wav",
            "tower_destroy":"tower_destroy.mp3",
            "upshort":"upshort.wav"
            
            
            // 添加更多音效时可自由指定格式
        ]

        for (effectName, fileName) in soundEffects {
            // 提取文件名和扩展名
            let components = fileName.split(separator: ".")
            guard components.count >= 2 else { continue }
            let resourceName = String(components[0])
            let fileExtension = String(components[1])

            if let path = Bundle.main.path(forResource: resourceName, ofType: fileExtension) {
                print("Found sound effect file: \(fileName)")
                let url = URL(fileURLWithPath: path)
                do {
                    let player = try AVAudioPlayer(contentsOf: url)
                    player.prepareToPlay()
                    player.volume = 0.3 // 设置音效音量
                    soundEffectPlayers[effectName] = player
                    print("Successfully created player for: \(effectName)")
                } catch {
                    print("Failed to load sound effect \(effectName): \(error)")
                }
            } else {
                print("Sound effect file not found: \(fileName)")
            }
        }

        print("Loaded sound effects: \(soundEffectPlayers.keys.joined(separator: ", "))")
    }
    
    func playBackgroundMusic() {
        guard isSoundEnabled else { return }
        if backgroundMusicPlayer?.isPlaying == true {
            print("Background music is already playing")
            return
        }
        
        if let player = backgroundMusicPlayer {
            player.play()
            print("Started playing background music")
        } else {
            print("Background music player is not initialized")
        }
    }
    
    func stopBackgroundMusic() {
        if let player = backgroundMusicPlayer {
            player.stop()
            print("Stopped background music")
        }
    }
    
    func playSoundEffect(_ name: String, in scene: SKScene) {
        guard isSoundEnabled else { return }
        
        // 检查全局冷却
        if globalSoundCooldownTimer > 0 {
            print("冷却时间未结束")
            return
        }
        
        // 检查同时播放的音效数量
        if currentlyPlayingSounds >= maxConcurrentSounds {
            print("当前播放音效队列已满")
            return
        }
        
        // 获取音效优先级
        let priority = soundPriorities[name] ?? 0
        
        // 检查是否有更高优先级的音效正在播放
        if currentlyPlayingSounds > 0 && priority < getHighestPlayingPriority() {
            return
        }
        
        if let player = soundEffectPlayers[name] {
            // 如果音效正在播放，先重置到开始位置
            if player.isPlaying {
                player.currentTime = 0
            }
            
            // 播放音效
            player.play()
            currentlyPlayingSounds += 1
            
            // 设置全局冷却
            globalSoundCooldownTimer = globalSoundCooldownDuration
            
            // 监听音效播放完成
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) { [weak self] in
                self?.currentlyPlayingSounds -= 1
            }
            
            print("Playing sound effect: \(name)")
        } else {
            print("Sound effect not found: \(name)")
        }
    }
    
    // 获取当前正在播放的音效中的最高优先级
    private func getHighestPlayingPriority() -> Int {
        var highestPriority = 0
        for (name, player) in soundEffectPlayers {
            if player.isPlaying {
                highestPriority = max(highestPriority, soundPriorities[name] ?? 0)
            }
        }
        return highestPriority
    }
    
    public func resetCooldownTimer()
    {
        if globalSoundCooldownTimer > 0 {
            globalSoundCooldownTimer = 0
        }
    }
    
    // 更新全局冷却计时器（在场景的update方法中调用）
    func update(deltaTime: TimeInterval) {
        if globalSoundCooldownTimer > 0 {
            globalSoundCooldownTimer -= deltaTime
        }
    }
}




