//
//  ExploreView.swift
//  LeapPlan
//
//  Created by Wesley Goey on 01/06/26.
//

import SwiftUI
import MapKit

// MARK: - 1. MAIN MAP VIEW
struct ExploreView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    // State untuk mode pencarian melayang (Floating Search)
    @State private var isSearching = false
    @FocusState private var isSearchFocused: Bool
    
    // State khusus untuk menangkap klik pada tempat bawaan Apple Maps
    @State private var selectedMapFeature: MapFeature?
    
    var body: some View {
        ZStack(alignment: .top) {
            
            // LAYER 1: Full Screen Map
            Map(position: $viewModel.cameraPosition, selection: $selectedMapFeature) {
                
                // FIX: Menampilkan Indikator Titik Lokasi HP Pengguna Sekarang (Bulat Hijau)
                UserAnnotation {
                    ZStack {
                        Circle()
                            .fill(Color(red: 0/255, green: 173/255, blue: 133/255).opacity(0.2))
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                            .background(Circle().fill(Color(red: 0/255, green: 173/255, blue: 133/255)))
                            .frame(width: 14, height: 14)
                    }
                }
                
                // Menampilkan pin dari hasil pencarian Foursquare (Hanya muncul jika dicari dari bar)
                ForEach(viewModel.displayedPins) { place in
                    Marker(place.name, systemImage: getIconForCategory(place.name), coordinate: place.coordinate)
                        .tint(Color(red: 0/255, green: 173/255, blue: 133/255))
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
                    handleAppleMapFeatureClick(feature)
                }
            }
            // Mengembalikan peta bersih & menghilangkan sorotan POI jika detail sheet ditutup
            .onChange(of: viewModel.selectedPlace) { place in
                if place == nil {
                    selectedMapFeature = nil
                    viewModel.displayedPins = []
                }
            }
            
            // LAYER 2: Floating UI (Header Search Bar)
            VStack(spacing: 12) {
                if isSearching {
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            
                            TextField("Search destination...", text: $viewModel.searchQuery)
                                .focused($isSearchFocused)
                                .submitLabel(.search)
                                .onSubmit {
                                    if let firstRecommendation = viewModel.searchResults.first {
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            viewModel.selectPlace(firstRecommendation)
                                            isSearching = false
                                            isSearchFocused = false
                                        }
                                    }
                                }
                            
                            // Tombol Silang (X) untuk membatalkan pencarian secara instan
                            Button(action: {
                                withAnimation(.easeInOut) {
                                    viewModel.searchQuery = ""
                                    isSearching = false
                                    isSearchFocused = false
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 20))
                                    .padding(.leading, 8)
                            }
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                        
                        // Dropdown Rekomendasi Hasil Ketikan
                        if viewModel.isLoading {
                            ProgressView().padding().background(Color.white).clipShape(Circle()).shadow(radius: 5)
                        } else if !viewModel.searchResults.isEmpty {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(viewModel.searchResults) { place in
                                        Button(action: {
                                            withAnimation(.easeInOut(duration: 0.5)) {
                                                viewModel.selectPlace(place)
                                                isSearching = false
                                                isSearchFocused = false
                                            }
                                        }) {
                                            HStack(spacing: 15) {
                                                Image(systemName: "mappin.circle.fill")
                                                    .font(.title2)
                                                    .foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(place.name).font(.system(size: 16, weight: .semibold)).foregroundColor(.primary)
                                                    if let distance = place.distance {
                                                        Text("\(distance) meters away").font(.system(size: 12)).foregroundColor(.gray)
                                                    }
                                                }
                                                Spacer()
                                            }
                                            .padding(.vertical, 12).padding(.horizontal, 16)
                                        }
                                        Divider()
                                    }
                                }
                                .background(Color(.systemBackground)).cornerRadius(16)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                            }
                            .frame(maxHeight: 280).padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    
                } else {
                    // TAMPILAN IDLE SEARCH BAR BARU (Tanpa Category Pills di bawahnya)
                    Button(action: {
                        withAnimation { isSearching = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { isSearchFocused = true }
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass").foregroundColor(.gray)
                            Text(viewModel.searchQuery.isEmpty ? "Search on map..." : viewModel.searchQuery)
                                .foregroundColor(viewModel.searchQuery.isEmpty ? .gray : .primary)
                            Spacer()
                        }
                        .padding().background(Color(.systemBackground)).cornerRadius(30)
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                    }
                    .padding(.horizontal).padding(.top, 10)
                }
                
                Spacer()
                
                // Floating Action Button: Center to User GPS
                if !isSearching {
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.8)) { viewModel.centerToCurrentLocation() }
                        }) {
                            Image(systemName: "location.fill").font(.system(size: 20))
                                .foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                                .frame(width: 50, height: 50).background(Color.white).clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, viewModel.selectedPlace != nil ? 280 : 100)
                    }
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceDetailSheet(place: place)
                .presentationDetents([.fraction(0.35)])
                .presentationDragIndicator(.visible)
        }
    }
    
    // MARK: - Helper Functions
    private func handleAppleMapFeatureClick(_ feature: MapFeature) {
        let tempPlace = FSQPlace(
            fsq_place_id: UUID().uuidString,
            name: feature.title ?? "Selected Location",
            distance: 0,
            latitude: feature.coordinate.latitude,
            longitude: feature.coordinate.longitude,
            location: FSQLocation(locality: nil, country: nil),
            rating: nil,
            stats: nil
        )
        viewModel.selectPlace(tempPlace, isFromAppleMap: true)
    }
    
    private func getIconForCategory(_ name: String) -> String {
        let lowerName = name.lowercased()
        if lowerName.contains("apotek") || lowerName.contains("hospital") || lowerName.contains("rs ") || lowerName.contains("rumah sakit") { return "cross.case.fill" }
        if lowerName.contains("kopi") || lowerName.contains("cafe") || lowerName.contains("seafood") || lowerName.contains("makan") || lowerName.contains("resto") { return "cup.and.saucer.fill" }
        if lowerName.contains("univ") || lowerName.contains("school") || lowerName.contains("ciputra") { return "graduationcap.fill" }
        if lowerName.contains("hotel") || lowerName.contains("residence") { return "bed.double.fill" }
        return "mappin"
    }
}

// MARK: - 2. BOTTOM SHEET (Detail Lokasi)
struct PlaceDetailSheet: View {
    let place: FSQPlace
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("SELECTED PLACE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.top, 10)
            
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient(colors: [Color(red: 0/255, green: 173/255, blue: 133/255), Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white.opacity(0.8))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text(place.location?.locality ?? "Destination")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                        Text(String(format: "%.1f", place.rating ?? 4.9)).font(.caption).fontWeight(.bold)
                        Text("•").foregroundColor(.gray)
                        if let distance = place.distance, distance > 0 {
                            Text(formatDistance(distance)).font(.caption).foregroundColor(.gray)
                        }
                    }
                }
            }
            Spacer()
            
            Button(action: {
                print("Tambahkan \(place.name) ke Itinerary")
                dismiss()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add to Itinerary")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 0/255, green: 173/255, blue: 133/255))
                .cornerRadius(12)
            }
            .padding(.bottom, 20)
        }
        .padding(.horizontal, 24)
        .padding(.top, 10)
    }
    
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            let kilometers = Double(meters) / 1000.0
            return String(format: "%.1f km away", kilometers)
        } else { return "\(meters) m away" }
    }
}

#Preview{
    ExploreView()
}
