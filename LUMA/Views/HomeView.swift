import SwiftUI

struct HomeView: View {
    let onTap: () -> Void
    @State private var isPulsing = false
    @ObservedObject private var locationManager = LocationManager.shared
    @ObservedObject private var mapManager = MapManager.shared
    @State private var showAlert = false
    @State private var alertMessage = ""
    
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
                handleTap()
            }
            
            if locationManager.currentCity == nil {
                Text("LOCATING...")
                    .font(.system(size: 10, weight: .thin, design: .monospaced))
                    .foregroundColor(.gray)
                    .padding(.top, 20)
            }
            
            Spacer()
        }
        .background(Color.black)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("DATA UNAVAILABLE"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func handleTap() {
        guard let city = locationManager.currentCity else {
            alertMessage = "Waiting for your current location..."
            showAlert = true
            return
        }
        
        if mapManager.validateData(for: city) {
            onTap()
        } else {
            alertMessage = "Offline map data for \(city) is missing. Please download it to continue."
            showAlert = true
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(onTap: {})
    }
}
