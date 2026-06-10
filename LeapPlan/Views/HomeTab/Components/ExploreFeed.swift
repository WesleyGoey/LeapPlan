//
//  ExploreFeed.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

// MARK: - Komponen Utama Pembungkus Feed
struct ExploreFeedView: View {
    let places: [FSQPlace]

    var body: some View {
        TabView {
            ForEach(places, id: \.fsq_place_id) { place in
                ExploreFeedCard(place: place)
            }
        }
        .frame(height: 500)
        .tabViewStyle(.page(indexDisplayMode: .always))
        .cornerRadius(30)
    }
}

// MARK: - Desain UI Tiap Kartu Feed
struct ExploreFeedCard: View {
    let place: FSQPlace

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 1. BACKGROUND GAMBAR DARI FOURSQUARE
            if let urlStr = place.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        // Tanda loading kalau internet lambat
                        ProgressView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            } else {
                // Gambar cadangan kalau tempatnya nggak ada foto
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }

            // 2. EFEK GELAP DI BAWAH (Biar teks putihnya kebaca)
            LinearGradient(
                colors: [.clear, .black.opacity(0.8)],
                startPoint: .center,
                endPoint: .bottom
            )

            // 3. TEKS INFORMASI DESTINASI
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(place.name)
                        .font(.title)
                        .bold()
                    Spacer()
                }

                // Nama Kota / Negara
                let locationName = place.location?.locality ?? place.location?.country ?? "Unknown Location"
                Label(locationName, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)

                // Rating & Review
                HStack {
                    let ratingVal = (place.rating ?? 0.0) / 2.0
                    let ratingStr = place.rating != nil ? String(format: "%.1f", ratingVal) : "N/A"

                    Label(ratingStr, systemImage: "star.fill")
                        .foregroundColor(.yellow)

                    let reviewCount = place.stats?.total_ratings ?? 0
                    Text("(\(reviewCount) reviews)")
                        .font(.caption)
                }
            }
            .foregroundColor(.white)
            .padding(30)
            .padding(.bottom, 50)
        }
    }
}
