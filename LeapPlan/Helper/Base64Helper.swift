//
//  Base64Helper.swift
//  RecipeVault
//
//  Created by Wesley Goey on 31/05/26.
//

import UIKit

struct Base64Helper {
    // MARK: - Encode Image
    static func encode(_ image: UIImage, quality: CGFloat = 0.3) -> String? {
        let targetSize = CGSize(width: 400, height: 400)
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage.jpegData(compressionQuality: quality)?
            .base64EncodedString()
    }

    // MARK: - Decode Image
    static func decode(_ base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: data)
    }
}
