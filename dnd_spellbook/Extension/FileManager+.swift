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
        guard let image = image?.imageResized(to: CGSize(width: 60, height: 60)) else { return nil }
        let data: Data
        let filename: String
        
        if let jpeg = image.jpegData(compressionQuality: 0.2) {
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

extension UIImage {
    func imageResized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
