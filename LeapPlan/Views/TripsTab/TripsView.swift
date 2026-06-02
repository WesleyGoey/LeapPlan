//
//  TripsView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import SwiftUI

enum TripRoute: Hashable {
    case tripDetail(Trip)
    case generateRandom
    case createManual
}

struct TripsView: View {
    @StateObject var viewModel: TripsViewModel
    @State private var selectedTab: TripStatus = .upcoming

    @State private var isShowingFABMenu: Bool = false
    @State private var navigationPath = NavigationPath()

    @MainActor
    init(viewModel: TripsViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TripsViewModel())
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                Color(hex: "#F9F9F9")
                    .ignoresSafeArea()

                // Overlay gelap saat FAB Menu terbuka
                if isShowingFABMenu {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                isShowingFABMenu = false
                            }
                        }
                        .zIndex(1)
                }

                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    HStack(alignment: .bottom) {
                        Text("My Trips")
                            .font(
                                .system(
                                    size: 34,
                                    weight: .bold,
                                    design: .default
                                )
                            )
                            .foregroundColor(.leapSecondary)
                        Spacer()
                        Text("\(viewModel.trips.count) trips total")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .padding(.bottom, 6)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    statusTabBar
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 24) {
                            let filteredTrips = viewModel.trips.filter {
                                $0.status == selectedTab
                            }

                            if filteredTrips.isEmpty {
                                emptyStateView
                            } else {
                                ForEach(filteredTrips) { trip in
                                    NavigationLink(
                                        value: TripRoute.tripDetail(trip)
                                    ) {
                                        TripCardView(
                                            trip: trip,
                                            placesCount: trip.totalPlaces
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 120)
                    }
                }

                createTripFAB
                    .zIndex(2)
            }
            .navigationDestination(for: TripRoute.self) { route in
                switch route {
                case .tripDetail(let trip):
                    TripDetailView(trip: trip)

                case .generateRandom:
                    // MENGHUBUNGKAN UI DENGAN LOGIKA GENERATE
                    GenerateItineraryView { preferences in
                        let title = "\(preferences.locationName) Trip"

                        do {
                            // Tunggu proses download Foursquare selesai
                            let newTrip =
                                try await viewModel.generateRandomTrip(
                                    preferences: preferences,
                                    title: title
                                )

                            // MAGIC: Tutup layar Generate, dan Pindah ke TripDetailView
                            navigationPath.removeLast()
                            navigationPath.append(TripRoute.tripDetail(newTrip))

                        } catch {
                            print("Gagal generate: \(error)")
                        }
                    }

                case .createManual:
                    Text("Create Manual View")  // Placeholder
                }
            }
            .onAppear {
                viewModel.loadUserTrips()
            }
        }
    }

    // MARK: - Subviews
    private var statusTabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Upcoming", status: .upcoming)
                .frame(maxWidth: .infinity)
            tabButton(title: "Ongoing", status: .ongoing)
                .frame(maxWidth: .infinity)
            tabButton(title: "Past", status: .past)
                .frame(maxWidth: .infinity)
        }
        .padding(8)
    }

    private func tabButton(title: String, status: TripStatus) -> some View {
        let isActive = selectedTab == status
        let count = viewModel.trips.filter { $0.status == status }.count

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = status
            }
        } label: {
            VStack(spacing: 8) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(
                            .system(
                                size: 16,
                                weight: isActive ? .bold : .medium
                            )
                        )
                        .foregroundColor(isActive ? .leapPrimary : .gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("\(count)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isActive ? .white : .gray)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            isActive
                                ? Color.leapPrimary : Color.gray.opacity(0.2)
                        )
                        .clipShape(Capsule())
                }
                Rectangle()
                    .fill(isActive ? Color.leapPrimary : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
    }

    private var createTripFAB: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if isShowingFABMenu {
                Button {
                    withAnimation { isShowingFABMenu = false }
                    navigationPath.append(TripRoute.createManual)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "pencil")
                            .foregroundColor(.gray)
                        Text("Create Manual")
                            .fontWeight(.semibold)
                            .foregroundColor(.leapSecondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))

                Button {
                    withAnimation { isShowingFABMenu = false }
                    navigationPath.append(TripRoute.generateRandom)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.leapPrimary)
                        Text("Create Random")
                            .fontWeight(.semibold)
                            .foregroundColor(.leapPrimary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isShowingFABMenu.toggle()
                }
            } label: {
                Image(systemName: isShowingFABMenu ? "xmark" : "plus")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        isShowingFABMenu
                            ? Color.leapSecondary : Color.leapPrimary
                    )
                    .clipShape(Circle())
                    .shadow(
                        color: (isShowingFABMenu
                            ? Color.leapSecondary : Color.leapPrimary).opacity(
                                0.4
                            ),
                        radius: 10,
                        y: 5
                    )
                    .rotationEffect(.degrees(isShowingFABMenu ? 90 : 0))
            }
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 50))
                .foregroundColor(.gray.opacity(0.5))
            Text("No \(selectedTab.rawValue) trips found.")
                .font(.headline)
                .foregroundColor(.gray)
            Text("Tap the + button to create a new itinerary.")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }
}

// MARK: - Preview Mocks
#if DEBUG
    private class PreviewTripRepository: TripRepositoryProtocol {
        var dummyTrips: [Trip] = []

        func fetchTrips(forUserID userID: String) async throws -> [Trip] {
            return dummyTrips
        }
        func createTrip(_ trip: Trip, forUserID userID: String) async throws {}
        func updateTrip(_ trip: Trip, forUserID userID: String) async throws {}
        func deleteTrip(tripID: String, forUserID userID: String) async throws {
        }

        func fetchDayPlans(forTripID tripID: String, userID: String)
            async throws -> [DayPlan]
        { return [] }
        func saveDayPlan(
            _ dayPlan: DayPlan,
            forTripID tripID: String,
            userID: String
        ) async throws {}
        func saveGeneratedTripWithDayPlans(
            trip: Trip,
            dayPlans: [DayPlan],
            userID: String
        ) async throws {}
        
        func deleteDayPlan(planID: String, tripID: String, userID: String) async throws {}
    }

    private class PreviewAuthService: AuthServiceProtocol {
        func register(email: String, password: String) async throws -> String {
            return "user1"
        }
        func login(email: String, password: String) async throws -> String {
            return "user1"
        }
        func getCurrentUserID() -> String? { return "user1" }
        func updateEmail(currentPassword: String, newEmail: String) async throws
        {}
        func updatePassword(currentPassword: String, newPassword: String)
            async throws
        {}
        func deleteUser(password: String) async throws {}
        func logout() throws {}
    }

    private class PreviewTripGenService: TripGenerationServiceProtocol {
        func generateRandomItinerary(preferences: RandomTripPreferences)
            async throws -> [DayPlan]
        { return [] }
    }

    #Preview("Trips View") {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"

        let trip1 = Trip(
            id: "1",
            title: "Kyoto Autumn Trip",
            locationName: "Kyoto, Japan",
            startDate: formatter.date(from: "2026/11/10")!,
            endDate: formatter.date(from: "2026/11/18")!,
            status: .upcoming,
            coverImageUrl:
                "https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?q=80&w=800&auto=format&fit=crop",
            participantIDs: ["user1"],
            totalPlaces: 8,
            createdAt: Date(),
            createdBy: "user1"
        )

        let trip2 = Trip(
            id: "2",
            title: "Santorini Getaway",
            locationName: "Santorini, Greece",
            startDate: formatter.date(from: "2026/08/14")!,
            endDate: formatter.date(from: "2026/08/20")!,
            status: .upcoming,
            coverImageUrl:
                "https://images.unsplash.com/photo-1613395877344-13d4a8e0d49e?q=80&w=800&auto=format&fit=crop",
            participantIDs: ["user1"],
            totalPlaces: 6,
            createdAt: Date(),
            createdBy: "user1"
        )

        let previewRepo = PreviewTripRepository()
        previewRepo.dummyTrips = [trip1, trip2]

        let viewModel = TripsViewModel(
            tripRepository: previewRepo,
            authService: PreviewAuthService(),
            tripGenService: PreviewTripGenService()
        )

        viewModel.trips = previewRepo.dummyTrips

        return TripsView(viewModel: viewModel)
    }
#endif
