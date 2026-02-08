import SwiftUI

struct SearchView: View {
    let onSelect: (POI) -> Void
    let onCancel: () -> Void
    @State private var searchText = ""
    @FocusState private var isFocused: Bool
    @StateObject private var poiManager = POIManager()
    
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
                }
                
                Spacer()
            }
        }
        .onAppear {
            isFocused = true
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
