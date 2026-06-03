//
//  TripsView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import PhotosUI
import SwiftUI

struct TripsView: View {
    @StateObject var viewModel: TripViewModel
    @State private var selectedTab: TripStatus = .upcoming

    @State private var isShowingFABMenu: Bool = false
    @State private var navigationPath = NavigationPath()

    @State private var tripToEdit: Trip? = nil

    @State private var isShowingGenerateSheet = false
    @State private var isShowingManualSheet = false

    @MainActor
    init(viewModel: TripViewModel? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel ?? TripViewModel())
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .bottomTrailing) {
                Color(hex: "#F9F9F9").ignoresSafeArea()

                if isShowingFABMenu {
                    Color.black.opacity(0.2).ignoresSafeArea().onTapGesture {
                        withAnimation(.spring()) { isShowingFABMenu = false }
                    }.zIndex(1)
                }

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .bottom) {
                        Text("My Trips").font(
                            .system(size: 34, weight: .bold, design: .default)
                        ).foregroundColor(.leapSecondary)
                        Spacer()
                        Text("\(viewModel.trips.count) trips total").font(
                            .subheadline
                        ).foregroundColor(.gray).padding(.bottom, 6)
                    }
                    .padding(.horizontal, 20).padding(.top, 16)

                    statusTabBar.padding(.top, 20).padding(.bottom, 10)

                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 24) {
                            let filteredTrips = viewModel.trips.filter { trip in
                                trip.status == selectedTab
                            }.sorted(by: { $0.startDate > $1.startDate })

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
                        .padding(.horizontal, 20).padding(.top, 10).padding(
                            .bottom,
                            120
                        )
                    }
                }

                if viewModel.isLoggedIn {
                    createTripFAB.zIndex(2)
                }
            }
            .navigationDestination(for: TripRoute.self) { route in
                switch route {
                case .tripDetail(let trip): TripDetailView(trip: trip)
                }
            }
            .onAppear {
                if viewModel.isLoggedIn {
                    viewModel.loadUserTrips()
                } else {
                    viewModel.clearData()
                }
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: NSNotification.Name("UserLoggedOut")
                )
            ) { _ in
                viewModel.clearData()
            }
            .sheet(isPresented: $isShowingGenerateSheet) {
                GenerateItineraryView(viewModel: viewModel)
            }
            .sheet(isPresented: $isShowingManualSheet) {
                CreateManualTripView(viewModel: viewModel)
            }
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
                    isShowingManualSheet = true
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
                    isShowingGenerateSheet = true
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
                    )
                    .rotationEffect(.degrees(isShowingFABMenu ? 90 : 0))
            }
        }.padding(.trailing, 24).padding(.bottom, 24)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.questionmark").font(
                .system(size: 50)
            ).foregroundColor(.gray.opacity(0.5))

            if viewModel.isLoggedIn {
                Text("No \(selectedTab.rawValue) trips found.").font(.headline)
                    .foregroundColor(.gray)
                Text("Tap the + button to create a new itinerary.").font(
                    .subheadline
                ).foregroundColor(.gray.opacity(0.8)).multilineTextAlignment(
                    .center
                )
            } else {
                Text("You are not logged in.").font(.headline).foregroundColor(
                    .gray
                )
                Text("Please login or register to create and view your trips.")
                    .font(.subheadline).foregroundColor(.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }.padding(.top, 60)
    }
}

// MARK: - EDITOR DARI HALAMAN UTAMA (TripsView)
struct TripsEditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip

    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var coverImageUrl: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?

    init(viewModel: TripViewModel, trip: Trip) {
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
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            if let selectedUIImage {
                                Image(uiImage: selectedUIImage).resizable()
                                    .scaledToFill().frame(
                                        width: 150,
                                        height: 120
                                    ).clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                            } else if !coverImageUrl.isEmpty,
                                let uiImage = Base64Helper.decode(coverImageUrl)
                            {
                                Image(uiImage: uiImage).resizable()
                                    .scaledToFill().frame(
                                        width: 150,
                                        height: 120
                                    ).clipShape(
                                        RoundedRectangle(cornerRadius: 12)
                                    )
                            } else {
                                RoundedRectangle(cornerRadius: 12).fill(
                                    Color.gray.opacity(0.2)
                                ).frame(width: 150, height: 120).overlay(
                                    Image(systemName: "photo").font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                            }

                            HStack(spacing: 20) {
                                PhotosPicker(
                                    selection: $selectedPhotoItem,
                                    matching: .images,
                                    photoLibrary: .shared()
                                ) {
                                    Text("Change Photo").font(.subheadline)
                                        .foregroundColor(.leapPrimary)
                                }

                                if !coverImageUrl.isEmpty
                                    || selectedUIImage != nil
                                {
                                    Button(
                                        role: .destructive,
                                        action: {
                                            withAnimation {
                                                selectedUIImage = nil
                                                coverImageUrl = ""
                                                selectedPhotoItem = nil
                                            }
                                        }
                                    ) {
                                        Image(systemName: "trash").font(
                                            .subheadline
                                        ).foregroundColor(.leapHighlight)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
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
                                let base64 = Base64Helper.encode(
                                    selectedUIImage
                                )
                            {
                                finalImageUrl = base64
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
                    }.bold().foregroundColor(.leapPrimary)
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
    }
}
