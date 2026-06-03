//
//  TripCardView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import SwiftUI

struct TripCardView: View {
    let trip: Trip
    var placesCount: Int = 0
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Gambar Base64 / Fallback
            if let base64String = trip.coverImageUrl, let uiImage = Base64Helper.decode(base64String) {
                Image(uiImage: uiImage).resizable().scaledToFill().frame(height: 220).clipped()
            } else {
                // FALLBACK ICON DAN BACKGROUND GRADIENT
                ZStack {
                    LinearGradient(colors: [Color.leapPrimary.opacity(0.8), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "suitcase.fill").font(.system(size: 60)).foregroundColor(.white.opacity(0.4))
                }
                .frame(height: 220)
                .clipped()
            }
            
            // 2. Gradient Overlay
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.3), .clear],
                startPoint: .bottom, endPoint: .top
            )
            
            // 3. Card Content
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    if placesCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill").foregroundColor(.leapHighlight)
                            Text("\(placesCount) Places").font(.caption.bold()).foregroundColor(.white)
                        }
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    Spacer()
                    Text(trip.status.rawValue).font(.caption.bold()).foregroundColor(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8).background(Color.leapPrimary).clipShape(Capsule())
                }
                Spacer()
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(trip.locationName)
                    }.font(.subheadline).foregroundColor(.white.opacity(0.9))
                    
                    Text(trip.title).font(.title2).fontWeight(.bold).foregroundColor(.white).lineLimit(1)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(formattedDateRange)
                    }.font(.subheadline).foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    private var formattedDateRange: String {
        let formatter = DateFormatter(); formatter.dateFormat = "MMM d"
        let startString = formatter.string(from: trip.startDate)
        let endFormatter = DateFormatter()
        let startYear = Calendar.current.component(.year, from: trip.startDate)
        let endYear = Calendar.current.component(.year, from: trip.endDate)
        
        if startYear == endYear { endFormatter.dateFormat = "d, yyyy" }
        else { endFormatter.dateFormat = "MMM d, yyyy" }
        
        let endString = endFormatter.string(from: trip.endDate)
        return "\(startString) – \(endString)"
    }
}

#Preview("Trip Card") {
    ZStack {
        Color(hex: "#F5F7F8").ignoresSafeArea()
        
        let dummyTrip = Trip(
            id: "1",
            title: "Kyoto Autumn Trip",
            locationName: "Kyoto, Japan",
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 8, to: Date())!,
            status: .upcoming,
            coverImageUrl: "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=1000&auto=format&fit=crop",
            participantIDs: ["user1"],
            totalPlaces: 8,
            createdAt: Date(),
            createdBy: "user1"
        )
        
        TripCardView(trip: dummyTrip, placesCount: dummyTrip.totalPlaces)
            .padding()
    }
}
