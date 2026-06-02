//
//  TripsView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

//
//  TripsView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import PhotosUI  // PENTING: Untuk layar edit foto
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

    // State untuk mengetahui Trip mana yang sedang diedit dari Context Menu
    @State private var tripToEdit: Trip? = nil

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

                                    // MARK: - FITUR HOLD (CONTEXT MENU)
                                    .contextMenu {
                                        Button {
                                            // Buka Halaman Edit
                                            tripToEdit = trip
                                        } label: {
                                            Label(
                                                "Edit Trip",
                                                systemImage: "pencil"
                                            )
                                        }

                                        Button(role: .destructive) {
                                            // Hapus Trip
                                            if let tripID = trip.id {
                                                withAnimation {
                                                    viewModel.deleteTrip(
                                                        tripID: tripID
                                                    )
                                                }
                                            }
                                        } label: {
                                            Label(
                                                "Delete Trip",
                                                systemImage: "trash"
                                            )
                                        }
                                    }
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
                    GenerateItineraryView { preferences in
                        let title = "\(preferences.locationName) Trip"
                        do {
                            let newTrip =
                                try await viewModel.generateRandomTrip(
                                    preferences: preferences,
                                    title: title
                                )
                            navigationPath.removeLast()
                            navigationPath.append(TripRoute.tripDetail(newTrip))
                        } catch { print("Gagal generate: \(error)") }
                    }

                case .createManual:
                    Text("Create Manual View")
                }
            }
            .onAppear {
                viewModel.loadUserTrips()
            }

            // MARK: - MUNCULKAN HALAMAN EDIT DARI LUAR
            .sheet(item: $tripToEdit) { trip in
                TripsEditSheetView(viewModel: viewModel, trip: trip)
            }
        }
    }

    // MARK: - Subviews
    private var statusTabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Upcoming", status: .upcoming).frame(
                maxWidth: .infinity
            )
            tabButton(title: "Ongoing", status: .ongoing).frame(
                maxWidth: .infinity
            )
            tabButton(title: "Past", status: .past).frame(maxWidth: .infinity)
        }.padding(8)
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
                    Text(title).font(
                        .system(size: 16, weight: isActive ? .bold : .medium)
                    ).foregroundColor(isActive ? .leapPrimary : .gray)
                        .lineLimit(1).minimumScaleFactor(0.8)
                    Text("\(count)").font(.system(size: 12, weight: .bold))
                        .foregroundColor(isActive ? .white : .gray).padding(
                            .horizontal,
                            6
                        ).padding(.vertical, 2).background(
                            isActive
                                ? Color.leapPrimary : Color.gray.opacity(0.2)
                        ).clipShape(Capsule())
                }
                Rectangle().fill(isActive ? Color.leapPrimary : Color.clear)
                    .frame(height: 3).cornerRadius(1.5)
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
                        Image(systemName: "pencil").foregroundColor(.gray)
                        Text("Create Manual").fontWeight(.semibold)
                            .foregroundColor(.leapSecondary)
                    }.padding(.horizontal, 20).padding(.vertical, 14)
                        .background(Color.white).clipShape(Capsule()).shadow(
                            color: .black.opacity(0.1),
                            radius: 5,
                            y: 2
                        )
                }.transition(.move(edge: .bottom).combined(with: .opacity))

                Button {
                    withAnimation { isShowingFABMenu = false }
                    navigationPath.append(TripRoute.generateRandom)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "sparkles").foregroundColor(
                            .leapPrimary
                        )
                        Text("Create Random").fontWeight(.semibold)
                            .foregroundColor(.leapPrimary)
                    }.padding(.horizontal, 20).padding(.vertical, 14)
                        .background(Color.white).clipShape(Capsule()).shadow(
                            color: .black.opacity(0.1),
                            radius: 5,
                            y: 2
                        )
                }.transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    isShowingFABMenu.toggle()
                }
            } label: {
                Image(systemName: isShowingFABMenu ? "xmark" : "plus").font(
                    .system(size: 24, weight: .medium)
                ).foregroundColor(.white).frame(width: 64, height: 64)
                    .background(
                        isShowingFABMenu
                            ? Color.leapSecondary : Color.leapPrimary
                    ).clipShape(Circle()).shadow(
                        color: (isShowingFABMenu
                            ? Color.leapSecondary : Color.leapPrimary).opacity(
                                0.4
                            ),
                        radius: 10,
                        y: 5
                    ).rotationEffect(.degrees(isShowingFABMenu ? 90 : 0))
            }
        }.padding(.trailing, 24).padding(.bottom, 24)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark").font(
                .system(size: 50)
            ).foregroundColor(.gray.opacity(0.5))
            Text("No \(selectedTab.rawValue) trips found.").font(.headline)
                .foregroundColor(.gray)
            Text("Tap the + button to create a new itinerary.").font(
                .subheadline
            ).foregroundColor(.gray.opacity(0.8)).multilineTextAlignment(
                .center
            )
        }.padding(.top, 60)
    }
}

// MARK: - TAMPILAN EDITOR DARI HALAMAN UTAMA
struct TripsEditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripsViewModel
    let trip: Trip

    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var coverImageUrl: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?

    init(viewModel: TripsViewModel, trip: Trip) {
        self.viewModel = viewModel
        self.trip = trip
        _title = State(initialValue: trip.title)
        _startDate = State(initialValue: trip.startDate)
        _endDate = State(initialValue: trip.endDate)
        _coverImageUrl = State(initialValue: trip.coverImageUrl ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Cover Image") {
                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        if let selectedUIImage {
                            Image(uiImage: selectedUIImage).resizable()
                                .scaledToFill().frame(height: 150).clipShape(
                                    RoundedRectangle(cornerRadius: 12)
                                )
                        } else {
                            HStack {
                                Image(systemName: "photo.badge.plus").font(
                                    .title2
                                )
                                Text("Upload image from phone")
                            }.foregroundColor(.leapPrimary).padding(
                                .vertical,
                                8
                            )
                        }
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(
                                type: Data.self
                            ), let img = UIImage(data: data) {
                                selectedUIImage = img
                            }
                        }
                    }
                }
                Section("Trip Information") {
                    TextField("Trip Name", text: $title)
                }
                Section(
                    footer: Text(
                        "If you reduce the travel dates, the extra days from your itinerary will be permanently deleted."
                    )
                ) {
                    DatePicker(
                        "Start Date",
                        selection: $startDate,
                        displayedComponents: .date
                    )
                    DatePicker(
                        "End Date",
                        selection: $endDate,
                        displayedComponents: .date
                    )
                }
            }
            .navigationTitle("Edit Trip").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            var finalImageUrl = coverImageUrl
                            if let selectedUIImage,
                                let localPath = viewModel.saveImageLocally(
                                    image: selectedUIImage
                                )
                            {
                                finalImageUrl = localPath
                            }
                            await viewModel.updateTripDetails(
                                trip: trip,
                                title: title,
                                startDate: startDate,
                                endDate: endDate,
                                coverImageUrl: finalImageUrl
                            )
                            dismiss()
                        }
                    }.bold()
                }
            }
        }
    }
}

// MARK: - Preview Mocks (Disingkat agar muat)
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
        func deleteDayPlan(planID: String, tripID: String, userID: String)
            async throws
        {}
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
            title: "Kyoto Trip",
            locationName: "Kyoto",
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
        let previewRepo = PreviewTripRepository()
        previewRepo.dummyTrips = [trip1]
        let viewModel = TripsViewModel(
            tripRepository: previewRepo,
            authService: PreviewAuthService(),
            tripGenService: PreviewTripGenService()
        )
        viewModel.trips = previewRepo.dummyTrips
        return TripsView(viewModel: viewModel)
    }
#endif
