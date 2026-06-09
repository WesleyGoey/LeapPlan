//
//  WatchTripsView.swift
//  Leaplan_Watch Watch App
//

import SwiftUI

struct WatchTripsView: View {
    @ObservedObject var viewModel: WatchAppViewModel

    var filteredTrips: [Trip] {
        viewModel.trips.filter { $0.status == .upcoming || $0.status == .ongoing }
    }

    var body: some View {
        ZStack {
            // Main Background
            Color(hex: "#F2F2F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    // MARK: - Header Area
                    HStack {
                        Text("My Trips")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)

                        Spacer()

                        // Circular notification-style badge
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#E5E5EA"))
                                .frame(width: 24, height: 24)

                            Text("\(filteredTrips.count)")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(Color(hex: "#50B498"))
                        }
                    }
                    .padding(.horizontal, 4)
                    .padding(.bottom, 4)
                    .padding(.top, 8)

                    // MARK: - List Area
                    if filteredTrips.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 24))
                                .foregroundStyle(Color(hex: "#50B498").opacity(0.6))
                            Text("No active trips yet")
                                .font(.system(size: 12))
                                .foregroundStyle(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    } else {
                        ForEach(filteredTrips) { trip in
                            WatchTripCardView(trip: trip)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            viewModel.triggerManualSync()
        }
    }
}

// MARK: - Trip Card Design
struct WatchTripCardView: View {
    let trip: Trip

    private var barColor: Color {
        switch trip.status {
        case .upcoming: return Color(hex: "#50B498")
        case .ongoing: return Color.blue
        case .past: return Color.red
        }
    }
    
    private var pillBackgroundColor: Color {
        if trip.status == .upcoming {
            return Color(hex: "#50B498").opacity(0.15)
        }
        return Color.gray.opacity(0.15)
    }
    
    private var pillTextColor: Color {
        if trip.status == .upcoming {
            return Color(hex: "#2E8B57") // Darker green for text readability
        }
        return .gray
    }
    
    private func formattedDates() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: trip.startDate)) – \(formatter.string(from: trip.endDate))"
    }

    var body: some View {
        HStack(spacing: 0) {
            // Left color bar
            RoundedRectangle(cornerRadius: 2)
                .fill(barColor)
                .frame(width: 4)
                .padding(.vertical, 14)
                .padding(.leading, 8)
            
            VStack(alignment: .leading, spacing: 6) {
                // Dynamic Status Tag Pill
                Text(trip.status.rawValue.capitalized)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(pillTextColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule().fill(pillBackgroundColor)
                    )

                // Trip Title
                Text(trip.title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(1)
                
                // Dates
                Text(formattedDates())
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.gray)
            }
            .padding(.leading, 8)
            .padding(.vertical, 12)
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Color.gray.opacity(0.4))
                .padding(.trailing, 12)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
        )
        // Subtle shadow
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    let mockTrip1 = Trip(id: "1", title: "🌴 Bali Holiday", locationName: "Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400*10), status: .upcoming, participantIDs: [], createdAt: Date(), createdBy: "123")
    let mockTrip2 = Trip(id: "2", title: "🗼 Tokyo Escape", locationName: "Tokyo", startDate: Date(), endDate: Date().addingTimeInterval(86400*7), status: .ongoing, participantIDs: [], createdAt: Date(), createdBy: "123")
    let mockTrip3 = Trip(id: "3", title: "🗺️ Paris Spring", locationName: "Paris", startDate: Date(), endDate: Date().addingTimeInterval(86400*7), status: .past, participantIDs: [], createdAt: Date(), createdBy: "123")
    
    WatchTripsView(viewModel: .mock(isLoggedIn: true, trips: [mockTrip1, mockTrip2, mockTrip3]))
}
