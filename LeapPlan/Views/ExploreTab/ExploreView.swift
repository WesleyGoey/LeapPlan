//
//  ExploreView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 01/06/26.
//

import MapKit
import SwiftUI

struct ExploreView: View {
    @StateObject private var viewModel = SearchViewModel()

    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @State private var selectedMapFeature: MapFeature?

    @State private var placeToAdd: FSQPlace? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Map(
                position: $viewModel.cameraPosition,
                selection: $selectedMapFeature
            ) {
                UserAnnotation {
                    ZStack {
                        Circle().fill(Color.leapPrimary.opacity(0.2)).frame(
                            width: 32,
                            height: 32
                        )
                        Circle().stroke(Color.white, lineWidth: 2).background(
                            Circle().fill(Color.leapPrimary)
                        ).frame(width: 14, height: 14)
                    }
                }

                ForEach(viewModel.displayedPins) { place in
                    Marker(
                        place.name,
                        systemImage: viewModel.getIconForCategory(
                            name: place.name
                        ),
                        coordinate: place.coordinate
                    )
                    .tint(Color.leapPrimary)
                }
            }
            .ignoresSafeArea(edges: .top)
            .onTapGesture {
                withAnimation {
                    isSearching = false
                    isSearchFocused = false
                }
            }
            .onChange(of: selectedMapFeature) { feature in
                if let feature = feature {
                    viewModel.handleAppleMapFeatureClick(feature)
                }
            }
            .onChange(of: viewModel.selectedPlace) { place in
                if place == nil {
                    selectedMapFeature = nil
                    viewModel.displayedPins = []
                }
            }

            VStack(spacing: 12) {
                if isSearching {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            TextField(
                                "Search destination...",
                                text: $viewModel.searchQuery
                            )
                            .focused($isSearchFocused)
                            .submitLabel(.search)
                            .onSubmit {
                                if let first = viewModel.searchResults.first {
                                    withAnimation {
                                        viewModel.selectPlace(first)
                                        isSearching = false
                                        isSearchFocused = false
                                    }
                                }
                            }

                            Button(action: {
                                withAnimation {
                                    viewModel.searchQuery = ""
                                    isSearching = false
                                    isSearchFocused = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray).font(
                                        .system(size: 20)
                                    ).padding(.leading, 8)
                            }
                        }
                        .padding().background(Color(.systemBackground))
                        .cornerRadius(30).shadow(
                            color: Color.black.opacity(0.15),
                            radius: 10,
                            x: 0,
                            y: 5
                        ).padding(.horizontal)

                        if viewModel.isLoading {
                            ProgressView().padding().background(Color.white)
                                .clipShape(Circle()).shadow(radius: 5)
                        } else if !viewModel.searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.searchResults) { place in
                                        Button(action: {
                                            withAnimation {
                                                viewModel.selectPlace(place)
                                                isSearching = false
                                                isSearchFocused = false
                                            }
                                        }) {
                                            HStack(spacing: 15) {
                                                RoundedRectangle(
                                                    cornerRadius: 8
                                                ).fill(
                                                    Color.leapPrimary.opacity(0.12)
                                                ).frame(
                                                    width: 40,
                                                    height: 40
                                                ).overlay(
                                                    Image(systemName: "mappin.circle.fill")
                                                        .foregroundColor(.leapPrimary.opacity(0.7))
                                                )

                                                VStack(
                                                    alignment: .leading,
                                                    spacing: 4
                                                ) {
                                                    Text(place.name).font(
                                                        .system(
                                                            size: 16,
                                                            weight: .semibold
                                                        )
                                                    ).foregroundColor(.primary)
                                                    if let distance = place
                                                        .distance
                                                    {
                                                        Text(
                                                            "\(distance) meters away"
                                                        ).font(
                                                            .system(size: 12)
                                                        ).foregroundColor(.gray)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 12).padding(
                                                .horizontal,
                                                16
                                            )
                                        }
                                        Divider()
                                    }
                                }
                                .background(Color(.systemBackground))
                                .cornerRadius(16).shadow(
                                    color: Color.black.opacity(0.1),
                                    radius: 10,
                                    x: 0,
                                    y: 5
                                )
                            }
                            .frame(maxHeight: 280).padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                } else {
                    Button(action: {
                        withAnimation { isSearching = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isSearchFocused = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                            Text(
                                viewModel.searchQuery.isEmpty
                                    ? "Search on map..." : viewModel.searchQuery
                            ).foregroundColor(
                                viewModel.searchQuery.isEmpty ? .gray : .primary
                            )
                            Spacer()
                        }
                        .padding().background(Color(.systemBackground))
                        .cornerRadius(30).shadow(
                            color: Color.black.opacity(0.1),
                            radius: 5,
                            x: 0,
                            y: 2
                        )
                    }
                    .padding(.horizontal).padding(.top, 10)

                    HStack {
                        Spacer()
                        Text("LeapPlan")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.leapPrimary)
                            .padding(.horizontal, 24)
                            .padding(.top, 4)
                            .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                    }
                }

                Spacer()

                if !isSearching {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation {
                                viewModel.centerToCurrentLocation()
                            }
                        }) {
                            Image(systemName: "location.fill").font(
                                .system(size: 20)
                            ).foregroundColor(Color.leapPrimary)
                                .frame(width: 50, height: 50).background(
                                    Color.white
                                ).clipShape(Circle()).shadow(
                                    color: Color.black.opacity(0.2),
                                    radius: 5,
                                    x: 0,
                                    y: 2
                                )
                        }
                        .padding(.trailing, 20).padding(
                            .bottom,
                            viewModel.selectedPlace != nil ? 280 : 100
                        )
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceDetailSheet(
                place: place,
                isLoggedIn: viewModel.isLoggedIn,
                placeToAdd: $placeToAdd
            )
            .presentationDetents([.fraction(0.35)])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $placeToAdd) { placeToSave in
            AddToItinerarySheetView(place: placeToSave)
        }
    }
}

// MARK: - 2. DETAIL PLACE SHEET
struct PlaceDetailSheet: View {
    let place: FSQPlace
    let isLoggedIn: Bool
    @Environment(\.dismiss) var dismiss

    @Binding var placeToAdd: FSQPlace?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SELECTED PLACE").font(.caption).fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill").font(.title2)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.top, 10)

            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [Color.leapPrimary, Color.teal],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 36))
                            .foregroundColor(.white.opacity(0.9))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name).font(.title3).fontWeight(.bold)
                    Text(place.location?.locality ?? "Destination").font(
                        .subheadline
                    ).foregroundColor(.gray)
                    HStack {
                        if let distance = place.distance, distance > 0 {
                            Image(systemName: "location.fill")
                                .font(.caption).foregroundColor(.gray)
                            Text(formatDistance(distance)).font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.top, 12)

            VStack(spacing: 8) {
                Button(action: {
                    let p = place
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        placeToAdd = p
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to Itinerary")
                    }
                    .font(.headline).foregroundColor(.white).frame(
                        maxWidth: .infinity
                    ).padding(.vertical, 14)
                    .background(isLoggedIn ? Color.leapPrimary : Color.gray)
                    .cornerRadius(12)
                }
                .disabled(!isLoggedIn)

                if !isLoggedIn {
                    Text(
                        "Please login or register to add places to your itinerary."
                    )
                    .font(.caption2).foregroundColor(.gray)
                }
            }
            .padding(.top, 4)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 24).padding(.top, 16)
    }

    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            return String(format: "%.1f km away", Double(meters) / 1000.0)
        } else {
            return "\(meters) m away"
        }
    }
}

#Preview {
    ExploreView()
}
