import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    
    private init() {}
    
    func leftTurn() {
        // Left turn = 1 short tap
        impactMedium.impactOccurred()
    }
    
    func rightTurn() {
        // Right turn = 2 short taps
        impactMedium.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactMedium.impactOccurred()
        }
    }
    
    func uTurn() {
        // U-turn = 3 rapid taps
        impactHeavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.impactHeavy.impactOccurred()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.impactHeavy.impactOccurred()
        }
    }
    
    func arrival() {
        // Arrival = 1 long, soft pulse
        // Note: Core Haptics would be better for a "long pulse", 
        // but for now we'll use a series or a specific feedback type.
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
