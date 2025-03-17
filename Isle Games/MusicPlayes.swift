import AVFoundation
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer? // Для фоновой музыки
    private var effectPlayer: AVAudioPlayer? // Для звуковых эффектов

    @Published var isSoundOn: Bool = false {
        didSet {
            if isSoundOn {
                playMusic()
            } else {
                stopMusic()
            }
        }
    }

    private init() {
        // Загружаем фоновую музыку
        if let url = Bundle.main.url(forResource: "audio", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
            } catch {
                print("Error loading background audio file: \(error.localizedDescription)")
            }
        }
    }

    func playMusic() {
        audioPlayer?.play()
    }

    func stopMusic() {
        audioPlayer?.stop()
    }

    // Новый метод для воспроизведения звуковых эффектов
    func playSound(_ soundName: String) {
        guard let url = Bundle.main.url(forResource: soundName, withExtension: "mp3") else {
            print("Sound file \(soundName).mp3 not found")
            return
        }
        do {
            effectPlayer = try AVAudioPlayer(contentsOf: url)
            effectPlayer?.play()
        } catch {
            print("Error playing sound \(soundName): \(error.localizedDescription)")
        }
    }
}
