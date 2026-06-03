//
//  ExploreView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 01/06/26.
//


import SwiftUI
import MapKit

struct ExploreView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    @State private var selectedMapFeature: MapFeature?
    @State private var isShowingAddToItinerarySheet = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // LAYER 1: Map
            Map(position: $viewModel.cameraPosition, selection: $selectedMapFeature) {
                UserAnnotation {
                    ZStack {
                        Circle().fill(Color(red: 0/255, green: 173/255, blue: 133/255).opacity(0.2)).frame(width: 32, height: 32)
                        Circle().stroke(Color.white, lineWidth: 2).background(Circle().fill(Color(red: 0/255, green: 173/255, blue: 133/255))).frame(width: 14, height: 14)
                    }
                }
                
                ForEach(viewModel.displayedPins) { place in
                    Marker(place.name, systemImage: viewModel.getIconForCategory(name: place.name), coordinate: place.coordinate)
                        .tint(Color(red: 0/255, green: 173/255, blue: 133/255))
                }
            }
            .ignoresSafeArea(edges: .top)
            .onTapGesture {
                withAnimation { isSearching = false; isSearchFocused = false }
            }
            .onChange(of: selectedMapFeature) { feature in
                if let feature = feature { viewModel.handleAppleMapFeatureClick(feature) }
            }
            .onChange(of: viewModel.selectedPlace) { place in
                if place == nil { selectedMapFeature = nil; viewModel.displayedPins = [] }
            }
            
            // LAYER 2: Search Bar UI
            VStack(spacing: 12) {
                if isSearching {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            TextField("Search destination...", text: $viewModel.searchQuery)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    if let first = viewModel.searchResults.first {
                                        withAnimation { viewModel.selectPlace(first); isSearching = false; isSearchFocused = false }
                                    }
                                }
                            
                            Button(action: {
                                withAnimation { viewModel.searchQuery = ""; isSearching = false; isSearchFocused = false }
                            }) { Image(systemName: "xmark.circle.fill").foregroundColor(.gray).font(.system(size: 20)).padding(.leading, 8) }
                        }
                        .padding().background(Color(.systemBackground)).cornerRadius(30).shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5).padding(.horizontal)
                        
                        if viewModel.isLoading {
                            ProgressView().padding().background(Color.white).clipShape(Circle()).shadow(radius: 5)
                        } else if !viewModel.searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.searchResults) { place in
                                        Button(action: {
                                            withAnimation { viewModel.selectPlace(place); isSearching = false; isSearchFocused = false }
                                        }) {
                                            HStack(spacing: 15) {
                                                Image(systemName: "mappin.circle.fill").font(.title2).foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(place.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                                    if let distance = place.distance { Text("\(distance) meters away").font(.system(size: 12)).foregroundColor(.gray) }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 12).padding(.horizontal, 16)
                                        }
                                        Divider()
                                    }
                                }
                                .background(Color(.systemBackground)).cornerRadius(16).shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            .frame(maxHeight: 280).padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                } else {
                    Button(action: {
                        withAnimation { isSearching = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isSearchFocused = true }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            Text(viewModel.searchQuery.isEmpty ? "Search on map..." : viewModel.searchQuery).foregroundColor(viewModel.searchQuery.isEmpty ? .gray : .primary)
                            Spacer()
                        }
                        .padding().background(Color(.systemBackground)).cornerRadius(30).shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal).padding(.top, 10)
                }
                
                Spacer()
                
                if !isSearching {
                    HStack {
                        Spacer()
                        Button(action: { withAnimation { viewModel.centerToCurrentLocation() } }) {
                            Image(systemName: "location.fill").font(.system(size: 20)).foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                                .frame(width: 50, height: 50).background(Color.white).clipShape(Circle()).shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.trailing, 20).padding(.bottom, viewModel.selectedPlace != nil ? 280 : 100)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            // LEMPAR STATUS LOGIN KE SHEET
            PlaceDetailSheet(place: place, isLoggedIn: viewModel.isLoggedIn, isTriggeringAddSheet: $isShowingAddToItinerarySheet)
                .presentationDetents([.fraction(0.35)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $isShowingAddToItinerarySheet) {
            if let placeToSave = viewModel.selectedPlace {
                AddToItinerarySheetView(place: placeToSave)
            }
        }
    }
}

// MARK: - 2. DETAIL PLACE SHEET
struct PlaceDetailSheet: View {
    let place: FSQPlace
    let isLoggedIn: Bool // BARU: Status Login
    @Environment(\.dismiss) var dismiss
    @Binding var isTriggeringAddSheet: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SELECTED PLACE").font(.caption).fontWeight(.bold).foregroundColor(.gray)
                Spacer()
                Button(action: { dismiss() }) { Image(systemName: "xmark.circle.fill").font(.title2).foregroundColor(.gray.opacity(0.8)) }
            }
            .padding(.top, 10)
            
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color(red: 0/255, green: 173/255, blue: 133/255), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .overlay(Image(systemName: "building.2.crop.circle.fill").font(.system(size: 40)).foregroundColor(.white.opacity(0.8)))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name).font(.title3).fontWeight(.bold)
                    Text(place.location?.locality ?? "Destination").font(.subheadline).foregroundColor(.gray)
                    HStack {
                        Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                        Text(String(format: "%.1f", place.rating ?? 4.9)).font(.caption).fontWeight(.bold)
                        Text("•").foregroundColor(.gray)
                        if let distance = place.distance, distance > 0 { Text(formatDistance(distance)).font(.caption).foregroundColor(.gray) }
                    }
                }
            }
            Spacer()
            
            // TOMBOL ADD TO ITINERARY (DENGAN GUEST MODE)
            VStack(spacing: 8) {
                Button(action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        isTriggeringAddSheet = true
                    }
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text("Add to Itinerary")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(isLoggedIn ? Color(red: 0/255, green: 173/255, blue: 133/255) : Color.gray) // Warna berubah abu-abu jika belum login
                    .cornerRadius(12)
                }
                .disabled(!isLoggedIn) // Tombol mati jika guest
                
                // Pesan Peringatan jika belum login
                if !isLoggedIn {
                    Text("Please login or register to add places to your itinerary.")
                        .font(.caption2)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24).padding(.top, 10)
    }
    
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 { return String(format: "%.1f km away", Double(meters) / 1000.0) }
        else { return "\(meters) m away" }
    }
}

#Preview{
    ExploreView()
}
