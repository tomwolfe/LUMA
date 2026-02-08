import SwiftUI

struct ArrivalView: View {
    let onFinish: () -> Void
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            // Placeholder for destination image
            Image(systemName: "photo")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeIn(duration: 1.0)) {
                        opacity = 1.0
                    }
                    
                    // Auto-dismiss after 5 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                        withAnimation(.easeOut(duration: 1.0)) {
                            opacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            onFinish()
                        }
                    }
                }
        }
    }
}
