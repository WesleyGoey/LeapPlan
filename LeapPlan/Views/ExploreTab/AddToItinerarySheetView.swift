//
//  AddToItinerarySheetView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 03/06/26.
//

import SwiftUI

struct AddToItinerarySheetView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var tripViewModel = TripViewModel()

    let place: FSQPlace
    @State private var selectedTrip: Trip? = nil
    @State private var selectedTab: TripStatus = .ongoing

    @State private var selectedDays: Set<Int> = []

    @State private var processingDays: Set<Int> = []

    @State private var isLoadingDayPlans: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
                if tripViewModel.isLoading {
                    ProgressView("Loading Itineraries...").padding(.top, 40)
                    Spacer()
                } else if tripViewModel.trips.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "briefcase").font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text("No Trips Found").font(.headline)
                        Text(
                            "Please create a trip first before adding an itinerary."
                        ).font(.subheadline).foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }.padding()
                } else if selectedTrip == nil {
                    VStack(spacing: 0) {
                        statusTabBar
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        let filteredTrips = tripViewModel.trips.filter { $0.status == selectedTab }
                        if filteredTrips.isEmpty {
                            Spacer()
                            Text("No \(selectedTab.rawValue) trips found.")
                                .foregroundColor(.gray)
                            Spacer()
                        } else {
                            List(filteredTrips) { trip in
                                Button(action: {
                                    withAnimation { selectedTrip = trip }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(trip.title).font(.headline)
                                                .foregroundColor(.primary)
                                            Text(trip.locationName).font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }.padding(.vertical, 4)
                                }
                            }.listStyle(.plain)
                        }
                    }
                } else if let trip = selectedTrip {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Sync \(place.name) to \(trip.title)")
                            .font(.subheadline.bold())
                            .foregroundColor(.gray)
                            .padding(.horizontal, 20).padding(.top, 16).padding(
                                .bottom,
                                8
                            )

                        if isLoadingDayPlans {
                            ProgressView("Scanning Database...").frame(
                                maxWidth: .infinity
                            ).padding(.top, 40)
                            Spacer()
                        } else {
                            let totalDays = calculateTotalDays(
                                start: trip.startDate,
                                end: trip.endDate
                            )
                            List(1...totalDays, id: \.self) { dayNum in
                                Button(action: {
                                    if !selectedDays.contains(dayNum) {
                                        toggleDaySync(dayNum: dayNum, trip: trip)
                                    }
                                }) {
                                    HStack {
                                        Text("Day \(dayNum)").font(.body)
                                            .foregroundColor(.primary)
                                        Spacer()

                                        if processingDays.contains(dayNum) {
                                            ProgressView()
                                        } else {
                                            Image(
                                                systemName:
                                                    selectedDays.contains(
                                                        dayNum
                                                    )
                                                    ? "checkmark.circle.fill"
                                                    : "circle"
                                            )
                                            .font(.title3)
                                            .foregroundColor(
                                                selectedDays.contains(dayNum)
                                                    ? Color.leapPrimary : .gray
                                            )
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .disabled(processingDays.contains(dayNum) || selectedDays.contains(dayNum))
                            }.listStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle(
                selectedTrip == nil ? "Choose Itinerary" : "Select Days"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if selectedTrip != nil {
                        Button("Back") {
                            withAnimation { selectedTrip = nil }
                        }
                    } else {
                        Button("Close") { dismiss() }
                    }
                }
            }
            .task {
                tripViewModel.loadUserTrips()
            }
            .onChange(of: selectedTrip) { _, newTrip in
                if let trip = newTrip, let id = trip.id {
                    Task {
                        isLoadingDayPlans = true
                        let plans = await tripViewModel.fetchDayPlans(for: id)
                        var foundDays = Set<Int>()
                        for plan in plans {
                            if plan.destinations.contains(where: {
                                $0.foursquareID == place.fsq_place_id
                            }) {
                                foundDays.insert(plan.dayNumber)
                            }
                        }
                        self.selectedDays = foundDays
                        isLoadingDayPlans = false
                    }
                } else {
                    self.selectedDays = []
                }
            }
        }
    }

    private func toggleDaySync(dayNum: Int, trip: Trip) {
        // Hanya bisa add, tidak bisa remove dari sheet ini
        guard !selectedDays.contains(dayNum) else { return }

        selectedDays.insert(dayNum)

        processingDays.insert(dayNum)

        Task {
            await tripViewModel.togglePlaceInDay(
                place: place,
                trip: trip,
                dayNum: dayNum,
                isAdding: true
            )
            processingDays.remove(dayNum)
        }
    }

    private var statusTabBar: some View {
        HStack(spacing: 0) {
            tabButton(title: "Ongoing", status: .ongoing).frame(maxWidth: .infinity)
            tabButton(title: "Upcoming", status: .upcoming).frame(maxWidth: .infinity)
            tabButton(title: "Past", status: .past).frame(maxWidth: .infinity)
        }.padding(.horizontal, 8)
    }

    private func tabButton(title: String, status: TripStatus) -> some View {
        let isActive = selectedTab == status
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = status
            }
        } label: {
            VStack(spacing: 8) {
                Text(title).font(
                    .system(size: 16, weight: isActive ? .bold : .medium)
                ).foregroundColor(isActive ? .leapPrimary : .gray)
                
                Rectangle().fill(isActive ? Color.leapPrimary : Color.clear)
                    .frame(height: 3).cornerRadius(1.5)
            }
        }
    }

    private func calculateTotalDays(start: Date, end: Date) -> Int {
        let components = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: start),
            to: Calendar.current.startOfDay(for: end)
        )
        return max(1, (components.day ?? 0) + 1)
    }
}
