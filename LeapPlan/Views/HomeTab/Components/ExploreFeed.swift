//
//  ExploreFeed.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

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

struct ExploreFeedCard: View {
    let place: FSQPlace
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .overlay(Text("Placeholder: \(place.name)").foregroundColor(.gray))
            
            LinearGradient(colors: [.clear, .black.opacity(0.8)], startPoint: .center, endPoint: .bottom)
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(place.name)
                        .font(.title)
                        .bold()
                    Spacer()
                    // TOMBOL FAVORITE SUDAH DIHAPUS TOTAL DI SINI
                }
                
                let locationName = place.location?.locality ?? place.location?.country ?? "Unknown Location"
                Label(locationName, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                
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
