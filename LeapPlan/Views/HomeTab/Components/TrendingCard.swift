//
//  TrendingCard.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

struct TrendingCard: View {
    let place: FSQPlace

    var body: some View {
        VStack(alignment: .leading) {
            // 🔥 NAMPILIN GAMBAR ASLI DARI API
            if let urlStr = place.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        ProgressView()
                    }
                }
                .frame(width: 140, height: 140)
                .clipped()
                .cornerRadius(15)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 140, height: 140)
                    .cornerRadius(15)
                    .overlay(
                        Text(String(place.name.prefix(1)))
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }

            Text(place.name)
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(1)

            // 🔥 RATING DINAMIS SKALA 5 BINTANG
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption2)
                
                let ratingVal = (place.rating ?? 0.0) / 2.0
                Text(place.rating != nil ? String(format: "%.1f", ratingVal) : "N/A")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .frame(width: 140)
    }
}
