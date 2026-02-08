import SwiftUI

struct SearchView: View {
    let onSelect: (POIItem) -> Void
    let onCancel: () -> Void
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @StateObject private var poiManager = POIManager()
    @ObservedObject private var mapManager = MapManager.shared
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                TextField("", text: $searchText)
                    .font(.system(size: 36, weight: .ultraLight, design: .monospaced))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .focused($isFocused)
                    .submitLabel(.go)
                    .onChange(of: searchText) { newValue in
                        poiManager.search(query: newValue)
                    }
                    .padding(.top, 100)
                
                if !poiManager.results.isEmpty {
                    ScrollView {
                        VStack(alignment: .center, spacing: 15) {
                            ForEach(poiManager.results) { poi in
                                Button(action: {
                                    onSelect(poi)
                                }) {
                                    VStack {
                                        Text(poi.name.uppercased())
                                            .font(.system(size: 18, weight: .light, design: .monospaced))
                                            .foregroundColor(.white)
                                        Text(poi.city.uppercased())
                                            .font(.system(size: 12, weight: .thin, design: .monospaced))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                } else if !searchText.isEmpty {
                    Text("NO RESULTS FOUND")
                        .font(.system(size: 14, weight: .thin, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            
            if !mapManager.isMapReady {
                VStack {
                    Text("OFFLINE DATA MISSING")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundColor(.red)
                    Text("PLEASE ENSURE THE APP IS PROPERLY INSTALLED")
                        .font(.system(size: 10, weight: .light, design: .monospaced))
                        .foregroundColor(.red)
                }
                .padding()
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            isFocused = true
            if !mapManager.isMapReady {
                showAlert = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Offline Data Missing"),
                message: Text("Please ensure the app is properly installed and all data files are present."),
                dismissButton: .default(Text("OK"))
            )
        }
        .onTapGesture {
            if searchText.isEmpty {
                onCancel()
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(onSelect: { _ in }, onCancel: {})
    }
}
