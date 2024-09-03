import Foundation

// Function to get the URL for the Documents directory
func getDocumentsDirectory() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
}

// Function to save JSON data to the Documents directory
func saveJson<T: Codable>(data: T, to filename: String) {
    let documentDirectory = getDocumentsDirectory().appendingPathComponent("Hypertrofind/Json")
    
    do {
        // Create the directory if it doesn't exist
        try FileManager.default.createDirectory(at: documentDirectory, withIntermediateDirectories: true, attributes: nil)
        
        let fileURL = documentDirectory.appendingPathComponent("\(filename).json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL, options: .atomic)
        print("Data saved successfully to \(filename) at \(fileURL.path)")
    } catch {
        print("Failed to save data to \(filename): \(error)")
    }
}

func loadJson<T: Codable>(from filename: String) -> T? {
    let documentDirectory = getDocumentsDirectory().appendingPathComponent("Hypertrofind/Json")
    let fileURL = documentDirectory.appendingPathComponent("\(filename).json")
    
    if FileManager.default.fileExists(atPath: fileURL.path) {
        do {
            let data = try Data(contentsOf: fileURL)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Failed to load or decode \(filename).json from the Documents directory: \(error)")
        }
    } else {
        guard let bundleURL = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Failed to locate \(filename).json in the app bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: bundleURL)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            return decodedData
        } catch {
            print("Failed to load or decode \(filename).json from the app bundle: \(error)")
        }
    }
    
    return nil
}
