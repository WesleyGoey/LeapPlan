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
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // MARK: - Header Area
                HStack {
                    Text("My Trips")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    // Circular notification-style badge
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#50B498"))
                            .frame(width: 22, height: 22)

                        Text("\(filteredTrips.count)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.black)
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)

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
            .padding(.vertical, 8)
        }
        .onAppear {
            viewModel.triggerManualSync()
        }
    }
}

// MARK: - Trip Card Design
struct WatchTripCardView: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dynamic Status Tag
            Text(trip.status.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(Color(hex: "#50B498"))
                )

            // Trip Title
            Text(trip.title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(white: 0.12)) // Organically integrated dark pill
        )
    }
}

#Preview {
    // We create some mock trips since the preview needs it
    let mockTrip1 = Trip(id: "1", title: "Bali Getaway", locationName: "Bali", startDate: Date(), endDate: Date().addingTimeInterval(86400*3), totalCost: 1000, description: "", createdAt: Date(), updatedAt: Date(), creatorId: "123", status: .upcoming, destinationIds: [])
    let mockTrip2 = Trip(id: "2", title: "Japan Tour", locationName: "Tokyo", startDate: Date(), endDate: Date().addingTimeInterval(86400*7), totalCost: 2000, description: "", createdAt: Date(), updatedAt: Date(), creatorId: "123", status: .ongoing, destinationIds: [])
    
    WatchTripsView(viewModel: .mock(isLoggedIn: true, trips: [mockTrip1, mockTrip2]))
}
