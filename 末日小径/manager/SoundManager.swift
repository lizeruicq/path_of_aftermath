import SpriteKit
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    
    private var backgroundMusicPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [String: AVAudioPlayer] = [:]
    
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
                backgroundMusicPlayer?.volume = 0.3 // 设置音量
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
        if let player = soundEffectPlayers[name] {
            // 如果音效正在播放，先重置到开始位置
            if player.isPlaying {
                player.currentTime = 0
            }
            player.play()
            print("Playing sound effect: \(name)")
        } else {
            print("Sound effect not found: \(name)")
        }
    }
}




