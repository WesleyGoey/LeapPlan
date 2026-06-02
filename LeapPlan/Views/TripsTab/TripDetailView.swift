//
//  TripDetailView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

//
//  TripDetailView.swift
//  LeapPlan
//

import SwiftUI
import MapKit
import PhotosUI // PENTING UNTUK UPLOAD GAMBAR

struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TripDetailViewModel
    @State private var position: MapCameraPosition = .automatic
    @State private var isShowingEditSheet = false
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDetailViewModel(trip: trip))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topLeading) {
                Map(position: $position) {
                    if let dayPlan = viewModel.currentDayPlan {
                        let validDestinations = dayPlan.destinations.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
                        let coordinates = validDestinations.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                        MapPolyline(coordinates: coordinates).stroke(Color.leapPrimary, style: StrokeStyle(lineWidth: 3, dash: [6, 6]))
                        
                        ForEach(Array(validDestinations.enumerated()), id: \.element.id) { index, dest in
                            Annotation(dest.name, coordinate: CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)) {
                                ZStack {
                                    Circle().fill(dest.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).frame(width: 24, height: 24)
                                    Circle().fill(Color.white).frame(width: 10, height: 10)
                                }.shadow(radius: 3)
                            }
                        }
                    }
                }
                .frame(height: 280) // MEMBATASI TINGGI PETA
                
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "arrow.left").font(.system(size: 20, weight: .semibold)).foregroundColor(.black).padding(12).background(Color.white).clipShape(Circle()).shadow(radius: 5)
                    }
                    Spacer()
                    Text("\(viewModel.trip.locationName) 📍").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10).background(Color.white).clipShape(Capsule()).shadow(radius: 5)
                    Spacer()
                    Button { isShowingEditSheet = true } label: {
                        Image(systemName: "ellipsis").font(.system(size: 20, weight: .semibold)).foregroundColor(.black).padding(12).background(Color.white).clipShape(Circle()).shadow(radius: 5)
                    }
                }
                .padding(.horizontal, 20).padding(.top, 60)
            }
            .ignoresSafeArea(edges: .top)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(viewModel.dayPlans.enumerated()), id: \.element.id) { index, plan in
                        Button { withAnimation { viewModel.selectedDayIndex = index } } label: {
                            Text("Day \(plan.dayNumber)").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10).background(viewModel.selectedDayIndex == index ? Color.leapPrimary : Color.gray.opacity(0.1)).foregroundColor(viewModel.selectedDayIndex == index ? .white : .gray).clipShape(Capsule())
                        }
                    }
                }.padding(.horizontal, 20).padding(.vertical, 16)
            }
            
            if let currentDayPlan = viewModel.currentDayPlan {
                if currentDayPlan.destinations.isEmpty {
                    VStack {
                        Spacer()
                        Text("No destinations for this day.").foregroundColor(.gray)
                        Spacer()
                    }.frame(maxWidth: .infinity)
                } else {
                    List {
                        ForEach(currentDayPlan.destinations) { dest in
                            let time = viewModel.calculateTime(for: dest, in: currentDayPlan)
                            let isLast = dest.id == currentDayPlan.destinations.last?.id
                            
                            // MELEWATKAN FUNGSI DELETE/EDIT KE TIMELINE ROW
                            TimelineRowView(destination: dest, time: time, isLast: isLast, onEdit: {
                                print("Edit \(dest.name)") // Placeholder untuk fitur Edit Tempat
                            }, onDelete: {
                                withAnimation { viewModel.deleteDestination(destID: dest.id) }
                            })
                            .listRowInsets(EdgeInsets())
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }
                        .onMove { source, destination in viewModel.moveDestination(from: source, to: destination) }
                        
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "plus.circle").font(.title2).foregroundColor(.gray)
                                Text("Tap + to add more destinations").foregroundColor(.gray)
                            }.padding(.leading, 64).padding(.top, 16).padding(.bottom, 80)
                        }
                        .listRowInsets(EdgeInsets()).listRowSeparator(.hidden).listRowBackground(Color.clear)
                    }
                    .listStyle(.plain).scrollContentBackground(.hidden).background(Color(hex: "#F9F9F9"))
                }
            } else if viewModel.isLoading {
                Spacer(); ProgressView(); Spacer()
            }
        }
        .background(Color(hex: "#F9F9F9").ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear { viewModel.loadDayPlans() }
        .sheet(isPresented: $isShowingEditSheet) { TripEditView(viewModel: viewModel) }
    }
}

// MARK: - EDITOR TRIP DENGAN UPLOAD GAMBAR DARI GALERI
struct TripEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripDetailViewModel
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var coverImageUrl: String
    
    // State untuk PhotosPicker
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    init(viewModel: TripDetailViewModel) {
        self.viewModel = viewModel
        _title = State(initialValue: viewModel.trip.title)
        _startDate = State(initialValue: viewModel.trip.startDate)
        _endDate = State(initialValue: viewModel.trip.endDate)
        _coverImageUrl = State(initialValue: viewModel.trip.coverImageUrl ?? "")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Trip Cover Image") {
                    // FITUR UPLOAD GAMBAR
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                        if let selectedUIImage {
                            Image(uiImage: selectedUIImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            HStack {
                                Image(systemName: "photo.badge.plus")
                                Text("Upload image from phone")
                            }
                            .foregroundColor(.leapPrimary)
                        }
                    }
                    .onChange(of: selectedPhotoItem) { newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                                selectedUIImage = img
                            }
                        }
                    }
                }
                
                Section("Trip Information") {
                    TextField("Trip Name", text: $title)
                }
                
                Section("Travel Dates") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            // Jika ada gambar baru yang dipilih, simpan ke memori HP dan ambil path-nya
                            var finalImageUrl = coverImageUrl
                            if let selectedUIImage, let localPath = viewModel.saveImageLocally(image: selectedUIImage) {
                                finalImageUrl = localPath
                            }
                            await viewModel.updateTripDetails(title: title, startDate: startDate, endDate: endDate, coverImageUrl: finalImageUrl)
                            dismiss()
                        }
                    }.bold()
                }
            }
        }
    }
}

// MARK: - TIMELINE ROW DENGAN HOVER MENU (3-DOT)
struct TimelineRowView: View {
    let destination: TripDestination
    let time: String
    let isLast: Bool
    
    // Aksi saat menu ditekan
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).frame(width: 44, height: 44)
                        .shadow(color: (destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).opacity(0.4), radius: 5, y: 2)
                    Image(systemName: destination.category == "Tempat Makan" ? "fork.knife" : "mappin").foregroundColor(.white).font(.system(size: 16, weight: .bold))
                }
                if !isLast {
                    Line().stroke(style: StrokeStyle(lineWidth: 2, dash: [5])).frame(width: 2, height: 100).foregroundColor(Color.gray.opacity(0.3)).padding(.top, 8)
                }
            }
            .padding(.leading, 20)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(destination.name).font(.headline).foregroundColor(.leapSecondary)
                            Text(destination.category).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                        
                        // Waktu
                        Text(time).font(.caption.bold()).foregroundColor(destination.category == "Tempat Makan" ? .pink : .leapPrimary).padding(.horizontal, 10).padding(.vertical, 6).background((destination.category == "Tempat Makan" ? Color.pink : Color.leapPrimary).opacity(0.1)).clipShape(Capsule())
                        
                        // HOVER MENU 3-TITIK UNTUK CARD
                        Menu {
                            Button(action: onEdit) {
                                Label("Edit Place", systemImage: "pencil")
                            }
                            Button(role: .destructive, action: onDelete) {
                                Label("Delete Place", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.system(size: 18))
                                .foregroundColor(.gray)
                                .padding(8)
                                .background(Color.gray.opacity(0.1))
                                .clipShape(Circle())
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text("Stay Duration: \(destination.stayDurationMinutes / 60) Hours")
                    }.font(.caption.bold()).foregroundColor(destination.category == "Tempat Makan" ? .pink : .leapPrimary)
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                
                if !isLast {
                    HStack(spacing: 6) {
                        Image(systemName: "car.fill")
                        Text("\(destination.transitTimeToNextMinutes ?? 0) mins drive")
                    }.font(.caption.bold()).foregroundColor(.leapPrimary).padding(.horizontal, 12).padding(.vertical, 6).background(Color.leapPrimary.opacity(0.1)).clipShape(Capsule()).padding(.bottom, 8)
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 8)
    }
}

struct Line: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}
