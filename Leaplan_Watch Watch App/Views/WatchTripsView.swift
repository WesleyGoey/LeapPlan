#if os(watchOS)
//
//  WatchTripsView.swift
//  Leaplan_Watch Watch App
//
//  Created by Wesley Goey on 10/06/26.
//

import SwiftUI

struct WatchTripsView: View {
    @EnvironmentObject private var appViewModel: WatchAppViewModel

    var filteredTrips: [Trip] {
        appViewModel.trips
    }

    var body: some View {
        ZStack {
            Color(hex: "#F2F2F7")
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("My Trips")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.black)

                        Spacer()

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
            appViewModel.triggerManualSync()
        }
    }
}

// MARK: - Watch Trip Card View
struct WatchTripCardView: View {
    let trip: Trip

    private var barColor: Color {
        switch trip.status {
        case .upcoming: return Color(hex: "#00AD85")
        case .ongoing: return Color(hex: "#FF2E63")
        case .past: return Color.gray
        }
    }
    
    private var pillBackgroundColor: Color {
        if trip.status == .upcoming {
            return Color(hex: "#00AD85").opacity(0.15)
        } else if trip.status == .ongoing {
            return Color(hex: "#FF2E63").opacity(0.15)
        }
        return Color.gray.opacity(0.15)
    }
    
    private var pillTextColor: Color {
        if trip.status == .upcoming {
            return Color(hex: "#00AD85")
        } else if trip.status == .ongoing {
            return Color(hex: "#FF2E63")
        }
        return .gray
    }
    
    // MARK: - Formatted Dates
    private func formattedDates() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: trip.startDate)) – \(formatter.string(from: trip.endDate))"
    }

    var body: some View {
        NavigationLink(destination: WatchTripDetailView(viewModel: WatchTripDetailViewModel(trip: trip))) {
            HStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 2)
                    .fill(barColor)
                    .frame(width: 4)
                    .padding(.vertical, 14)
                    .padding(.leading, 8)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(trip.status.rawValue.capitalized)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(pillTextColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule().fill(pillBackgroundColor)
                        )

                    Text(trip.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "#222831"))
                        .lineLimit(1)
                    
                    Text(formattedDates())
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.gray)
                }
                .padding(.leading, 8)
                .padding(.vertical, 12)
                
                Spacer()
            
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
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    WatchTripsView()
}

#endif
