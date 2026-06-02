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
    @State private var isShowingSearchScreen = false
    
    var body: some View {
        ZStack(alignment: .top) {
            // LAYER 1: Full Screen Map
            Map(coordinateRegion: $viewModel.mapRegion,
                annotationItems: viewModel.searchResults) { place in
                MapAnnotation(coordinate: place.coordinate) {
                    MapPinView(place: place, isSelected: viewModel.selectedPlace?.id == place.id)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.8)) {
                                viewModel.selectPlace(place)
                            }
                        }
                }
            }
            .ignoresSafeArea(edges: .top)
            
            // LAYER 2: Floating UI
            VStack(spacing: 12) {
                Button(action: {
                    isShowingSearchScreen = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        Text(viewModel.searchQuery.isEmpty ? "Search on map..." : viewModel.searchQuery)
                            .foregroundColor(viewModel.searchQuery.isEmpty ? .gray : .primary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(30)
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        CategoryPill(icon: "fork.knife", title: "Food", isSelected: false)
                        CategoryPill(icon: "camera", title: "Sights", isSelected: true)
                        CategoryPill(icon: "bed.double", title: "Stay", isSelected: false)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            viewModel.centerToCurrentLocation()
                        }
                    }) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                            .frame(width: 50, height: 50)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, viewModel.selectedPlace != nil ? 280 : 100)
                    .animation(.easeInOut, value: viewModel.selectedPlace)
                }
            }
        }
        .sheet(item: $viewModel.selectedPlace) { place in
            PlaceDetailSheet(place: place)
                .presentationDetents([.fraction(0.35)])
                .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $isShowingSearchScreen) {
            SearchInputScreen(viewModel: viewModel, isPresented: $isShowingSearchScreen)
        }
    }
}

// MARK: - 2. SEARCH INPUT SCREEN (DENGAN LIVE DATA & ERROR STATE DIAGNOSTIK)
struct SearchInputScreen: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var isPresented: Bool
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Input Field Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search here", text: $viewModel.searchQuery)
                        .focused($isInputFocused)
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Kondisi A: Menampilkan Indikator Memuat Data
                if viewModel.isLoading {
                    ProgressView("Mencari rekomendasi tempat...")
                        .padding(.top, 30)
                }
                
                // Kondisi B: MENAMPILKAN PESAN ERROR JIKA REQ KE SERVER GAGAL
                if let errorText = viewModel.errorMessage {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(.orange)
                        Text("Gagal Terhubung ke Foursquare")
                            .fontWeight(.semibold)
                        Text(errorText)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 40)
                }
                
                // Kondisi C: Teks jika pencarian kosong dari server
                if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty && !viewModel.isLoading && viewModel.errorMessage == nil {
                    Text("Tidak ada saran tempat untuk \"\(viewModel.searchQuery)\"")
                        .foregroundColor(.gray)
                        .padding(.top, 40)
                }
                
                // Kondisi D: Menampilkan List Live Autocomplete
                List(viewModel.searchResults) { place in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            viewModel.selectPlace(place)
                        }
                        isPresented = false 
                    }) {
                        HStack(spacing: 15) {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(Color(red: 0/255, green: 173/255, blue: 133/255))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(place.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                if let distance = place.distance {
                                    Text("\(distance) meters away")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.primary)
                    }
                }
            }
            .onAppear {
                isInputFocused = true 
            }
        }
    }
}

// MARK: - 3. BOTTOM SHEET (Detail Lokasi)
struct PlaceDetailSheet: View {
    let place: FSQPlace
    
    // Fitur bawaan SwiftUI untuk menutup sheet
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Header: Judul dan Tombol Close
            HStack {
                Text("SELECTED PLACE")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Tombol Cross (X) untuk menutup sheet
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.top, 10)
            
            HStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Destination")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text("4.9")
                            .font(.caption)
                            .fontWeight(.bold)
                        Text("•")
                            .foregroundColor(.gray)
                        
                        // Menampilkan jarak dan mengonversinya ke Kilometer jika lebih dari 1000m
                        if let distance = place.distance {
                            Text(formatDistance(distance))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            
            Spacer()
            
            Button(action: {
                print("Tambahkan \(place.name) ke Itinerary")
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
    
    // Fungsi bantuan untuk merapikan format jarak
    private func formatDistance(_ meters: Int) -> String {
        if meters >= 1000 {
            let kilometers = Double(meters) / 1000.0
            return String(format: "%.1f km away", kilometers)
        } else {
            return "\(meters) m away"
        }
    }
}

// MARK: - 4. UI COMPONENTS 
struct CategoryPill: View {
    let icon: String
    let title: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 14, weight: .semibold))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Color(red: 0/255, green: 173/255, blue: 133/255) : Color(.systemBackground))
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

struct MapPinView: View {
    let place: FSQPlace
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            if isSelected {
                Text(place.name)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color(red: 34/255, green: 40/255, blue: 49/255))
                    .cornerRadius(8)
                    .shadow(radius: 3)
                    .offset(y: -35)
            }
            
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                
                Circle()
                    .fill(Color(red: 0/255, green: 173/255, blue: 133/255)) 
                    .frame(width: 10, height: 10)
                
                if isSelected {
                    Circle()
                        .stroke(Color(red: 0/255, green: 173/255, blue: 133/255).opacity(0.5), lineWidth: 4)
                        .frame(width: 32, height: 32)
                }
            }
        }
    }
}

#Preview{
    ExploreView()
}
