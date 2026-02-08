import SwiftUI

struct HomeView: View {
    let onTap: () -> Void
    @State private var isPulsing = false
    
    var body: some View {
        VStack {
            Spacer()
            
            // Minimalist Compass Icon
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 1)
                    .frame(width: 80, height: 80)
                
                Rectangle()
                    .fill(Color.white)
                    .frame(width: 2, height: 40)
                    .offset(y: -10)
            }
            .opacity(isPulsing ? 0.95 : 0.4)
            .scaleEffect(isPulsing ? 1.0 : 0.98)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isPulsing
            )
            .onAppear {
                isPulsing = true
            }
            .onTapGesture {
                onTap()
            }
            
            Spacer()
        }
        .background(Color.black)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(onTap: {})
    }
}
