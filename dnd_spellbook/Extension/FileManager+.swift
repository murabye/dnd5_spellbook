//
//  FileManager+.swift
//  dnd_spellbook
//
//  Created by Влада Кузнецова on 04.03.2024.
//

import Foundation
import UIKit

extension FileManager {
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }

    func save(image: UIImage?) -> URL? {
        guard let image else { return nil }
        let data: Data
        let filename: String
        
        if let jpeg = image.jpegData(compressionQuality: 0.5) {
            data = jpeg
            filename = "\(UUID().uuidString).jpeg"
        } else if let png = image.pngData() {
            data = png
            filename = "\(UUID().uuidString).png"
        } else {
            return nil
        }
        
        let fileUrl = getDocumentsDirectory().appendingPathComponent(filename)
        
        do {
            try data.write(to: fileUrl)
        } catch {
            return nil
        }
        return fileUrl
    }
    
    func load(fileName: String) -> UIImage? {
        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {
            return nil
        }
    }
}
