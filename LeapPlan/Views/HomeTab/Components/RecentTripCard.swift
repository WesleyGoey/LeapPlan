//
//  RecentTripCard.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

struct RecentTripCard: View {
    let trip: Trip  // Menerima data asli

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let coverUrlString = trip.coverImageUrl,
                let url = URL(string: coverUrlString)
            {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(height: 200)
                .clipped()
                .overlay(Color.black.opacity(0.3))
            } else {
                Color(hex: "#00ADB5").opacity(0.8)
                    .frame(height: 200)
                    .overlay(Color.black.opacity(0.2))
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("✈️ \(trip.status.rawValue.uppercased()) TRIP")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))

                Text(trip.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                HStack {
                    Image(systemName: "location.fill")
                    Text(trip.locationName)
                }
                .font(.caption)
                .foregroundColor(.white)

                HStack {
                    // Ngambil dari computed property daysUntilTrip milik modelmu
                    Label(
                        "Countdown: \(trip.daysUntilTrip) Days Left",
                        systemImage: "clock.fill"
                    )
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#00ADB5"))
                    .cornerRadius(20)

                    if trip.totalPlaces > 0 {
                        Text("\(trip.totalPlaces) Places")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .cornerRadius(20)
                    }
                }
                .foregroundColor(.white)
                .padding(.top, 8)
            }
            .padding(20)
        }
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
