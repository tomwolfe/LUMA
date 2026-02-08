import Foundation

class POIManager: ObservableObject {
    @Published var results: [POIItem] = []
    
    func search(query: String) {
        if query.isEmpty {
            results = []
            return
        }
        
        // Search the SQLite database in real-time
        DispatchQueue.global(qos: .userInteractive).async {
            let matches = POIDatabase.shared.search(query: query)
            DispatchQueue.main.async {
                self.results = matches
            }
        }
    }
}
