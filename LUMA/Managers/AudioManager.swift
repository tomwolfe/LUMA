import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var player: AVAudioPlayer?
    
    @Published var currentSound: SoundType = .rain
    
    enum SoundType: String, CaseIterable {
        case rain = "Rain"
        case ocean = "Ocean"
        case city = "City"
    }
    
    private init() {}
    
    func play() {
        guard let url = Bundle.main.url(forResource: currentSound.rawValue, withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1 // Loop indefinitely
            player?.play()
        } catch {
            print("Could not play sound: \(error)")
        }
    }
    
    func stop() {
        player?.stop()
    }
    
    func setSound(_ sound: SoundType) {
        currentSound = sound
        if player?.isPlaying == true {
            play()
        }
    }
}
