//
//  WatchDetailTripView.swift
//  Leaplan_Watch Watch App
//

import MapKit
import SwiftUI

struct WatchDetailTripView: View {
    @StateObject var viewModel: WatchDetailTripViewModel

    var body: some View {
        ZStack {
            Color(hex: "#F2F2F7").ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "#00AD85")))
            } else if let errorMessage = viewModel.errorMessage {
                VStack {
                    Text("Error")
                        .font(.headline)
                        .foregroundStyle(.red)
                    Text(errorMessage)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // MARK: - Full Screen Map
                        ZStack(alignment: .bottom) {
                            WatchMapView(viewModel: viewModel)
                                .disabled(true) // Disable interaction on watch map usually
                                .frame(height: WKInterfaceDevice.current().screenBounds.height)
                            
                            // Map Overlay Info
                            VStack {
                                HStack {
                                    Text(viewModel.trip.title)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(.black)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.8)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(.white.opacity(0.8)))
                                    Spacer()
                                    Text("MAP")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(RoundedRectangle(cornerRadius: 4).fill(Color(hex: "#00AD85")))
                                }
                                .padding(.horizontal, 8)
                                .padding(.top, 40) // safe area approx
                                Spacer()
                            }
                            
                            // Swipe up indicator
                            HStack {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 10, weight: .bold))
                                Text("Swipe up • Itinerary")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundStyle(.gray)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(.white))
                            .padding(.bottom, 20)
                            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        }
                        
                        // MARK: - Itinerary Header & Day Picker
                        VStack(alignment: .leading, spacing: 12) {
                            // Trip Info
                            VStack(alignment: .leading, spacing: 4) {
                                Text(viewModel.trip.title)
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(.black)
                                    .lineLimit(2)
                                
                                Text("\(viewModel.totalStopsForSelectedDay) stops • \(String(format: "%.1f", viewModel.totalDurationHoursForSelectedDay))h total")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color(hex: "#00AD85"))
                            }
                            .padding(.horizontal, 16)
                            
                            // Day Picker
                            if !viewModel.availableDays.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 8) {
                                        ForEach(0..<viewModel.availableDays.count, id: \.self) { index in
                                            let isSelected = (index == viewModel.selectedDayIndex)
                                            let dayLabel = "Day \(viewModel.availableDays[index])"
                                            
                                            Button(action: {
                                                withAnimation {
                                                    viewModel.selectedDayIndex = index
                                                    viewModel.calculateRoutes()
                                                }
                                            }) {
                                                Text(dayLabel)
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundStyle(isSelected ? .white : Color.gray)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(
                                                        Capsule().fill(isSelected ? Color(hex: "#00AD85") : Color(hex: "#F2F2F7"))
                                                    )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 24)
                        .padding(.bottom, 12)
                        .background(Color.white)
                        
                        Divider().padding(.horizontal, 16)
                        
                        // MARK: - Itinerary List
                        VStack(spacing: 0) {
                            ForEach(Array(viewModel.selectedDayDestinations.enumerated()), id: \.element.id) { index, dest in
                                WatchItineraryRow(
                                    destination: dest,
                                    index: index + 1,
                                    isLast: index == viewModel.selectedDayDestinations.count - 1
                                )
                            }
                        }
                        .padding(.bottom, 40)
                        .background(Color.white)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .onAppear {
            viewModel.fetchTripDetails()
        }
    }
}

// MARK: - Map View
struct WatchMapView: View {
    @ObservedObject var viewModel: WatchDetailTripViewModel
    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Map(position: $position) {
            ForEach(Array(viewModel.selectedDayDestinations.enumerated()), id: \.element.id) { index, dest in
                Annotation("", coordinate: dest.coordinate) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#00AD85"))
                            .frame(width: 24, height: 24)
                            .shadow(radius: 2)
                        Text("\(index + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            
            if !viewModel.selectedDayRoutes.isEmpty {
                ForEach(Array(viewModel.selectedDayRoutes.enumerated()), id: \.offset) { _, route in
                    MapPolyline(route)
                        .stroke(Color(hex: "#00AD85"), lineWidth: 4)
                }
            } else if !viewModel.selectedDayDestinations.isEmpty {
                // Fallback to straight dashed line while calculating
                MapPolyline(coordinates: viewModel.selectedDayDestinations.map { $0.coordinate })
                    .stroke(Color(hex: "#00AD85").opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round, dash: [8, 8]))
            }
        }
        .onChange(of: viewModel.selectedDayIndex) { _ in
            withAnimation {
                position = .region(viewModel.currentRegion)
            }
        }
        .onChange(of: viewModel.dayPlans.count) { _ in
            withAnimation {
                position = .region(viewModel.currentRegion)
            }
        }
    }
}

// MARK: - Itinerary Row
struct WatchItineraryRow: View {
    let destination: TripDestination
    let index: Int
    let isLast: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Drag icon placeholder (left side dots)
            Image(systemName: "line.3.horizontal")
                .font(.system(size: 12))
                .foregroundStyle(Color.gray.opacity(0.3))
                .padding(.top, 6)
            
            // Number Circle and Line
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "#00AD85"))
                        .frame(width: 24, height: 24)
                    Text("\(index)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.white)
                }
                
                if !isLast {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 2)
                        .frame(minHeight: 20)
                        .padding(.vertical, 4)
                }
            }
            
            // Text Details
            VStack(alignment: .leading, spacing: 2) {
                Text(destination.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.black)
                    .lineLimit(2)
                
                Text(destination.category)
                    .font(.system(size: 10))
                    .foregroundStyle(.gray)
            }
            .padding(.top, 4)
            
            Spacer()
            
            // Duration
            Text("\(destination.stayDurationMinutes / 60) hrs")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.gray)
                .padding(.top, 6)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
