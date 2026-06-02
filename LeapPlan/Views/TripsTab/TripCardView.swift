//
//  TripCardView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    // Karena jumlah tempat (Places) berada di dalam sub-collection (DayPlan),
    // kita bisa me-pass nilainya dari ViewModel. Defaultnya kita set 0 untuk UI.
    var placesCount: Int = 0 
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // 1. Background Image
            AsyncImage(url: URL(string: trip.coverImageUrl ?? "")) { phase in
                switch phase {
                case .empty:
                    // Placeholder saat loading
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(ProgressView())
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    // Fallback jika tidak ada gambar/gagal load
                    Rectangle()
                        .fill(Color.leapSecondary.opacity(0.8))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundColor(.white.opacity(0.5))
                                .font(.largeTitle)
                        )
                @unknown default:
                    EmptyView()
                }
            }
            .frame(height: 220)
            .clipped()
            
            // 2. Gradient Overlay (Agar teks putih tetap terbaca di gambar terang)
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.3), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            
            // 3. Card Content
            VStack(alignment: .leading, spacing: 0) {
                // Top Row: Places Badge & Status Badge
                HStack {
                    // Places Badge (Glassmorphism effect)
                    if placesCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.leapHighlight)
                            Text("\(placesCount) Places")
                                .font(.caption.bold())
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                    
                    Spacer()
                    
                    // Status Badge
                    Text(trip.status.rawValue)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.leapPrimary)
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                // Bottom Row: Location, Title, Dates
                VStack(alignment: .leading, spacing: 6) {
                    // Location
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text(trip.locationName)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    
                    // Title
                    Text(trip.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Dates
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                        Text(formattedDateRange)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                }
            }
            .padding(16)
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
    }
    
    // MARK: - Helper Methods
    
    // Helper untuk memformat tanggal (Contoh: "Nov 10 – 18, 2026")
    private var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startString = formatter.string(from: trip.startDate)
        
        let endFormatter = DateFormatter()
        // Cek apakah tahunnya sama
        let startYear = Calendar.current.component(.year, from: trip.startDate)
        let endYear = Calendar.current.component(.year, from: trip.endDate)
        
        if startYear == endYear {
            endFormatter.dateFormat = "d, yyyy"
        } else {
            endFormatter.dateFormat = "MMM d, yyyy"
        }
        
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
