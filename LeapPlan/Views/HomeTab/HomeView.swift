//
//  HomeView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 02/06/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @StateObject var profileVM = ProfileViewModel()
    @Binding var selectedTab: Int

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {

                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("LeapPlan").font(.largeTitle).fontWeight(.bold)
                                .foregroundColor(Color.leapPrimary)
                            Text("Plan your next adventure").font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()

                        Button(action: {
                            selectedTab = 3
                        }) {
                            if let base64 = profileVM.currentUser?
                                .profileImageUrl,
                                let uiImage = Base64Helper.decode(base64)
                            {
                                Image(uiImage: uiImage).resizable()
                                    .scaledToFill()
                                    .frame(width: 45, height: 45).clipShape(
                                        Circle()
                                    )
                                    .shadow(radius: 3)
                            } else {
                                Circle().fill(Color.leapPrimary)
                                    .frame(width: 45, height: 45)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.white)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if let trip = viewModel.recentTrip {
                        NavigationLink(destination: TripDetailView(trip: trip))
                        {
                            HomeRecentTripCard(
                                trip: trip,
                                placesCount: viewModel.recentTripPlacesCount
                            )
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        HomeEmptyRecentTripCard()
                            .padding(.horizontal)
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("🔥 Trending")
                                .font(.title3)
                                .bold()
                            Spacer()

                            Button(action: {
                                selectedTab = 1
                            }) {
                                Text("See All >")
                                    .font(.caption)
                                    .foregroundColor(.leapPrimary)
                            }
                        }
                        .padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView().padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(
                                        viewModel.trendingPlaces,
                                        id: \.fsq_place_id
                                    ) { place in
                                        HomeTrendingCard(place: place)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    VStack(alignment: .leading) {
                        HStack {
                            Text("🌍 Explore Destinations")
                                .font(.title3)
                                .bold()
                            Spacer()

                            Button(action: {
                                selectedTab = 1
                            }) {
                                Text("See All >")
                                    .font(.caption)
                                    .foregroundColor(.leapPrimary)
                            }
                        }
                        .padding(.horizontal)

                        if !viewModel.trendingPlaces.isEmpty {
                            VStack(spacing: 14) {
                                ForEach(
                                    viewModel.trendingPlaces,
                                    id: \.fsq_place_id
                                ) { place in
                                    HomeExploreRow(place: place)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top)
            }
            .onAppear {
                profileVM.loadProfile()
                Task { await viewModel.loadDashboardData() }
            }
        }
    }
}

struct HomeRecentTripCard: View {
    let trip: Trip
    let placesCount: Int

    private func dateRangeString(start: Date, end: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        let yearFmt = DateFormatter()
        yearFmt.dateFormat = ", yyyy"
        let startStr = fmt.string(from: start)
        let endStr = fmt.string(from: end) + yearFmt.string(from: end)
        return "\(startStr) – \(endStr)"
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let cover = trip.coverImageUrl,
                let img = Base64Helper.decode(cover)
            {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .overlay(Color.black.opacity(0.25))
            } else if let cover = trip.coverImageUrl,
                let url = URL(string: cover)
            {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().aspectRatio(contentMode: .fill)
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 200)
                .clipped()
                .overlay(Color.black.opacity(0.25))
            } else {
                LinearGradient(
                    colors: [
                        Color.leapPrimary.opacity(0.9), Color.teal.opacity(0.9),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
            }

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "airplane.departure")
                    Text(
                        "\(trip.status == .upcoming ? "UPCOMING" : trip.status == .ongoing ? "ONGOING" : "COMPLETED") TRIP"
                    )
                }
                .font(.caption2.weight(.bold))
                .foregroundColor(.white.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.12))
                .clipShape(Capsule())

                Text(trip.title)
                    .font(.title2).bold()
                    .foregroundColor(.white)

                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(
                        dateRangeString(
                            start: trip.startDate,
                            end: trip.endDate
                        )
                    )
                }
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))

                HStack(spacing: 8) {
                    Label(
                        "Countdown: \(trip.daysUntilTrip) Days Left",
                        systemImage: "clock.fill"
                    )
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(hex: "#00ADB5"))
                    .clipShape(Capsule())
                    .foregroundColor(.white)

                    if placesCount > 0 {
                        Text("\(placesCount) Places")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 6)
            }
            .padding(20)
        }
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

struct HomeEmptyRecentTripCard: View {
    var body: some View {
        ZStack(alignment: .leading) {
            LinearGradient(
                colors: [Color.gray.opacity(0.15), Color.gray.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 160)
            .cornerRadius(24)

            VStack(alignment: .leading, spacing: 6) {
                Text("Belum ada trip")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text("Buat trip pertamamu dari tab Explore.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(20)
        }
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct HomeTrendingCard: View {
    let place: FSQPlace

    private func tagText() -> String {
        if let locality = place.location?.locality, !locality.isEmpty {
            return locality
        }
        return "Place"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                if let urlStr = place.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if let image = phase.image {
                            image.resizable().scaledToFill()
                        } else {
                            RoundedRectangle(cornerRadius: 16).fill(
                                Color.gray.opacity(0.2)
                            )
                        }
                    }
                    .frame(width: 180, height: 120)
                    .clipped()
                    .cornerRadius(16)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.gray.opacity(0.15))
                        .frame(width: 180, height: 120)
                        .overlay(
                            Image(systemName: "photo").foregroundColor(.gray)
                        )
                }

                Text(tagText())
                    .font(.caption2.weight(.bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.9))
                    .clipShape(Capsule())
                    .padding(8)
            }

            Text(place.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)

            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
                Text(String(format: "%.1f", place.rating ?? 4.9))
                    .foregroundColor(.gray)
                    .font(.caption)
                if let total = place.stats?.total_ratings {
                    Text("(\(total))").foregroundColor(.gray).font(.caption)
                }
            }
        }
        .frame(width: 180)
    }
}

struct HomeExploreRow: View {
    let place: FSQPlace

    private func tagText() -> String {
        if let locality = place.location?.locality, !locality.isEmpty {
            return locality
        }
        return "Nature"
    }

    var body: some View {
        HStack(spacing: 12) {
            if let urlStr = place.imageURL, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if let image = phase.image {
                        image.resizable().scaledToFill()
                    } else {
                        Color.gray.opacity(0.2)
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 56, height: 56)
                    .overlay(Image(systemName: "photo").foregroundColor(.gray))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.headline)
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                    Text(
                        place.location?.country ?? place.location?.locality
                            ?? "Unknown"
                    )
                }
                .font(.caption)
                .foregroundColor(.gray)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.yellow)
                    Text(String(format: "%.1f", place.rating ?? 4.8))
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            Text(tagText())
                .font(.caption.weight(.bold))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
