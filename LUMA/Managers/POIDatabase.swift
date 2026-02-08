import Foundation
import SQLite3

struct POIItem: Identifiable {
    let id: Int32
    let name: String
    let city: String
    let latitude: Double
    let longitude: Double
}

class POIDatabase {
    static let shared = POIDatabase()
    private var db: OpaquePointer?
    
    private init() {
        openDatabase()
    }
    
    private func openDatabase() {
        // Expected Schema:
        // CREATE TABLE pois (id INTEGER PRIMARY KEY, name TEXT, city TEXT, latitude REAL, longitude REAL);
        // CREATE INDEX idx_pois_name ON pois(name);
        // CREATE INDEX idx_pois_city ON pois(city);
        
        guard let path = Bundle.main.path(forResource: "pois", ofType: "sqlite") else {
            print("POI database not found in bundle.")
            return
        }
        
        if sqlite3_open(path, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }
    
    func search(query: String) -> [POIItem] {
        var results: [POIItem] = []
        guard let db = db else {
            print("Database not initialized")
            return results
        }
        
        var statement: OpaquePointer?
        let queryString = "SELECT id, name, city, latitude, longitude FROM pois WHERE name LIKE ? OR city LIKE ? LIMIT 50"
        
        if sqlite3_prepare_v2(db, queryString, -1, &statement, nil) == SQLITE_OK {
            let searchPattern = "%\(query)%"
            sqlite3_bind_text(statement, 1, (searchPattern as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 2, (searchPattern as NSString).utf8String, -1, nil)
            
            while sqlite3_step(statement) == SQLITE_ROW {
                let id = sqlite3_column_int(statement, 0)
                let name = String(cString: sqlite3_column_text(statement, 1))
                let city = String(cString: sqlite3_column_text(statement, 2))
                let lat = sqlite3_column_double(statement, 3)
                let lon = sqlite3_column_double(statement, 4)
                
                results.append(POIItem(id: id, name: name, city: city, latitude: lat, longitude: lon))
            }
        } else {
            print("Error preparing search statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        
        sqlite3_finalize(statement)
        return results
    }
}
