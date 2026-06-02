//
//  TripDetailView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//


import SwiftUI
import MapKit

struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TripDetailViewModel
    
    // Kamera peta
    @State private var position: MapCameraPosition = .automatic
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 1. HEADER PETA (MapKit)
            ZStack(alignment: .topLeading) {
                Map(position: $position) {
                    if let dayPlan = viewModel.currentDayPlan {
                        let validDestinations = dayPlan.destinations.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
                        
                        // Garis Rute (Polyline)
                        let coordinates = validDestinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                        MapPolyline(coordinates: coordinates)
                            .stroke(Color.leapPrimary, style: StrokeStyle(lineWidth: 3, dash: [6, 6]))
                        
                        // Titik Lokasi (Markers)
                        ForEach(Array(validDestinations.enumerated()), id: \.element.id) { index, dest in
                            Annotation(dest.name, coordinate: CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)) {
                                ZStack {
                                    Circle()
                                        .fill(dest.category == "Tempat Makan" ? Color.pink : Color.leapPrimary)
                                        .frame(width: 24, height: 24)
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 10, height: 10)
                                }
                                .shadow(radius: 3)
                            }
                        }
                    }
                }
                .frame(height: 280)
                
                // Back Button & City Name Overlay
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                    }
                    Spacer()
                    Text("\(viewModel.trip.locationName) 📍")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.white)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                    Spacer()
                    // Dummy space to balance the back button
                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60) // Safe area
            }
            .ignoresSafeArea(edges: .top)
            
            // 2. DAY SELECTOR (Pills)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.dayPlans.enumerated()), id: \.element.id) { index, plan in
                        Button {
                            withAnimation { viewModel.selectedDayIndex = index }
                        } label: {
                            Text("Day \(plan.dayNumber)")
                                .font(.subheadline.bold())
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(viewModel.selectedDayIndex == index ? Color.leapPrimary : Color.gray.opacity(0.1))
                                .foregroundColor(viewModel.selectedDayIndex == index ? .white : .gray)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
            
            // 3. REORDERABLE TIMELINE LIST
            if let currentDayPlan = viewModel.currentDayPlan {
                List {
                    ForEach(currentDayPlan.destinations) { dest in
                        let time = viewModel.calculateTime(for: dest, in: currentDayPlan)
                        let isLast = dest.id == currentDayPlan.destinations.last?.id
                        
                        TimelineRowView(destination: dest, time: time, isLast: isLast)
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                    .onMove { source, destination in
                        viewModel.moveDestination(from: source, to: destination)
                    }
                    
                    // Add Destination Placeholder
                    Button(action: {}) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Tap + to add more destinations")
                                .foregroundColor(.gray)
                        }
                        .padding(.leading, 64)
                        .padding(.top, 16)
                        .padding(.bottom, 80)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(Color(hex: "#F9F9F9"))
            } else if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .background(Color(hex: "#F9F9F9").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadDayPlans()
        }
    }
}

// MARK: - Timeline Custom Row
struct TimelineRowView: View {
    let destination: TripDestination
    let time: String
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            // Kolom Kiri: Garis & Icon
            VStack(spacing: 0) {
                // Icon Bulat
                ZStack {
                    Circle()
                        .fill(destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary)
                        .frame(width: 44, height: 44)
                        .shadow(color: (destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).opacity(0.4), radius: 5, y: 2)
                    
                    Image(systemName: destination.category == "Tempat Makan" ? "fork.knife" : "mappin")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .bold))
                }
                
                // Garis Putus-putus ke bawah
                if !isLast {
                    Line()
                        .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(width: 2, height: 100) // Tinggi bisa disesuaikan
                        .foregroundColor(Color.gray.opacity(0.3))
                        .padding(.top, 8)
                }
            }
            .padding(.leading, 20)
            
            // Kolom Kanan: Info Card
            VStack(alignment: .leading, spacing: 12) {
                // Card Utama
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(destination.name)
                                .font(.headline)
                                .foregroundColor(.leapSecondary)
                            Text(destination.category)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text(time)
                            .font(.caption.bold())
                            .foregroundColor(destination.category == "Tempat Makan" ? .pink : .leapPrimary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background((destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text("Stay Duration: \(destination.stayDurationMinutes / 60) Hours")
                    }
                    .font(.caption.bold())
                    .foregroundColor(destination.category == "Tempat Makan" ? .pink : .leapPrimary)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                
                // Transit Info (Di bawah card)
                if !isLast {
                    HStack(spacing: 6) {
                        Image(systemName: "car.fill")
                        Text("\(destination.transitTimeToNextMinutes ?? 0) mins drive")
                    }
                    .font(.caption.bold())
                    .foregroundColor(.leapPrimary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.leapPrimary.opacity(0.1))
                    .clipShape(Capsule())
                    .padding(.bottom, 8) // Jarak ke Card selanjutnya
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 8)
    }
}

// Helper untuk menggambar garis lurus putus-putus
struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}