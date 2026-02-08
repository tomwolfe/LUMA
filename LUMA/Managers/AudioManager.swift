import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var currentPlayer: AVAudioPlayer?
    private var nextPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    
    @Published var currentSound: SoundType = .rain
    
    enum SoundType: String, CaseIterable {
        case rain = "Rain"
        case ocean = "Ocean"
        case city = "City"
    }
    
    private init() {
        // Configure audio session for background playback and mixing
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func play() {
        guard let url = Bundle.main.url(forResource: currentSound.rawValue, withExtension: "mp3") else { return }
        
        do {
            currentPlayer = try AVAudioPlayer(contentsOf: url)
            currentPlayer?.numberOfLoops = -1
            currentPlayer?.volume = 1.0
            currentPlayer?.play()
        } catch {
            print("Could not play sound: \(error)")
        }
    }
    
    func stop() {
        currentPlayer?.stop()
        nextPlayer?.stop()
    }
    
    func setSound(_ sound: SoundType) {
        guard sound != currentSound || currentPlayer == nil else { return }
        
        let oldSound = currentSound
        currentSound = sound
        
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "mp3") else { return }
        
        do {
            nextPlayer = try AVAudioPlayer(contentsOf: url)
            nextPlayer?.numberOfLoops = -1
            nextPlayer?.volume = 0.0
            nextPlayer?.play()
            
            // Start cross-fade
            performCrossFade()
        } catch {
            print("Could not switch sound: \(error)")
        }
    }
    
    private func performCrossFade() {
        fadeTimer?.invalidate()
        
        let fadeDuration: TimeInterval = 2.0
        let steps = 20
        let stepInterval = fadeDuration / Double(steps)
        let volumeStep = 1.0 / Float(steps)
        
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: stepInterval, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            currentStep += 1
            
            let currentVol = self.currentPlayer?.volume ?? 0
            let nextVol = self.nextPlayer?.volume ?? 0
            
            self.currentPlayer?.volume = max(0, currentVol - volumeStep)
            self.nextPlayer?.volume = min(1.0, nextVol + volumeStep)
            
            if currentStep >= steps {
                timer.invalidate()
                self.currentPlayer?.stop()
                self.currentPlayer = self.nextPlayer
                self.nextPlayer = nil
                self.currentPlayer?.volume = 1.0
            }
        }
    }
}
