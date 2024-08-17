import Foundation
import Foundation


func saveJson<T: Codable>(data: T, to filename: String) {
    let documentDirectory = "/Users/zgalbs/src/xcode/Hypertrofind/Hypertrofind/Json"
    let fileURL = URL(fileURLWithPath: documentDirectory).appendingPathComponent(filename)
    
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(data)
        try jsonData.write(to: fileURL, options: .atomic)
        print("Data saved successfully to \(filename)")
    } catch {
        print("Failed to save data to \(filename): \(error)")
    }
}

func loadJson<T: Codable>(from filename: String) -> T? {
    let documentDirectory = "/Users/zgalbs/src/xcode/Hypertrofind/Hypertrofind/Json"
    let fileURL = URL(fileURLWithPath: documentDirectory).appendingPathComponent(filename)
    
    do {
        let data = try Data(contentsOf: fileURL)
        let decodedData = try JSONDecoder().decode(T.self, from: data)
        return decodedData
    } catch {
        print("Failed to load data from \(filename): \(error)")
        return nil
    }
}
