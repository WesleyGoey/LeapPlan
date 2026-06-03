//
//  TripDetailView.swift
//  LeapPlan
//
//  Created by Sean tandjaja on 02/06/26.
//

import MapKit
import PhotosUI
import SwiftUI


struct TripDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: TripDestinationViewModel // NAMA BARU
    
    @State private var position: MapCameraPosition = .automatic
    @State private var isShowingEditSheet = false
    @State private var isShowingFABMenu = false
    @State private var isShowingAddPlaceSheet = false
    @State private var selectedDestinationToEdit: TripDestination? = nil
    
    init(trip: Trip) {
        _viewModel = StateObject(wrappedValue: TripDestinationViewModel(trip: trip))
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                // HEADER PETA
                ZStack(alignment: .topLeading) {
                    Map(position: $position) {
                        // 1. Gambar Jalur Jalan Raya Asli (Actual Route)
                        ForEach(Array(viewModel.actualRoutes.enumerated()), id: \.offset) { index, route in
                            MapPolyline(route.polyline)
                                .stroke(Color.leapPrimary, lineWidth: 4)
                        }
                        
                        // 2. Gambar Pin Angka
                        if let dayPlan = viewModel.currentDayPlan {
                            let validDestinations = dayPlan.destinations.filter { $0.latitude != 0.0 && $0.longitude != 0.0 }
                            
                            ForEach(Array(validDestinations.enumerated()), id: \.element.id) { index, dest in
                                Annotation(dest.name, coordinate: CLLocationCoordinate2D(latitude: dest.latitude, longitude: dest.longitude)) {
                                    ZStack {
                                        Circle().fill(Color.leapPrimary).frame(width: 28, height: 28).shadow(radius: 3)
                                        Text("\(index + 1)").font(.caption.bold()).foregroundColor(.white)
                                    }
                                }
                            }
                        }
                    }.frame(height: 280)
                    
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
                    }.padding(.horizontal, 20).padding(.top, 60)
                }
                
                // DAY SELECTOR
                if !viewModel.dayPlans.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(viewModel.dayPlans.enumerated()), id: \.element.id) { index, plan in
                                Button {
                                    withAnimation { viewModel.selectedDayIndex = index }
                                } label: {
                                    Text("Day \(plan.dayNumber)").font(.subheadline.bold()).padding(.horizontal, 20).padding(.vertical, 10)
                                        .background(viewModel.selectedDayIndex == index ? Color.leapPrimary : Color.gray.opacity(0.1))
                                        .foregroundColor(viewModel.selectedDayIndex == index ? .white : .gray).clipShape(Capsule())
                                }
                            }
                        }.padding(.horizontal, 20).padding(.vertical, 16)
                    }.background(Color.white)
                }
                
                // DAFTAR DESTINASI
                Group {
                    if viewModel.isLoading {
                        VStack {
                            Spacer()
                            ProgressView("Loading...").scaleEffect(1.2)
                            Spacer()
                        }
                    } else if let currentDayPlan = viewModel.currentDayPlan {
                        if currentDayPlan.destinations.isEmpty {
                            VStack {
                                Spacer()
                                Image(systemName: "mappin.and.ellipse").font(.system(size: 40)).foregroundColor(.gray.opacity(0.5)).padding(.bottom, 8)
                                Text("No destinations for this day.").font(.headline).foregroundColor(.gray)
                                Spacer()
                            }.frame(maxWidth: .infinity)
                        } else {
                            List {
                                ForEach(Array(currentDayPlan.destinations.enumerated()), id: \.element.id) { index, dest in
                                    let isLast = dest.id == currentDayPlan.destinations.last?.id
                                    
                                    TimelineRowView(
                                        destination: dest,
                                        indexNumber: index + 1, // PIN ANGKA
                                        isLast: isLast,
                                        onEdit: { selectedDestinationToEdit = dest },
                                        onDelete: { withAnimation { viewModel.deleteDestination(destID: dest.id) } }
                                    )
                                    .listRowInsets(EdgeInsets())
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                                }.onMove { source, destination in
                                    viewModel.moveDestination(from: source, to: destination)
                                }
                                Color.clear.frame(height: 100).listRowInsets(EdgeInsets()).listRowSeparator(.hidden).listRowBackground(Color.clear)
                            }.listStyle(.plain).scrollContentBackground(.hidden)
                        }
                    }
                }.background(Color(hex: "#F9F9F9"))
            }.edgesIgnoringSafeArea(.top)
            
            if isShowingFABMenu {
                Color.black.opacity(0.2).ignoresSafeArea().onTapGesture {
                    withAnimation(.spring()) { isShowingFABMenu = false }
                }.zIndex(1)
            }
            detailFABMenu.zIndex(2)
        }
        .navigationBarHidden(true).onAppear { viewModel.loadDayPlans() }
        .sheet(isPresented: $isShowingEditSheet) { TripEditView(viewModel: viewModel) }
        .sheet(isPresented: $isShowingAddPlaceSheet) { AddOrEditPlaceSheetView(viewModel: viewModel, mode: .add, destinationToEdit: nil) }
        .sheet(item: $selectedDestinationToEdit) { destination in AddOrEditPlaceSheetView(viewModel: viewModel, mode: .edit, destinationToEdit: destination) }
    }
    
    private var detailFABMenu: some View {
        VStack(alignment: .trailing, spacing: 16) {
            if isShowingFABMenu {
                Button {
                    withAnimation { isShowingFABMenu = false }
                    isShowingAddPlaceSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle").foregroundColor(.gray)
                        Text("Add Places").fontWeight(.semibold).foregroundColor(.leapSecondary)
                    }.padding(.horizontal, 20).padding(.vertical, 14).background(Color.white).clipShape(Capsule()).shadow(color: .black.opacity(0.1), radius: 5, y: 2)
                }.transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { isShowingFABMenu.toggle() }
            } label: {
                Image(systemName: isShowingFABMenu ? "xmark" : "plus").font(.system(size: 24, weight: .medium)).foregroundColor(.white).frame(width: 64, height: 64)
                    .background(isShowingFABMenu ? Color.leapSecondary : Color.leapPrimary).clipShape(Circle()).shadow(color: (isShowingFABMenu ? Color.leapSecondary : Color.leapPrimary).opacity(0.4), radius: 10, y: 5)
                    .rotationEffect(.degrees(isShowingFABMenu ? 90 : 0))
            }
        }.padding(.trailing, 24).padding(.bottom, 24)
    }
}

// Subview pendukung (Sheet Editor) menggunakan TripDestinationViewModel
struct AddOrEditPlaceSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripDestinationViewModel
    
    let mode: PlaceMode
    let destinationToEdit: TripDestination?
    
    @State private var searchQuery: String = ""
    @State private var selectedCategory = "Objek Wisata"
    @State private var stayDurationHours: Int = 2
    @State private var stayDurationMinutes: Int = 0
    @State private var selectedPlace: FSQPlace?
    @FocusState private var isSearchFocused: Bool
    
    init(viewModel: TripDestinationViewModel, mode: PlaceMode, destinationToEdit: TripDestination?) {
        self.viewModel = viewModel
        self.mode = mode
        self.destinationToEdit = destinationToEdit
        
        if mode == .edit, let dest = destinationToEdit {
            _searchQuery = State(initialValue: dest.name)
            _selectedCategory = State(initialValue: dest.category)
            _stayDurationHours = State(initialValue: dest.stayDurationMinutes / 60)
            _stayDurationMinutes = State(initialValue: dest.stayDurationMinutes % 60)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Search Location") {
                    VStack(alignment: .leading) {
                        TextField("Search in \(viewModel.trip.locationName)", text: $searchQuery)
                            .focused($isSearchFocused)
                            .onChange(of: searchQuery) { newValue in viewModel.searchPlacesAroundCity(query: newValue) }
                        
                        if isSearchFocused && !viewModel.addSearchResults.isEmpty {
                            List(viewModel.addSearchResults, id: \.fsq_place_id) { place in
                                Button(action: {
                                    selectedPlace = place
                                    searchQuery = place.name
                                    viewModel.addSearchResults = []
                                }) { Text(place.name) }
                            }.frame(height: 150)
                        }
                    }
                }
                Section("Category") {
                    Picker("Category", selection: $selectedCategory) {
                        Text("Objek Wisata").tag("Objek Wisata")
                        Text("Tempat Makan").tag("Tempat Makan")
                    }.pickerStyle(.segmented)
                }
                Section("Stay Duration") {
                    HStack {
                        Picker("Hours", selection: $stayDurationHours) { ForEach(0..<24) { i in Text("\(i) hrs").tag(i) } }.pickerStyle(.wheel).frame(width: 100, height: 100)
                        Picker("Minutes", selection: $stayDurationMinutes) { ForEach(0..<60) { i in Text("\(i) mins").tag(i) } }.pickerStyle(.wheel).frame(width: 100, height: 100)
                    }
                }
            }
            .navigationTitle(mode == .add ? "Add Destination" : "Edit Destination")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let totalMinutes = (stayDurationHours * 60) + stayDurationMinutes
                        viewModel.addManualDestination(name: searchQuery, category: selectedCategory, durationMinutes: totalMinutes, place: selectedPlace)
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TripEditView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: TripDestinationViewModel
    
    @State private var title: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var coverImageUrl: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedUIImage: UIImage?
    
    init(viewModel: TripDestinationViewModel) {
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
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            // MENGGUNAKAN BASE64 HELPER
                            if let selectedUIImage {
                                Image(uiImage: selectedUIImage).resizable().scaledToFill().frame(width: 150, height: 120).clipShape(RoundedRectangle(cornerRadius: 12))
                            } else if !coverImageUrl.isEmpty, let uiImage = Base64Helper.decode(coverImageUrl) {
                                Image(uiImage: uiImage).resizable().scaledToFill().frame(width: 150, height: 120).clipShape(RoundedRectangle(cornerRadius: 12))
                            } else {
                                RoundedRectangle(cornerRadius: 12).fill(Color.gray.opacity(0.2)).frame(width: 150, height: 120).overlay(Image(systemName: "photo").font(.largeTitle).foregroundColor(.gray))
                            }
                            
                            HStack(spacing: 20) {
                                PhotosPicker(selection: $selectedPhotoItem, matching: .images, photoLibrary: .shared()) {
                                    Text("Change Photo").font(.subheadline).foregroundColor(.leapPrimary)
                                }
                                
                                if !coverImageUrl.isEmpty || selectedUIImage != nil {
                                    Button(role: .destructive, action: {
                                        withAnimation {
                                            selectedUIImage = nil
                                            coverImageUrl = "" // Mengosongkan gambar
                                            selectedPhotoItem = nil
                                        }
                                    }) {
                                        Image(systemName: "trash").font(.subheadline).foregroundColor(.leapHighlight)
                                    }
                                }
                            }
                        }
                        Spacer()
                    }
                    .padding(.vertical, 8)
                }
                Section("Trip Information") { TextField("Trip Name", text: $title) }
                Section(footer: Text("If you reduce the travel dates, the extra days from your itinerary will be permanently deleted.")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Trip").navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        Task {
                            var finalImageUrl = coverImageUrl
                            if let selectedUIImage, let base64 = Base64Helper.encode(selectedUIImage) {
                                finalImageUrl = base64
                            }
                            await viewModel.updateTripDetails(title: title, startDate: startDate, endDate: endDate, coverImageUrl: finalImageUrl)
                            dismiss()
                        }
                    }.bold().foregroundColor(.leapPrimary)
                }
            }.onChange(of: selectedPhotoItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                        selectedUIImage = img
                    }
                }
            }
        }
    }
}

struct TimelineRowView: View {
    let destination: TripDestination
    let indexNumber: Int
    let isLast: Bool
    var onEdit: () -> Void
    var onDelete: () -> Void
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // DRAG ICON (6 Titik)
            Image(systemName: "circle.grid.2x3.fill")
                .foregroundColor(.gray.opacity(0.4))
                .padding(.top, 16)
                .padding(.leading, 16)
            
            // PIN ANGKA DAN GARIS TIMELINE
            VStack(spacing: 0) {
                ZStack {
                    Circle().fill(Color.leapPrimary).frame(width: 32, height: 32)
                        .shadow(color: Color.leapPrimary.opacity(0.3), radius: 5, y: 2)
                    Text("\(indexNumber)")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                
                if !isLast {
                    Line().stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                        .frame(width: 2)
                        .foregroundColor(Color.gray.opacity(0.3))
                        .padding(.top, 4)
                }
            }
            
            // BOX KONTEN DESTINASI
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(destination.name).font(.headline).foregroundColor(.leapSecondary)
                            Text(destination.category).font(.subheadline).foregroundColor(.gray)
                        }
                        Spacer()
                        Menu {
                            Button(action: onEdit) { Label("Edit Place", systemImage: "pencil") }
                            Button(role: .destructive, action: onDelete) { Label("Delete Place", systemImage: "trash") }
                        } label: {
                            Image(systemName: "ellipsis").font(.system(size: 18, weight: .bold))
                                .padding(8).background(Color.gray.opacity(0.1)).clipShape(Circle()).foregroundColor(.gray)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text("Stay Duration: \(destination.stayDurationMinutes / 60)h \(destination.stayDurationMinutes % 60)m")
                    }.font(.caption.bold()).foregroundColor(.leapPrimary)
                }
                .padding(16).background(Color.white).cornerRadius(16).shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                
                // MUNCULKAN WAKTU TEMPUH (ETA) DI BAWAH BOX
                if !isLast {
                    HStack(spacing: 6) {
                        Image(systemName: "car.fill")
                        Text("\(destination.transitTimeToNextMinutes ?? 0) mins drive")
                    }
                    .font(.caption.bold()).foregroundColor(.gray)
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(Capsule())
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                } else {
                    Spacer().frame(height: 16)
                }
            }
            .padding(.trailing, 20)
        }
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
