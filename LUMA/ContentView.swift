import SwiftUI

struct ContentView: View {
    @State private var appState: AppState = .home
    @State private var selectedPOI: POIItem?
    
    enum AppState {
        case home
        case search
        case navigation
        case arrival
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            switch appState {
            case .home:
                HomeView(onTap: { appState = .search })
            case .search:
                SearchView(
                    onSelect: { poi in 
                        selectedPOI = poi
                        appState = .navigation 
                    }, 
                    onCancel: { appState = .home }
                )
            case .navigation:
                if let poi = selectedPOI {
                    NavigationView(destination: poi, onArrive: { appState = .arrival })
                }
            case .arrival:
                ArrivalView(onFinish: { appState = .home })
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
